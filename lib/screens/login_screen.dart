import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/auth_response.dart';
import 'package:economy_app/models/login_request.dart';
import 'package:economy_app/providers/auth_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:economy_app/utils/token_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listener del login
    // 1) Escoltem l'estat d'autenticació per detectar canvis. Si l'usuari inicia sessió correctament,
    // es neteja l'estat i es redirigeix a la pantalla d'inici.
    // Si hi ha un error, es mostra un missatge d'error.

    ref.listen<AsyncValue<AuthResponse?>>(authProvider, (previous, next) {
      final loginSuccess = previous is AsyncLoading && next is AsyncData;

      if (loginSuccess && next.value != null) {
        // Elimina totes les rutes anteriors de la pila de navegació i afegeix la ruta d'inici.
        // Això és útil per evitar que l'usuari pugui tornar enrere a la pantalla d'inici de sessió després d'haver iniciat sessió correctament.
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.HOME, (route) => false);
      }

      final isLoginFailed = previous is AsyncLoading && next is AsyncError;
      if (isLoginFailed) {
        final msg = (next.error as ApiError).message;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

        // Ara netegem l'error posant l'estat a null.
        // Com que el logout a part de llevar el token, també neteja l'estat d'autenticació, no caldrà fer-ho manualment.
        // Si no es neteja l'estat, el missatge d'error es mostrarà cada vegada que es torni a la pantalla d'inici de sessió.
        // logout deixa el estat a null --> state = const AsyncData(null);
        ref.read(authProvider.notifier).logout();
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
  // DESKTOP / TABLET WIDE
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
                  // -------- COLUMNA IZQUIERDA --------
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: _buildWelcomeSection(),
                      ),
                    ),
                  ),

                  // -------- COLUMNA DERECHA (FORMULARIO) --------
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: _loginCard(authState),
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
  // MÓVIL
  // ─────────────────────────────────────────────────────────────
  Widget _buildMobileLayout(AsyncValue<AuthResponse?> authState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.only(top: 80, left: 25, right: 25, bottom: 25),
              child: Center(child: _loginCard(authState)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Bienvenido a \nEconomy App",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "Gestiona tus gastos, controla tus ingresos y obtén una visión clara "
            "de tu economía familiar. Todo desde una plataforma simple, segura "
            "y accesible desde cualquier dispositivo.",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 40),

          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.white.withValues(alpha: 0.9),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                "Control financiero al instante",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.white.withValues(alpha: 0.9),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                "Datos seguros en la nube",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.white.withValues(alpha: 0.9),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                "Acceso desde móvil y web",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),

          const SizedBox(height: 50),

          Text(
            "Comienza a tomar el control hoy.",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TARJETA DEL LOGIN (COMPARTIDA)
  // ─────────────────────────────────────────────────────────────
  Widget _loginCard(AsyncValue<AuthResponse?> authState) {
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
          Image.asset('assets/images/img_login.png', height: 250, width: 250),
          Text(
            'Iniciar Sesión',
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  validator: (v) => v!.isEmpty ? "Introduce el nombre de usuario." : null,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _passwordController,
                  validator: (v) => v!.isEmpty ? 'Introduce la contraseña.' : null,
                  obscureText: _isObscure,
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

          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
              ),
              child: const Text('Login', style: TextStyle(fontSize: 15)),
            ),
          ),

          const SizedBox(height: 20),

          authState.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) => const SizedBox.shrink(),
            data: (authResponse) {
              if (authResponse != null) {
                final username = TokenUtils.getUsername(authResponse.token);
                return Text(
                  'Bienvenido/a $username',
                  style: const TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                );
              }
              return const Text('Por favor, inicia sesión.');
            },
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("¿No tienes cuenta?"),
              TextButton(
                onPressed: () {
                  // Fem un pushReplacementNamed per que si ferem Navigator.pushNamed(context, AppRoutes.REGISTER), el widget del LoginScreen no es destrueix, sinó que queda “sota” el de registre a la pila de rutes. Com que el teu ref.listen(authProvider…) està dins el LoginScreen, segueix escoltant els canvis del authProvider encara que no el vegis, així que qualsevol error o èxit disparat en la pantalla de registre també farà entrar aquest listen, i el missatge d'error es voria dos voltes. Per això fem un pushReplacementNamed, per que el LoginScreen es destrueix i no queda a la pila de rutes. Així no es dispara el listen del LoginScreen quan es fa login o registre.
                  // Reemplaça la ruta actual amb la ruta de registre.
                  Navigator.pushReplacementNamed(context, AppRoutes.REGISTER);
                },
                child: const Text(
                  "Registrarse",
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
  // LÓGICA LOGIN
  // ─────────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final loginRequest = LoginRequest(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await ref.read(authProvider.notifier).login(loginRequest);
    }
  }
}
