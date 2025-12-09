import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/providers/auth_provider.dart';
import 'package:economy_app/providers/user_dto_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawerApp extends StatelessWidget {
  const DrawerApp({super.key, required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primaryColor),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            title: const Text('Perfil de usuario'),
            onTap: () {
              Navigator.of(context).pop(); // Tancar el drawer abans de navegar
              Navigator.pushNamed(context, AppRoutes.USER_PROFILE);
            },
          ),
          ListTile(
            title: const Text('Todos los ingresos'),
            onTap: () {
              Navigator.of(context).pop(); // Tancar el drawer abans de navegar
              Navigator.pushNamed(context, AppRoutes.ALL_INCOMES);
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              // Actualitzem el userProvider perque com que hem tancat sessió, hem de refrescar l'estat de l'usuari.
              // Això es fa perque el provider d'usuari depen de l'authProvider, i si aquest canvia, el d'usuari també ha de canviar.
              ref.invalidate(userProvider);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.LOGIN,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
