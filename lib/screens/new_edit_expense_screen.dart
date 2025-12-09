import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/expense_dto.dart';
import 'package:economy_app/providers/balance_global_provider.dart';
import 'package:economy_app/providers/expenses_provider.dart';
import 'package:economy_app/providers/savings_categories_provider.dart';
import 'package:economy_app/providers/summary_categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewAndEditExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseDto? expenseDto;
  final int subCategoryId;

  const NewAndEditExpenseScreen({
    super.key,
    this.expenseDto,
    required this.subCategoryId,
  });

  @override
  ConsumerState<NewAndEditExpenseScreen> createState() => _NewExpenseFormState();
}

class _NewExpenseFormState extends ConsumerState<NewAndEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _expenseDate;

  final DateTime now = DateTime.now();
  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;

  bool _isSubmitting = false;

  // NUEVAS variables para “usar ahorros”
  bool _useSavings = false;
  int? _selectedSavingId; // Aquí guardamos la única categoría elegida

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.expenseDto != null) {
      _descriptionController.text = widget.expenseDto!.description;
      _amountController.text = widget.expenseDto!.amount.toString();
      _expenseDate = widget.expenseDto!.expenseDate;
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (widget.expenseDto == null) {
        if (!_useSavings) {
          await ref
              .read(
                expenseProvider((
                  widget.subCategoryId,
                  _expenseDate!.month,
                  _expenseDate!.year,
                )).notifier,
              )
              .addExpense(
                description: _descriptionController.text,
                amount: double.tryParse(_amountController.text) ?? 0.0,
                expenseDate: _expenseDate!,
              );
        } else {
          // Si se usa ahorros, se guarda la categoría seleccionada
          await ref
              .read(
                expenseProvider((
                  widget.subCategoryId,
                  _expenseDate!.month,
                  _expenseDate!.year,
                )).notifier,
              )
              .savingsToExpense(
                description: _descriptionController.text,
                amount: double.tryParse(_amountController.text) ?? 0.0,
                date: _expenseDate!,
                fromCategoryId: _selectedSavingId!,
              );
        }
      } else {
        if (!_useSavings) {
          await ref
              .read(
                expenseProvider((
                  widget.subCategoryId,
                  _expenseDate!.month,
                  _expenseDate!.year,
                )).notifier,
              )
              .updateExpense(
                expenseId: widget.expenseDto!.id,
                description: _descriptionController.text,
                amount: double.tryParse(_amountController.text) ?? 0.0,
                expenseDate: _expenseDate!,
              );
        } else {
          // Si se usa ahorros, se guarda la categoría seleccionada
          await ref
              .read(
                expenseProvider((
                  widget.subCategoryId,
                  _expenseDate!.month,
                  _expenseDate!.year,
                )).notifier,
              )
              .savingsToExpense(
                description: _descriptionController.text,
                amount: double.tryParse(_amountController.text) ?? 0.0,
                date: _expenseDate!,
                fromCategoryId: _selectedSavingId!,
              );
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                widget.expenseDto == null
                    ? Text('Gasto añadido correctamente')
                    : Text('Gasto actualizado correctamente'),
          ),
        );
        // INVALIDEM TOTS ELS PROVIDERS QUE DEPENEN DE LES DESPESES
        // Invalidem directament el provider del servici per no tindre mal de caps amb les fexes.
        ref.invalidate(expenseServiceProvider);
        // Com que els balanç global i del mes depenen del mateix servici, en que invaidem el balanceServiceProvider, automaticament, els porviders depenents de ell també es tornaran a carregar.
        ref.invalidate(balanceServiceProvider);
        // Invalidem el servici de les categories resum, per a no tindre que iterar tots els mesos i anys, i automaticament invalidem els providers fills, que son el summaryCategoriesProvider (el que trobem a la pantalla principal) i el summaryCategorySubcategoriesProvider (el que trobem a la pantalla  on es mostra el pastís i les subcategories).
        ref.invalidate(summaryCategoriesServiceProvider);

        Navigator.of(context).pop();
      }
    } catch (e) {
      final errorMessage = e is ApiError ? e.message : 'Error inesperado';

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
      }
    } finally {
      if (context.mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() => _expenseDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenim les categories d'estalvi
    // per a mostrar-les si l'usuari activa l'opció "Usar ahorros".
    final savingCatsAsync = ref.watch(savingCategoriesProvider);
    return Scaffold(
      appBar: AppBar(
        title: widget.expenseDto == null ? Text('Nuevo gasto') : Text('Editar gasto'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Importe (€)'),
                validator:
                    (value) =>
                        value == null || double.tryParse(value) == null
                            ? 'Debes poner un importe válido'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                maxLines: 2, // Permitir varias líneas para la descripción
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Debes poner una descripción'
                            : null,
              ),
              const SizedBox(height: 20),
              FormField<DateTime>(
                validator: (value) {
                  if (_expenseDate == null) {
                    return 'Selecciona una fecha';
                  }
                  return null;
                },
                builder: (formFieldState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _expenseDate == null
                                  ? 'Pulsa el icono para seleccionar una fecha.'
                                  : 'Fecha: ${_expenseDate!.day}-${_expenseDate!.month}-${_expenseDate!.year}',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _selectDate(context);
                              formFieldState.didChange(
                                _expenseDate,
                              ); // marca el camp com canviat
                            },
                            icon: const Icon(Icons.event),
                            tooltip: 'Selecciona una fecha',
                          ),
                        ],
                      ),
                      if (formFieldState.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 5),
                          child: Text(
                            formFieldState.errorText!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // 1. Mostramos las categorías de resumen
              savingCatsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, st) => Center(child: Text('Error cargando categorías: $err')),
                data:
                    (categories) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Switch para activar/desactivar “Usar ahorros”
                        SwitchListTile(
                          title: const Text('Usar ahorros'),
                          value: _useSavings,
                          onChanged: (val) => setState(() => _useSavings = val),
                        ),

                        // 2. Si está activo, mostramos el FormField con radios
                        if (_useSavings)
                          FormField<int>(
                            initialValue: _selectedSavingId,
                            validator: (val) {
                              if (_useSavings && val == null) {
                                return 'Selecciona una categoría';
                              }
                              return null;
                            },
                            builder: (state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Un RadioListTile por cada categoría
                                  ...categories.map(
                                    (cat) => RadioListTile<int>(
                                      title: Text(
                                        '${cat.categoryName} (${cat.totalExpenses.toStringAsFixed(2)} €)',
                                      ),
                                      value: cat.id,
                                      groupValue: _selectedSavingId,
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedSavingId = val;
                                          state.didChange(val);
                                        });
                                      },
                                    ),
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16, top: 4),
                                      child: Text(
                                        state.errorText!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
              ),
              const SizedBox(height: 70),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed:
                        _isSubmitting
                            ? null
                            : () {
                              _submitForm(context);
                              // Tanca el teclat quan es prem el botó
                              // i es fa un submit del formulari.
                              FocusScope.of(context).unfocus();
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child:
                        widget.expenseDto == null
                            ? Text('Guardar', style: TextStyle(fontSize: 16))
                            : Text('Actualizar', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 70),
              _isSubmitting
                  ? Center(
                    child: const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
