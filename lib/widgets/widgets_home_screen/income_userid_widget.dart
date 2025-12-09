import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/income_dto.dart';
import 'package:economy_app/providers/balance_global_provider.dart';
import 'package:economy_app/providers/income_user_provider.dart';
import 'package:economy_app/providers/incomes_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncomeByUseridWidget extends ConsumerStatefulWidget {
  final String role;
  const IncomeByUseridWidget({super.key, required this.role});

  @override
  ConsumerState<IncomeByUseridWidget> createState() => _IncomeByUseridWidgetState();
}

class _IncomeByUseridWidgetState extends ConsumerState<IncomeByUseridWidget> {
  bool _isDescending = true;
  int _currentPage = 0;
  static const int itemsPerPage = 5;

  // Metode per a canviar l'ordre de la llista d'ingressos, toglle vol dir palanca
  void _toggleSortOrder() {
    setState(() {
      _isDescending = !_isDescending;
    });
  }

  void _nextPage(List<IncomeDto> income) {
    if ((_currentPage + 1) * itemsPerPage < income.length) {
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

  Future<void> _confirmDelete(int incomeId, int month, int year) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar borrado'),
          content: const Text(
            '¿Seguro que quieres borrar este Ingreso?',
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
      await _deleteIncome(incomeId);
      ref.invalidate(balanceServiceProvider);
      ref.invalidate(incomeServiceProvider);
    }
  }

  Future<void> _deleteIncome(int incomeId) async {
    try {
      await ref.read(incomeUserProvider.notifier).deleteIncome(incomeId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingreso borrado correctamente.'),
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
    final incomeByUserIdState = ref.watch(incomeUserProvider);
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      'Resumen de ingresos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    subtitle: Text(
                      'Listado de todos mis ingresos.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: AppColors.secondaryColor),
                    ),
                    trailing: Image.asset(
                      'assets/icons/total_incomes.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
              ),
              incomeByUserIdState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (err, _) => Center(
                      child: Text(
                        //'No hay datos. ${(err as ApiError).message}'
                        'No hay datos.',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                data: (income) {
                  if (_isDescending) {
                    income.sort((a, b) => b.incomeDate.compareTo(a.incomeDate));
                  } else {
                    income.sort((a, b) => a.incomeDate.compareTo(b.incomeDate));
                  }

                  final startIndex = _currentPage * itemsPerPage;
                  final endIndex = startIndex + itemsPerPage;
                  final paginatedIncome = income.sublist(
                    startIndex,
                    endIndex > income.length ? income.length : endIndex,
                  );
                  // Posem un stac per poder afegir el botó flotant
                  // de crear un nou ingrés a la pantalla
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
                                icon: Icon(
                                  _isDescending
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                ),
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
                                    onPressed: () => _nextPage(income),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      income.isEmpty
                          ? const Center(
                            child: Text(
                              'Todavía no hay ingresos registrados.',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          )
                          : ListView.builder(
                            physics:
                                const NeverScrollableScrollPhysics(), // Desactivem el scroll perque qui crida a aquest widget ja te un scroll activat
                            shrinkWrap: true,
                            itemCount: paginatedIncome.length,
                            itemBuilder: (context, index) {
                              final IncomeDto incomeDto = paginatedIncome[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 25,
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: ListTile(
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Ingreso del ${incomeDto.formattedDate}",
                                          style: const TextStyle(
                                            color: AppColors.secondaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          incomeDto.description,
                                          style: const TextStyle(
                                            color: AppColors.secondaryColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      '${incomeDto.amount} €',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    trailing:
                                        widget.role == "ADMIN" ||
                                                widget.role == "SUPERADMIN"
                                            ? PopupMenuButton<String>(
                                              color: AppColors.primaryColor,
                                              onSelected: (value) async {
                                                if (value == 'edit') {
                                                  Navigator.pushNamed(
                                                    context,
                                                    AppRoutes.NEW_EDIT_INCOME,
                                                    arguments: {'incomeDto': incomeDto},
                                                  );
                                                } else if (value == 'delete') {
                                                  await _confirmDelete(
                                                    incomeDto.id,
                                                    incomeDto.incomeDate.month,
                                                    incomeDto.incomeDate.year,
                                                  );
                                                }
                                              },
                                              itemBuilder:
                                                  (context) => [
                                                    const PopupMenuItem(
                                                      value: 'edit',
                                                      child: ListTile(
                                                        title: Text(
                                                          'Editar',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        leading: Icon(
                                                          Icons.edit,
                                                          color:
                                                              AppColors.backgroundColor2,
                                                        ),
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'delete',
                                                      child: ListTile(
                                                        title: Text(
                                                          'Borrar',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        leading: Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                            )
                                            : SizedBox(),
                                  ),
                                ),
                              );
                            },
                          ),
                      const SizedBox(height: 50),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        widget.role == "ADMIN" || widget.role == "SUPERADMIN"
            ? Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.NEW_EDIT_INCOME);
                },
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              ),
            )
            : SizedBox.shrink(),
      ],
    );
  }
}
