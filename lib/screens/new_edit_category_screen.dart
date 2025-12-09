import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/category_summary.dart';
import 'package:economy_app/providers/balance_global_provider.dart';
import 'package:economy_app/providers/providers_utils_providers.dart';
import 'package:economy_app/providers/summary_categories_provider.dart';
import 'package:economy_app/providers/summary_category_subcategories_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewAndEditCategoryScreen extends ConsumerStatefulWidget {
  final SummaryCategory? category;
  final int? parentCategoryId;
  const NewAndEditCategoryScreen({super.key, this.category, this.parentCategoryId});

  @override
  ConsumerState<NewAndEditCategoryScreen> createState() => _NewExpenseFormState();
}

class _NewExpenseFormState extends ConsumerState<NewAndEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController();
  //final _iconController = TextEditingController();
  bool _isSaving = false;
  String _iconCategory = '';
  final _date = DateTime.now();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    // _iconController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.categoryName;
      _descriptionController.text = widget.category!.description;
      _isSaving = widget.category!.isSaving;
      _goalController.text = widget.category!.goal?.toString() ?? '';
      //_iconController.text = widget.category!.iconPath;
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      if (widget.parentCategoryId != null) {
        if (widget.category == null) {
          await ref
              .read(
                summaryCategorySubcategoriesProvider((
                  widget.parentCategoryId!,
                  _date.month,
                  _date.year,
                )).notifier,
              )
              .addCategory(
                name: _nameController.text,
                description: _descriptionController.text,
                parentCategoryId: widget.parentCategoryId!,
                //urlImage: _iconController.text.isEmpty ? null : _iconController.text,
                urlImage: _iconCategory.isEmpty ? null : _iconCategory,
                goal:
                    _goalController.text.isEmpty
                        ? null
                        : double.tryParse(_goalController.text),
                isSaving: _isSaving,
              );
        } else {
          await ref
              .read(
                summaryCategorySubcategoriesProvider((
                  widget.parentCategoryId!,
                  _date.month,
                  _date.year,
                )).notifier,
              )
              .updateCategory(
                categoryId: widget.category!.id,
                name: _nameController.text,
                description: _descriptionController.text,
                //urlImage: _iconController.text.isEmpty ? null : _iconController.text,
                urlImage: _iconCategory.isEmpty ? null : _iconCategory,
                goal:
                    _goalController.text.isEmpty
                        ? null
                        : double.tryParse(_goalController.text),
                parentCategoryId: widget.parentCategoryId!,
                isSaving: _isSaving,
              );
        }
      } else {
        if (widget.category == null) {
          await ref
              .read(summaryCategoriesProvider((_date.month, _date.year)).notifier)
              .addCategory(
                name: _nameController.text,
                description: _descriptionController.text,
                //urlImage: _iconController.text.isEmpty ? null : _iconController.text,
                urlImage: _iconCategory.isEmpty ? null : _iconCategory,
                goal:
                    _goalController.text.isEmpty
                        ? null
                        : double.tryParse(_goalController.text),
                isSaving: _isSaving,
              );
        } else {
          await ref
              .read(summaryCategoriesProvider((_date.month, _date.year)).notifier)
              .updateCategory(
                categoryId: widget.category!.id,
                name: _nameController.text,
                description: _descriptionController.text,
                //urlImage: _iconController.text.isEmpty ? null : _iconController.text,
                urlImage: _iconCategory.isEmpty ? null : _iconCategory,
                goal:
                    _goalController.text.isEmpty
                        ? null
                        : double.tryParse(_goalController.text),
                isSaving: _isSaving,
              );
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                widget.category == null
                    ? Text('Categoria añadida correctamente')
                    : Text('Categoria actualizado correctamente'),
          ),
        );
        // INVALIDEM PROVIDERS

        // Invalidem el servici de les categories resum, per a no tindre que iterar tots els mesos i anys, i automaticament invalidem els providers fills, que son el summaryCategoriesProvider (el que trobem a la pantalla principal) i el summaryCategorySubcategoriesProvider (el que trobem a la pantalla  on es mostra el pastís i les subcategories). I també el balanceServiceProvider, per a que es recalculi el balanç global.
        ref.invalidate(summaryCategoriesServiceProvider);
        ref.invalidate(selectedSubcategoryIconProvider);
        ref.invalidate(balanceServiceProvider);
        ref.invalidate(categoriesServiceProvider);

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

  @override
  Widget build(BuildContext context) {
    _iconCategory = ref.watch(selectedSubcategoryIconProvider);
    return Scaffold(
      appBar: AppBar(
        title:
            widget.category == null ? Text('Nueva categoria') : Text('Editar categoria'),
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Debes poner un nombre' : null,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _goalController,
                decoration:
                    widget.category == null
                        ? const InputDecoration(labelText: 'Objetivo (€)')
                        : InputDecoration(
                          labelText: 'Objetivo (€), pon 0 para eliminar el objetivo',
                        ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final goal = double.tryParse(value);
                    if (goal == null || goal < 0) {
                      return 'El objetivo debe ser un número positivo';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              /*
              TextFormField(
                controller: _iconController,
                decoration: InputDecoration(labelText: 'Url icono'),
              ),*/
              widget.parentCategoryId != null
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: const Text(
                          'Marca la casilla si quieres que esta categoría se destine a los ahorros.',
                        ),
                      ),
                      Checkbox(
                        value: _isSaving,
                        onChanged: (value) {
                          setState(() {
                            _isSaving = value ?? false;
                          });
                        },
                      ),
                    ],
                  )
                  : SizedBox.shrink(),
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.ICON_SELECTED);
                    },
                    icon:
                        //_iconController.text.isEmpty
                        _iconCategory.isEmpty
                            ? const Icon(Icons.add_a_photo, size: 70)
                            : Image.asset(_iconCategory, width: 70, height: 70),
                  ),
                  const SizedBox(width: 15),
                  Expanded(child: const Text('Pulsa sobre la imagen para cambiarla')),
                ],
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
                        widget.category == null
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
