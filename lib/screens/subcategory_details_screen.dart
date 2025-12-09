import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/category_summary.dart';
import 'package:economy_app/models/expense_dto.dart';
import 'package:economy_app/providers/balance_global_provider.dart';
import 'package:economy_app/providers/expenses_provider.dart';
import 'package:economy_app/providers/summary_categories_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:economy_app/utils/butons_appbar.dart';
import 'package:economy_app/utils/get_month_name.dart';
import 'package:economy_app/utils/size_screen.dart';
import 'package:economy_app/utils/token_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubcategoryDetailsScreen extends ConsumerStatefulWidget {
  final SummaryCategory summaryCategory;
  final int month;
  final int year;

  const SubcategoryDetailsScreen({
    super.key,
    required this.summaryCategory,
    required this.month,
    required this.year,
  });

  @override
  ConsumerState<SubcategoryDetailsScreen> createState() => _SubcategoryDetailsState();
}

class _SubcategoryDetailsState extends ConsumerState<SubcategoryDetailsScreen> {
  late int selectedMonth;
  late int selectedYear;
  String? role;

  bool _isDescending = true;
  int _currentPage = 0;
  static const int itemsPerPage = 5;

  // Metode per a canviar l'ordre de la llista d'ingressos, toglle vol dir palanca
  void _toggleSortOrder() {
    setState(() {
      _isDescending = !_isDescending;
    });
  }

  void _nextPage(List<ExpenseDto> expenses) {
    if ((_currentPage + 1) * itemsPerPage < expenses.length) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //final now = DateTime.now();
    selectedMonth = widget.month;
    selectedYear = widget.year;
    _loadUserRolFromToken();
  }

