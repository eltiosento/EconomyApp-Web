import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/providers/auth_provider.dart';
import 'package:economy_app/providers/user_dto_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditUserNameScreen extends ConsumerStatefulWidget {
  final String userName;

  const EditUserNameScreen({super.key, required this.userName});

  @override
  ConsumerState<EditUserNameScreen> createState() => _NewExpenseFormState();
}

class _NewExpenseFormState extends ConsumerState<EditUserNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _userNameController.text = widget.userName;
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(userProvider.notifier)
          .updateUserName(username: _userNameController.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nombre de usuario actualizado correctamente')),
        );
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
        title: Text('Editar nombre de usuario'),
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
                'Desde aquí puedes actualizar tu nombre de usuario, ten en cuenta que este nombre es único y no puede repetirse con otro usuario. Una vez actualizado, tendrás que volver a iniciar sesión para que los cambios surtan efecto.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Debes poner un nombre' : null,
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
