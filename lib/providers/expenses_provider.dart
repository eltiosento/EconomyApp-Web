import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/expense_dto.dart';
import 'package:economy_app/models/new_expense_dto.dart';
import 'package:economy_app/models/transfer_request_dto.dart';
import 'package:economy_app/providers/dio_provider.dart';
import 'package:economy_app/providers/user_dto_provider.dart';
import 'package:economy_app/services/expense_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  final dio = ref.watch(dioProvider);
  return ExpenseService(dio);
});

final expenseProvider =
    AsyncNotifierProvider.family<ExpenseNotifier, List<ExpenseDto>, (int, int, int)>(
      ExpenseNotifier.new,
    );

// Com que s'exten de FamilyAsyncNotifier, el buid es onstruirà amb els paràmetres que li passem quan l'observem passanli la tupla (int, int, int) amb el pramatres requerits.
class ExpenseNotifier extends FamilyAsyncNotifier<List<ExpenseDto>, (int, int, int)> {
  late ExpenseService _service;
  late int _userId;
  late int _subcategoryId;
  late int _month;
  late int _year;

  @override
  Future<List<ExpenseDto>> build((int subcategoryId, int month, int year) params) async {
    // Obtenim l'usuari loguejat per obtenir el seu ID
    // i el guardem a la variable _userId
    // Ho tractem aquí per evitar que el provider d'usuari
    // s'actualitzi cada vegada que es fa un canvi d'estat i de paso si no hi han dades del usuari tornem una llista buida
    // i no un error.
    final user = ref.watch(userProvider).value;
    if (user == null) {
      return [];
    }
    _userId = user.id;
    _service = ref.watch(expenseServiceProvider);
    final (subCatId, m, y) = params;
    _subcategoryId = subCatId;
    _month = m;
    _year = y;
    return _service.getAllExpensesBySubcategoryIdMontYear(_subcategoryId, _month, _year);
  }

  Future<void> addExpense({
    required String description,
    required double amount,
    required DateTime expenseDate,
  }) async {
    final newExpense = NewExpenseDto(
      userId: _userId,
      subcategoryId: _subcategoryId,
      description: description,
      amount: amount,
      expenseDate: expenseDate,
    );

    state = const AsyncLoading();
    try {
      await _service.createExpense(newExpense);

      // Torna a carregar tota la llista després del POST per actualitzar l'estat
      // de la llista de despeses amb el nou valor.
      final updatedList = await _service.getAllExpensesBySubcategoryIdMontYear(
        _subcategoryId,
        newExpense.expenseDate.month,
        newExpense.expenseDate.year,
      );
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

  Future<void> savingsToExpense({
    required int fromCategoryId,

    required String description,
    required double amount,
    required DateTime date,
  }) async {
    final transferRequest = TransferRequestDto(
      userId: _userId,
      fromCategoryId: fromCategoryId,
      toCategoryId: _subcategoryId,
      description: description,
      amount: amount,
      date: date,
    );

    state = const AsyncLoading();
    try {
      await _service.transferSavingsToExpenses(transferRequest);

      // Torna a carregar tota la llista després del POST per actualitzar l'estat
      // de la llista de despeses amb el nou valor.
      final updatedList = await _service.getAllExpensesBySubcategoryIdMontYear(
        _subcategoryId,
        date.month,
        date.year,
      );
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

  Future<void> updateExpense({
    required int expenseId,
    required String description,
    required double amount,
    required DateTime expenseDate,
  }) async {
    final newExpense = NewExpenseDto(
      userId: _userId,
      subcategoryId: _subcategoryId,
      description: description,
      amount: amount,
      expenseDate: expenseDate,
    );

    state = const AsyncLoading();
    try {
      await _service.updateExpense(expenseId, newExpense);

      // Torna a carregar tota la llista després del POST per actualitzar l'estat
      // de la llista de despeses amb el nou valor.
      final updatedList = await _service.getAllExpensesBySubcategoryIdMontYear(
        _subcategoryId,
        newExpense.expenseDate.month,
        newExpense.expenseDate.year,
      );
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

  Future<void> deleteExpense({required int expenseId}) async {
    state = const AsyncLoading();
    try {
      await _service.deleteExpense(expenseId);

      final updatedList = await _service.getAllExpensesBySubcategoryIdMontYear(
        _subcategoryId,
        _month,
        _year,
      );
      state = AsyncData(updatedList);
    } catch (e, st) {
      if (e is ApiError) {
        state = AsyncError(e, st);
        rethrow; // ⬅️ Això és important per propagar l’error
      } else {
        state = AsyncError(ApiError(message: e.toString()), st);
        rethrow;
      }
    }
  }
}
