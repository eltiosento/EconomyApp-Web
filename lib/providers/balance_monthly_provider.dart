import 'package:economy_app/models/balance.dart';
import 'package:economy_app/providers/auth_provider.dart';
import 'package:economy_app/providers/balance_global_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// El balanceServiceProvider que tenim definit a balance_global_provider.dart
// Fem us del FutureProvider.family perque el mes i l'any son variables que es poden passar com a arguments
// i no es poden definir com a constants. Fem servir un tuple per passar mes i any com a arguments.
final balancePerMonthProvider = FutureProvider.family<Balance?, (int, int)>((
  ref,
  tuple,
) async {
  final (month, year) = tuple;

  final authResponse = ref.watch(authProvider).value;
  if (authResponse == null) return null;

  final service = ref.watch(balanceServiceProvider);
  return await service.getSummaryMonthlyBalance(month, year);
});
