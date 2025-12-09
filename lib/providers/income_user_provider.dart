import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/new_income_dto.dart';
import 'package:economy_app/providers/incomes_provider.dart';
import 'package:economy_app/providers/user_dto_provider.dart';
import 'package:economy_app/services/income_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:economy_app/models/income_dto.dart';

final incomeUserProvider = AsyncNotifierProvider<IncomeUserNotifier, List<IncomeDto>>(
  IncomeUserNotifier.new,
);

class IncomeUserNotifier extends AsyncNotifier<List<IncomeDto>> {
  late IncomeService _service;
  late int _userId;
  @override
  Future<List<IncomeDto>> build() async {
    final user = ref.watch(userProvider).value;

    if (user == null) return [];
    _userId = user.id;
    _service = ref.watch(incomeServiceProvider);

    return await _service.getAllIncomesByUserId(_userId);
  }

  Future<void> addIncome({
    required String description,
    required double amount,
    required DateTime incomeDate,
  }) async {
    final newIncomeDto = NewIncomeDto(
      userId: _userId,
      description: description,
      amount: amount,
      incomeDate: incomeDate,
    );
    state = const AsyncLoading();
    try {
      await _service.createIncome(newIncomeDto);
      // Torna a carregar tota la llista després del POST
      final updatedList = await _service.getAllIncomesByUserId(_userId);
      state = AsyncData(updatedList);
    } catch (e, st) {
      if (e is ApiError) {
        state = AsyncError(e, st);
        rethrow; // ⬅️ Això és important per propagar l’error cap a _submitForm
      } else {
        state = AsyncError(ApiError(message: e.toString()), st);
        rethrow;
      }
    }
  }

  Future<void> updateIncome({
    required int incomeId,
    required String description,
    required double amount,
    required DateTime incomeDate,
  }) async {
    final newIncomeDto = NewIncomeDto(
      userId: _userId,
      description: description,
      amount: amount,
      incomeDate: incomeDate,
    );
    state = const AsyncLoading();
    try {
      await _service.updateIncome(incomeId, newIncomeDto);
      // Torna a carregar tota la llista després del PUT per actualitzar l'estat
      // de la llista d'ingressos amb el nou valor.
      final updatedList = await _service.getAllIncomesByUserId(_userId);
      state = AsyncData(updatedList);
    } catch (e, st) {
      if (e is ApiError) {
        state = AsyncError(e, st);
        rethrow; // ⬅️ Això és important per propagar l’error cap a _submitForm
      } else {
        state = AsyncError(ApiError(message: e.toString()), st);
        rethrow;
      }
    }
  }

  Future<void> deleteIncome(int incomeId) async {
    state = const AsyncLoading();
    try {
      await _service.deleteIncome(incomeId);
      // Torna a carregar tota la llista després de la eliminació
      final updatedList = await _service.getAllIncomesByUserId(_userId);
      state = AsyncData(updatedList);
    } catch (e, st) {
      if (e is ApiError) {
        state = AsyncError(e, st);
        rethrow; // ⬅️ Això és important per propagar l’error cap a _submitForm
      } else {
        state = AsyncError(ApiError(message: e.toString()), st);
        rethrow;
      }
    }
  }
}
