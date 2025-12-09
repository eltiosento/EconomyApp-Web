import 'package:economy_app/routes/app_pages.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MainApp()));
}

// Provant que es puja be al GitHub
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Economy App',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.LOGIN,
      onGenerateRoute: NavigationPages.generateRoute,
      theme: ThemeData(fontFamily: 'Montserrat'),
    );
  }
}
