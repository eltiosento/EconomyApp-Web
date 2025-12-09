import 'package:economy_app/models/income_dto.dart';
import 'package:economy_app/providers/auth_provider.dart';
import 'package:economy_app/providers/dio_provider.dart';
import 'package:economy_app/services/income_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final incomeServiceProvider = Provider<IncomeService>((ref) {
  final dio = ref.watch(dioProvider);
  return IncomeService(dio);
});

final incomesProvider = FutureProvider<List<IncomeDto>>((ref) async {
  final authResponse = ref.watch(authProvider).value;
  if (authResponse == null) return [];

  final service = ref.watch(incomeServiceProvider);
  return await service.getAllIncomes();
});
