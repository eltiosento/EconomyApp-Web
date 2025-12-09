import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/income_dto.dart';
import 'package:economy_app/providers/balance_global_provider.dart';
import 'package:economy_app/providers/income_user_provider.dart';
import 'package:economy_app/providers/incomes_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewAndEditIncomeScreen extends ConsumerStatefulWidget {
  final IncomeDto? incomeDto;
  const NewAndEditIncomeScreen({super.key, this.incomeDto});

  @override
  ConsumerState<NewAndEditIncomeScreen> createState() => _NewIncomeFormState();
}

class _NewIncomeFormState extends ConsumerState<NewAndEditIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _incomeDate;

  final DateTime now = DateTime.now();
  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.incomeDto != null) {
      _descriptionController.text = widget.incomeDto!.description;
      _amountController.text = widget.incomeDto!.amount.toString();
      _incomeDate = widget.incomeDto!.incomeDate;
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (widget.incomeDto == null) {
        await ref
            .read(incomeUserProvider.notifier)
            .addIncome(
              description: _descriptionController.text,
              amount: double.tryParse(_amountController.text) ?? 0.0,
              incomeDate: _incomeDate!,
            );
      } else {
        await ref
            .read(incomeUserProvider.notifier)
            .updateIncome(
              incomeId: widget.incomeDto!.id,
              description: _descriptionController.text,
              amount: double.tryParse(_amountController.text) ?? 0.0,
              incomeDate: _incomeDate!,
            );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                widget.incomeDto == null
                    ? Text('Ingreso añadido correctamente')
                    : Text('Ingreso actualizado correctamente'),
          ),
        );
        ref.invalidate(balanceServiceProvider);
        ref.invalidate(incomeServiceProvider);
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
      setState(() => _incomeDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.incomeDto == null ? Text('Nuevo ingreso') : Text('Editar ingreso'),
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
                  if (_incomeDate == null) {
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
                              _incomeDate == null
                                  ? 'Pulsa el icono para seleccionar una fecha.'
                                  : 'Fecha: ${_incomeDate!.day}-${_incomeDate!.month}-${_incomeDate!.year}',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await _selectDate(context);
                              formFieldState.didChange(
                                _incomeDate,
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
                        widget.incomeDto == null
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
