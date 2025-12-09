import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/auth_response.dart';
import 'package:economy_app/models/register_request.dart';
import 'package:economy_app/providers/auth_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isObscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ens suscrivim al proveïdor d'autenticació per obtenir l'estat d'autenticació actual.
    final authState = ref.watch(authProvider);

    // Listener del registro
    ref.listen<AsyncValue<AuthResponse?>>(authProvider, (previous, next) {
      final registerSuccess = previous is AsyncLoading && next is AsyncData;
      if (registerSuccess && next.value != null) {
        // Elimina totes les rutes anteriors de la pila de navegació i afegeix la ruta d'inici.
        // Això és útil per evitar que l'usuari pugui tornar enrere a la pantalla d'inici de sessió després d'haver iniciat sessió correctament.
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.HOME, (route) => false);
      }

      if (next is AsyncError) {
        final msg = (next.error as ApiError).message;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
        // Ara netegem l'error posant l'estat a `data(null)`:
        ref.read(authProvider.notifier).logout(); // limpiar estado
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundColor1, AppColors.backgroundColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;

            return isDesktop
                ? _buildDesktopLayout(authState)
                : _buildMobileLayout(authState);
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // DESKTOP / WIDE
  // ─────────────────────────────────────────────────────────────
  Widget _buildDesktopLayout(AsyncValue<AuthResponse?> authState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // IZQUIERDA
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 650),
                        child: _buildWelcomeSection(),
                      ),
                    ),
                  ),

                  // DERECHA (FORMULARIO)
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: _registerCard(authState),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MOBILE
  // ─────────────────────────────────────────────────────────────
  Widget _buildMobileLayout(AsyncValue<AuthResponse?> authState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 25),
              child: Center(child: _registerCard(authState)),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TARJETA DEL REGISTRO
  // ─────────────────────────────────────────────────────────────
  Widget _registerCard(AsyncValue<AuthResponse?> authState) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Colors.white54],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 15, offset: Offset(5, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/img_register.png', height: 250, width: 250),

          Text(
            'Crea tu cuenta',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryColor,
            ),
          ),

          const SizedBox(height: 20),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // USUARIO
                TextFormField(
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Introduce el nombre de usuario.";
                    } else if (value.length < 3 || value.length > 50) {
                      return "El nombre de usuario debe tener entre 3 y 50 caracteres.";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),

                // EMAIL
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Introduce el email.";
                    }
                    final regex = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!regex.hasMatch(value)) {
                      return "Introduce un email válido.";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),

                // CONTRASEÑA
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Introduce la contraseña.";
                    } else if (value.length < 8) {
                      return "La contraseña debe tener al menos 8 caracteres";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() => _isObscure = !_isObscure);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          // BOTÓN DE REGISTRO
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
              ),
              child: const Text('Registrarse', style: TextStyle(fontSize: 15)),
            ),
          ),

          const SizedBox(height: 20),

          // MENSAJES
          authState.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => const SizedBox.shrink(),
            data: (authResponse) {
              if (authResponse != null) {
                return const Text(
                  'Registrado correctamente.',
                  style: TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                );
              }
              return const Text('Por favor, rellena todos los campos.');
            },
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿Ya tienes una cuenta?'),
              TextButton(
                onPressed: () {
                  // Destruim tota la pila de navegació i afegim la ruta d'inici de sessió.
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.LOGIN,
                    (route) => false,
                  );
                },
                child: const Text(
                  "Inicia sesión",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // WELCOME SECTION (IZQUIERDA)
  // ─────────────────────────────────────────────────────────────
  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            "Crea tu cuenta",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Regístrate para comenzar a gestionar tus gastos,\n"
            "analizar tus ingresos y controlar tu economía familiar\n"
            "de forma simple y rápida.",
            style: TextStyle(fontSize: 20, color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LÓGICA REGISTRO
  // ─────────────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final request = RegisterRequest(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await ref.read(authProvider.notifier).register(request);
    }
  }
}