  Future<void> _loadUserRolFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? token = prefs.getString('auth_token');
      role = TokenUtils.getRole(token!);
    });
  }

  Future<void> _confirmDelete(int expenseId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // que no se cierre al pulsar fuera
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar borrado'),
          content: const Text(
            '¿Seguro que quieres borrar este gasto?',
            style: TextStyle(fontSize: 17),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(fontSize: 15)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Borrar', style: TextStyle(fontSize: 15)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteExpense(expenseId);
      // Com que els balanç global i del mes depenen del mateix servici, en que invaidem el balanceServiceProvider, automaticament, els porviders depenents de ell també es tornaran a carregar.
      ref.invalidate(balanceServiceProvider);
      // Invalidem el servici de les categories resum, per a no tindre que iterar tots els mesos i anys, i automaticament invalidem els providers fills, que son el summaryCategoriesProvider (el que trobem a la pantalla principal) i el summaryCategorySubcategoriesProvider (el que trobem a la pantalla  on es mostra el pastís i les subcategories).
      ref.invalidate(summaryCategoriesServiceProvider);
    }
  }

  Future<void> _deleteExpense(int expenseId) async {
    try {
      await ref
          .read(
            expenseProvider((
              widget.summaryCategory.id,
              selectedMonth,
              selectedYear,
            )).notifier,
          )
          .deleteExpense(expenseId: expenseId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gasto borrado correctamente.'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    } catch (e) {
      final message = e is ApiError ? e.message : 'Error inesperado';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al borrar: $message'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesState = ref.watch(
      expenseProvider((widget.summaryCategory.id, selectedMonth, selectedYear)),
    );

    return Scaffold(
      floatingActionButton:
          role == 'ADMIN' || role == 'SUPERADMIN'
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.NEW_EDIT_EXPENSE,
                    arguments: {'subCategoryId': widget.summaryCategory.id},
                  );
                },
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              )
              : SizedBox.shrink(),
      appBar: AppBar(
        title: Text(widget.summaryCategory.categoryName),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions:
            isDesktop(context)
                ? [
                  ButtonsAppBar(
                    'Inicio',
                    onTap:
                        () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.HOME,
                          (route) => false,
                        ),
                  ),
                  const SizedBox(width: 20),
                  ButtonsAppBar(
                    'Actualizar datos',
                    onTap: () => ref.invalidate(expenseServiceProvider),
                  ),
                  const SizedBox(width: 20),
                ]
                : [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.home),
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.HOME,
                            (route) => false,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          ref.invalidate(expenseServiceProvider);
                        },
                      ),
                    ],
                  ),
                ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.backgroundColor1, AppColors.backgroundColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            isTablet(context)
                ? _buildDescktopLayout(expensesState)
                : _buildMobileLayout(expensesState),
      ),
    );
  }

  Column _buildMobileLayout(AsyncValue<List<ExpenseDto>> expensesState) {
    return Column(
      children: [
        DetailsSubcategoryMobileWidget(widget: widget),

        // WIDGETS ON MOSTREM ELS MESOS I L'ANY
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _monthYearSelector(),
                const SizedBox(height: 20),
                //expensesState.when() s'executa per gestionar els diferents estats (loading, error, data).
                expensesState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) {
                    /*
                    final message =
                        error is ApiError
                            ? error.message
                            : "Se ha producido un error inesperado. Intentalo más tarde.";
                            */
                    return Center(
                      child: Text(
                        //'Error: $message',
                        'No hay datos',
                        style: const TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    );
                  },
                  data: (expenses) {
                    if (_isDescending) {
                      expenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
                    } else {
                      expenses.sort((a, b) => a.expenseDate.compareTo(b.expenseDate));
                    }

                    final startIndex = _currentPage * itemsPerPage;
                    final endIndex = startIndex + itemsPerPage;
                    final paginatedExpense = expenses.sublist(
                      startIndex,
                      endIndex > expenses.length ? expenses.length : endIndex,
                    );

                    if (expenses.isEmpty) {
                      return const Center(
                        child: Text(
                          'No s\'han trobat despeses',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      );
                    }
                    return _detailsExpensesList(expenses, paginatedExpense);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Row _buildDescktopLayout(AsyncValue<List<ExpenseDto>> expensesState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder:
              (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.65),
                      border: Border(
                        right: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                    ),
                    child: DetailsSubcategoryDesktopWidget(widget: widget),
                  ),
                ),
              ),
        ),

        // WIDGETS ON MOSTREM ELS MESOS I L'ANY
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _monthYearSelector(),
                const SizedBox(height: 20),
                //expensesState.when() s'executa per gestionar els diferents estats (loading, error, data).
                expensesState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) {
                    /*
                    final message =
                        error is ApiError
                            ? error.message
                            : "Se ha producido un error inesperado. Intentalo más tarde.";
                            */
                    return Center(
                      child: Text(
                        //'Error: $message',
                        'No hay datos',
                        style: const TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    );
                  },
                  data: (expenses) {
                    if (_isDescending) {
                      expenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
                    } else {
                      expenses.sort((a, b) => a.expenseDate.compareTo(b.expenseDate));
                    }

                    final startIndex = _currentPage * itemsPerPage;
                    final endIndex = startIndex + itemsPerPage;
                    final paginatedExpense = expenses.sublist(
                      startIndex,
                      endIndex > expenses.length ? expenses.length : endIndex,
                    );

                    if (expenses.isEmpty) {
                      return const Center(
                        child: Text(
                          'No se han encontrado gastos',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      );
                    }
                    return Center(
                      child: SizedBox(
                        width: 1000,
                        child: _detailsExpensesList(expenses, paginatedExpense),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column _detailsExpensesList(
    List<ExpenseDto> expenses,
    List<ExpenseDto> paginatedExpense,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Card(
            color: AppColors.secondaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  color: Colors.white,
                  icon: Icon(_isDescending ? Icons.arrow_downward : Icons.arrow_upward),
                  onPressed: _toggleSortOrder,
                  tooltip: "Ordenar",
                ),
                Row(
                  children: [
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousPage,
                    ),
                    Text(
                      "Página ${_currentPage + 1}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      color: Colors.white,
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _nextPage(expenses),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: paginatedExpense.length,
            itemBuilder: (context, index) {
              final expense = paginatedExpense[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: 5.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.formattedDate,
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        expense.description,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${expense.amount} €',
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              widget.summaryCategory.isSaving
                                  ? Colors.green[700]
                                  : Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (role == 'ADMIN' || role == 'SUPERADMIN')
                        Row(
                          children: [
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible:
                                      false, // que no se cierre al pulsar fuera
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(
                                        widget.summaryCategory.isSaving
                                            ? 'Detalles del ingreso'
                                            : 'Detalles del gasto',
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Descripción: ${expense.description}'),
                                          Text('Cantidad: ${expense.amount} €'),
                                          widget.summaryCategory.isSaving
                                              ? Text(
                                                'Fecha del ingreso: ${expense.formattedDate}',
                                              )
                                              : Text(
                                                'Fecha del gasto: ${expense.formattedDate}',
                                              ),
                                          Text('Creado por: ${expense.userName}'),
                                          Text(
                                            'Creado el: ${expense.formattedCreatedAt}',
                                          ),
                                          Text(
                                            'Última modificación: ${expense.formattedUpdatedAt}',
                                          ),
                                        ],
                                      ),

                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor: AppColors.secondaryColor,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text(
                                            'Cerrar',
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.info_outline,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.secondaryColor,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.NEW_EDIT_EXPENSE,
                                  arguments: {
                                    'expenseDto': expense,
                                    'subCategoryId': widget.summaryCategory.id,
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _confirmDelete(expense.id);
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Row _monthYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton<int>(
          value: selectedMonth,
          items: List.generate(12, (index) {
            final month = index + 1;
            return DropdownMenuItem(value: month, child: Text(getMonthName(month)));
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedMonth = value;
              });
            }
          },
        ),
        const SizedBox(width: 20),
        DropdownButton<int>(
          value: selectedYear,
          items: List.generate(3, (index) {
            final year = DateTime.now().year + index;
            return DropdownMenuItem(value: year, child: Text('$year'));
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedYear = value;
              });
            }
          },
        ),
      ],
    );
  }
}

class DetailsSubcategoryMobileWidget extends StatelessWidget {
  const DetailsSubcategoryMobileWidget({super.key, required this.widget});

  final SubcategoryDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.summaryCategory.description,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 20),
            Image.asset(widget.summaryCategory.iconPath, width: 70, height: 70),
          ],
        ),
      ),
    );
  }
}

class DetailsSubcategoryDesktopWidget extends StatelessWidget {
  const DetailsSubcategoryDesktopWidget({super.key, required this.widget});

  final SubcategoryDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Image.asset(widget.summaryCategory.iconPath, width: 90, height: 90),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            widget.summaryCategory.description,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
