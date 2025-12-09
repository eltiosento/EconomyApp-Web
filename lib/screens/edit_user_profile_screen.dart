import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/user_dto.dart';
import 'package:economy_app/providers/user_dto_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditUserProfileScreen extends ConsumerStatefulWidget {
  final UserDto userDto;

  const EditUserProfileScreen({super.key, required this.userDto});

  @override
  ConsumerState<EditUserProfileScreen> createState() => _NewExpenseFormState();
}

class _NewExpenseFormState extends ConsumerState<EditUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.userDto.firtName ?? '';
    _lastNameController.text = widget.userDto.lastName ?? '';
    _emailController.text = widget.userDto.email;
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(userProvider.notifier)
          .updateUser(
            username: widget.userDto.username,
            email: _emailController.text,
            firstName:
                _firstNameController.text.isEmpty ? null : _firstNameController.text,
            lastName: _lastNameController.text.isEmpty ? null : _lastNameController.text,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Datos actualizados correctamente')));
        ref.invalidate(userProvider);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
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
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce el email';
                  } else if (!RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  ).hasMatch(value)) {
                    return 'Introduce un email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
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
                    child: Text('Actualizar', style: TextStyle(fontSize: 16)),
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
