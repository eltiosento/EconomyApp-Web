import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/income_dto.dart';
import 'package:economy_app/providers/incomes_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:economy_app/utils/butons_appbar.dart';
import 'package:economy_app/utils/refresh_providers.dart';
import 'package:economy_app/utils/size_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllIncomesScreen extends ConsumerStatefulWidget {
  const AllIncomesScreen({super.key});

  @override
  ConsumerState<AllIncomesScreen> createState() => _AllIncomesScreenState();
}

class _AllIncomesScreenState extends ConsumerState<AllIncomesScreen> {
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

  @override
  Widget build(BuildContext context) {
    final incomeByUserIdState = ref.watch(incomesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de todos los ingresos'),
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
                  ButtonsAppBar('Actualizar datos', onTap: () => refreshProviders(ref)),
                  const SizedBox(width: 20),
                ]
                : [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      refreshProviders(ref);
                    },
                  ),
                ],
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.backgroundColor1, AppColors.backgroundColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child:
              isTablet(context)
                  ? _buildDesktopLayout(incomeByUserIdState)
                  : _buildMobileLayout(incomeByUserIdState),
        ),
      ),
    );
  }

  Column _buildMobileLayout(AsyncValue<List<IncomeDto>> incomeByUserIdState) {
    return Column(
      children: [
        DetailsAllIncomesMobileWidget(),

        // Widget que mostra la llista d'ingressos
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                incomeByUserIdState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error:
                      (err, _) => Center(
                        child: Text(
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
                    return _detailsAllIncomesList(income, paginatedIncome);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Row _buildDesktopLayout(AsyncValue<List<IncomeDto>> incomeByUserIdState) {
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
                    child: DetailsAllIncomesDesckTopWidget(),
                  ),
                ),
              ),
        ),

        // Widget que mostra la llista d'ingressos
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                incomeByUserIdState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error:
                      (err, _) => Center(
                        child: Text(
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
                    return Center(
                      child: SizedBox(
                        width: 1000,
                        child: _detailsAllIncomesList(income, paginatedIncome),
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

  Column _detailsAllIncomesList(List<IncomeDto> income, List<IncomeDto> paginatedIncome) {
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
                style: TextStyle(fontSize: 18, color: AppColors.primaryColor),
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
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                      "Ingreso del ${incomeDto.formattedDate}",
                      style: const TextStyle(
                        color: AppColors.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("- Hecho por: "),
                            Text(
                              incomeDto.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                        Text("- Descripción: ${incomeDto.description}"),
                        Text("- Creado: ${incomeDto.formattedCreatedAt}"),
                        Text("- Última modificación: ${incomeDto.formattedUpdatedAt}"),
                      ],
                    ),
                    trailing: Text(
                      '${incomeDto.amount} €',
                      style: TextStyle(
                        fontSize: isDesktop(context) ? 20 : 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
}

class DetailsAllIncomesMobileWidget extends StatelessWidget {
  const DetailsAllIncomesMobileWidget({super.key});

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
                "Listado de todos los ingresos hechos por todos los usuarios.",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 20),
            Image.asset("assets/icons/total_incomes.png", width: 70, height: 70),
          ],
        ),
      ),
    );
  }
}

class DetailsAllIncomesDesckTopWidget extends StatelessWidget {
  const DetailsAllIncomesDesckTopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Image.asset("assets/icons/total_incomes.png", width: 70, height: 70),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            "Listado de todos los ingresos hechos por todos los usuarios.",
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
