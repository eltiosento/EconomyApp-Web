import 'package:economy_app/providers/balance_global_provider.dart';
import 'package:economy_app/providers/expenses_provider.dart';

import 'package:economy_app/providers/incomes_provider.dart';
import 'package:economy_app/providers/providers_utils_providers.dart';
import 'package:economy_app/providers/summary_categories_provider.dart';
import 'package:economy_app/providers/user_dto_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void refreshProviders(WidgetRef ref) {
  ref.invalidate(balanceServiceProvider);
  ref.invalidate(summaryCategoriesServiceProvider);
  ref.invalidate(userProvider);
  ref.invalidate(incomeServiceProvider);
  ref.invalidate(selectedCategoryHomePieChartProvider);
  ref.invalidate(expenseServiceProvider);
  ref.invalidate(categoriesServiceProvider);
}
