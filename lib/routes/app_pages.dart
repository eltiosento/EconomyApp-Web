import 'package:economy_app/routes/app_routes.dart';
import 'package:economy_app/screens/all_incomes_screen.dart';
import 'package:economy_app/screens/edit_user_password_screen.dart';
import 'package:economy_app/screens/edit_user_profile_screen.dart';
import 'package:economy_app/screens/edit_username_screen.dart';
import 'package:economy_app/screens/home_screen.dart';
import 'package:economy_app/screens/icon_selected_screen.dart';
import 'package:economy_app/screens/info_user_screen.dart';
import 'package:economy_app/screens/login_screen.dart';
import 'package:economy_app/screens/new_edit_category_screen.dart';
import 'package:economy_app/screens/new_edit_expense_screen.dart';
import 'package:economy_app/screens/new_edit_income_screen.dart';
import 'package:economy_app/screens/register_screen.dart';
import 'package:economy_app/screens/list_subcategories_screen.dart';
import 'package:economy_app/screens/subcategory_details_screen.dart';
import 'package:flutter/material.dart';

class NavigationPages {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.LOGIN:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.REGISTER:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.HOME:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case AppRoutes.NEW_EDIT_INCOME:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => NewAndEditIncomeScreen(incomeDto: args['incomeDto']),
          );
        }
        return MaterialPageRoute(builder: (_) => const NewAndEditIncomeScreen());

      case AppRoutes.NEW_EDIT_EXPENSE:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder:
                (_) => NewAndEditExpenseScreen(
                  expenseDto: args['expenseDto'],
                  subCategoryId: args['subCategoryId'],
                ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => NewAndEditExpenseScreen(subCategoryId: args!['subCategoryId']),
        );

      case AppRoutes.NEW_EDIT_CATEGORY:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null) {
          return MaterialPageRoute(
            builder:
                (_) => NewAndEditCategoryScreen(
                  category: args['category'],
                  parentCategoryId: args['parentCategoryId'],
                ),
          );
        }
        return MaterialPageRoute(builder: (_) => const NewAndEditCategoryScreen());

      case AppRoutes.LIST_SUBCATEGORIES:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder:
              (_) => ListSubcategoriesScreen(
                summaryCategory: args['summaryCategory'],
                month: args['month'],
                year: args['year'],
              ),
        );

      case AppRoutes.SUBCATEGORY_DETAILS:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => SubcategoryDetailsScreen(
                summaryCategory: args['summaryCategory'],
                month: args['month'],
                year: args['year'],
              ),
        );

      case AppRoutes.ICON_SELECTED:
        return MaterialPageRoute(builder: (_) => const IconSelectedScreen());

      case AppRoutes.USER_PROFILE:
        return MaterialPageRoute(builder: (_) => const InfoUserScreen());

      case AppRoutes.EDIT_USER_PROFILE:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditUserProfileScreen(userDto: args['userDto']),
        );

      case AppRoutes.EDIT_USERNAME:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EditUserNameScreen(userName: args['userName']),
        );

      case AppRoutes.EDIT_USER_PASSWORD:
        return MaterialPageRoute(builder: (_) => const EditUserPasswordScreen());

      case AppRoutes.ALL_INCOMES:
        return MaterialPageRoute(builder: (_) => const AllIncomesScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Pàgina no trobada')),
          ),
    );
  }
}
