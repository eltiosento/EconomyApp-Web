import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/providers/auth_provider.dart';
import 'package:economy_app/providers/user_dto_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditUserPasswordScreen extends ConsumerStatefulWidget {
  const EditUserPasswordScreen({super.key});

  @override
  ConsumerState<EditUserPasswordScreen> createState() => _NewExpenseFormState();
}

class _NewExpenseFormState extends ConsumerState<EditUserPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userPasswordController = TextEditingController();
  final _userPasswordController2 = TextEditingController();

  bool _isSubmitting = false;
  bool _isObscure = true;

  @override
  void dispose() {
    _userPasswordController.dispose();
    _userPasswordController2.dispose();
    super.dispose();
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(userProvider.notifier)
          .updateUserPassword(
            password1: _userPasswordController.text,
            password2: _userPasswordController2.text,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Contraseña actualizada correctamente')));
        ref.read(authProvider.notifier).logout();
        // Actualitzem el userProvider perque com que hem tancat sessió, hem de refrescar l'estat de l'usuari.
        // Això es fa perque el provider d'usuari depen de l'authProvider, i si aquest canvia, el d'usuari també ha de canviar.
        ref.invalidate(userProvider);
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.LOGIN, (route) => false);
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
        title: Text('Editar contraseña'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Desde aquí puedes actualizar tu contraseña de usuario. Una vez actualizada, tendrás que volver a iniciar sesión para que los cambios surtan efecto.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Debes poner una contraseña';
                  } else if (value.length < 8) {
                    return 'La contraseña debe tener al menos 8 caracteres';
                  }
                  return null;
                },
                controller: _userPasswordController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Debes poner una contraseña';
                  } else if (value != _userPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
                controller: _userPasswordController2,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Repite la Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
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
                    child: Text('Actualizar y salir', style: TextStyle(fontSize: 16)),
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
