import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/category_summary.dart';
import 'package:economy_app/models/summary_category_subcategories.dart';
import 'package:economy_app/providers/providers_utils_providers.dart';
import 'package:economy_app/providers/summary_categories_provider.dart';
import 'package:economy_app/providers/summary_category_subcategories_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:economy_app/utils/butons_appbar.dart';
import 'package:economy_app/utils/get_month_name.dart';
import 'package:economy_app/utils/list_colors_pie_chart.dart';
import 'package:economy_app/utils/size_screen.dart';
import 'package:economy_app/utils/token_utils.dart';
import 'package:economy_app/widgets/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListSubcategoriesScreen extends ConsumerStatefulWidget {
  final SummaryCategory summaryCategory;
  final int month;
  final int year;
  const ListSubcategoriesScreen({
    super.key,
    required this.summaryCategory,
    required this.month,
    required this.year,
  });

  @override
  ConsumerState<ListSubcategoriesScreen> createState() => _SubcategoryDetailsState();
}

class _SubcategoryDetailsState extends ConsumerState<ListSubcategoriesScreen> {
  late int selectedMonth;
  late int selectedYear;
  late int indexSubcategory;
  String? role;
  // 🔹 Cambio: Map para almacenar el estado de cada Switch
  Map<int, bool> showMonthlyMap = {};

  @override
  void initState() {
    super.initState();
    //final now = DateTime.now();
    selectedMonth = widget.month;
    selectedYear = widget.year;
    indexSubcategory = -1;
    _loadUserRolFromToken();
  }

  Future<void> _loadUserRolFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? token = prefs.getString('auth_token');
      role = TokenUtils.getRole(token!);
    });
  }

  Future<void> _confirmDelete(int categoryId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // que no se cierre al pulsar fuera
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar borrado'),
          content: const Text(
            '¿Seguro que quieres borrar esta categoría?',
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
      await _deleteCategory(categoryId);
      // Invalidem el servici de les categories resum, per a no tindre que iterar tots els mesos i anys, i automaticament invalidem els providers fills, que son el summaryCategoriesProvider (el que trobem a la pantalla principal) i el summaryCategorySubcategoriesProvider (el que trobem a la pantalla  on es mostra el pastís i les subcategories).
      ref.invalidate(summaryCategoriesServiceProvider);
      ref.invalidate(categoriesServiceProvider);
    }
  }

  Future<void> _deleteCategory(int categoryId) async {
    try {
      await ref
          .read(
            summaryCategorySubcategoriesProvider((
              widget.summaryCategory.id,
              selectedMonth,
              selectedYear,
            )).notifier,
          )
          .deleteCategory(categoryId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categoria borrada correctamente.'),
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
    final summaryCategorySubcategoriesState = ref.watch(
      summaryCategorySubcategoriesProvider((
        widget.summaryCategory.id,
        selectedMonth,
        selectedYear,
      )),
    );

    return Scaffold(
      floatingActionButton:
          role == 'ADMIN' || role == 'SUPERADMIN'
              ? FloatingActionButton(
                onPressed: () {
                  ref.invalidate(selectedSubcategoryIconProvider);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.NEW_EDIT_CATEGORY,
                    arguments: {'parentCategoryId': widget.summaryCategory.id},
                  );
                },
                tooltip: 'Añadir subcategoría',
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
              )
              : SizedBox(),
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
                    onTap:
                        () => {
                          ref.invalidate(summaryCategoriesServiceProvider),
                          ref.invalidate(categoriesServiceProvider),
                        },
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
                          ref.invalidate(summaryCategoriesServiceProvider);
                          ref.invalidate(categoriesServiceProvider);
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
                ? _buildDesktopLayout(summaryCategorySubcategoriesState)
                : _buildMobileLayout(summaryCategorySubcategoriesState),
      ),
    );
  }

  Column _buildMobileLayout(
    AsyncValue<SummaryCategorySubcategories> summaryCategorySubcategoriesState,
  ) {
    return Column(
      children: [
        // WIDGET AMB LA DESCRIPCIO I ICONA DE LA SUBCATEGORIA
        DetailsCategoryMobileWidget(widget: widget),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // WIDGETS ON MOSTREM ELS MESOS I L'ANY
                _monthYearSelectors(),
                // LLISTAT DE SUBCATEGORIES
                summaryCategorySubcategoriesState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) {
                    /*
                        final message =
                            error is ApiError ? error.message : error.toString();*/
                    return Center(
                      child: Text(
                        //'Error: $message',
                        'No hay datos',
                        style: const TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    );
                  },
                  data: (categoryAndSubcategories) {
                    final totalExpenses = categoryAndSubcategories.monthlyExpense;
                    final listSubcategories = categoryAndSubcategories.subcategories;

                    if (listSubcategories.isEmpty) {
                      return const Center(
                        child: Text(
                          'No se han encontrado subcategorías.',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Card(
                            color: AppColors.secondaryColor.withValues(alpha: 0.9),
                            elevation: 7,
                            child: SizedBox(
                              height: 290,
                              width: 290,
                              child:
                                  (totalExpenses != 0 && listSubcategories.isNotEmpty)
                                      ? MyPieChart(
                                        data: categoryAndSubcategories,
                                        highlightIndex: indexSubcategory,
                                      )
                                      : Icon(
                                        Icons.pie_chart,
                                        size: 200,
                                        color: AppColors.primaryColor,
                                      ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20, bottom: 65),
                          child: _subcategoriesGrid(listSubcategories),
                        ),
                      ],
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

  Row _buildDesktopLayout(
    AsyncValue<SummaryCategorySubcategories> summaryCategorySubcategoriesState,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contenidor per al costat el grafica de pastis i la descripcio
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
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
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      // WIDGET AMB LA DESCRIPCIO I ICONA DE LA SUBCATEGORIA
                      DetailsCategoryDesktopWidget(widget: widget),

                      summaryCategorySubcategoriesState.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) {
                          /*
                                  final message =
                                      error is ApiError ? error.message : error.toString();*/
                          return Center(
                            child: Text(
                              //'Error: $message',
                              'No hay datos',
                              style: const TextStyle(color: Colors.red, fontSize: 20),
                            ),
                          );
                        },
                        data: (categoryAndSubcategories) {
                          final totalExpenses = categoryAndSubcategories.monthlyExpense;
                          final listSubcategories =
                              categoryAndSubcategories.subcategories;
                          return SizedBox(
                            height: 400,
                            width: 300,
                            child:
                                (totalExpenses != 0 && listSubcategories.isNotEmpty)
                                    ? MyPieChart(
                                      data: categoryAndSubcategories,
                                      highlightIndex: indexSubcategory,
                                    )
                                    : Icon(
                                      Icons.pie_chart,
                                      size: 200,
                                      color: AppColors.primaryColor,
                                    ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // WIDGETS ON MOSTREM ELS MESOS I L'ANY
                _monthYearSelectors(),
                // LLISTAT DE SUBCATEGORIES
                summaryCategorySubcategoriesState.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) {
                    /*
                        final message =
                            error is ApiError ? error.message : error.toString();*/
                    return Center(
                      child: Text(
                        //'Error: $message',
                        'No hay datos',
                        style: const TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    );
                  },
                  data: (categoryAndSubcategories) {
                    final listSubcategories = categoryAndSubcategories.subcategories;

                    if (listSubcategories.isEmpty) {
                      return const Center(
                        child: Text(
                          'No se han encontrado subcategorías.',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20, right: 20, bottom: 65),
                          child: _subcategoriesGrid(listSubcategories),
                        ),
                      ],
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

  LayoutBuilder _subcategoriesGrid(List<SummaryCategory> listSubcategories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns = 1;

        if (constraints.maxWidth >= 1100) {
          columns = 3;
        } else if (constraints.maxWidth >= 750) {
          columns = 2;
        }

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: listSubcategories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10, //--> espacio entre columnas
            mainAxisSpacing: 5, // --> espacio entre filas
            mainAxisExtent: 270, // --> altura de cada card
          ),
          itemBuilder: (context, index) {
            final subcategory = listSubcategories[index];

            return SubcategoryCard(
              subcategory: subcategory,
              index: index,
              parentCategoryId: widget.summaryCategory.id,
              selectedMonth: selectedMonth,
              selectedYear: selectedYear,
              role: role,
              onDelete: () {
                _confirmDelete(subcategory.id);
              },
              onEdit: () {
                // Posem al provide de la icona la icona seleccionada per poder cambirala desde la pantalla de edició.
                ref.read(selectedSubcategoryIconProvider.notifier).state =
                    subcategory.iconPath;
                Navigator.pushNamed(
                  context,
                  AppRoutes.NEW_EDIT_CATEGORY,
                  arguments: {
                    'category': subcategory,
                    'parentCategoryId': widget.summaryCategory.id,
                  },
                );
              },
              onDetails: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.SUBCATEGORY_DETAILS,
                  arguments: {
                    'parentCategoryId': widget.summaryCategory.id,
                    'summaryCategory': subcategory,
                    'month': selectedMonth,
                    'year': selectedYear,
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _monthYearSelectors() {
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
          items: List.generate(6, (index) {
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

class DetailsCategoryMobileWidget extends StatelessWidget {
  const DetailsCategoryMobileWidget({super.key, required this.widget});

  final ListSubcategoriesScreen widget;

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

class DetailsCategoryDesktopWidget extends StatelessWidget {
  final ListSubcategoriesScreen widget;

  const DetailsCategoryDesktopWidget({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Image.asset(widget.summaryCategory.iconPath, width: 90, height: 90),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            widget.summaryCategory.description,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class SubcategoryCard extends StatefulWidget {
  final SummaryCategory subcategory;
  final int index;
  final int parentCategoryId;
  final int selectedMonth;
  final int selectedYear;
  final String? role;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onDetails;

  const SubcategoryCard({
    super.key,
    required this.subcategory,
    required this.index,
    required this.parentCategoryId,
    required this.selectedMonth,
    required this.selectedYear,
    required this.role,
    required this.onDelete,
    required this.onEdit,
    required this.onDetails,
  });

  @override
  State<SubcategoryCard> createState() => _SubcategoryCardState();
}

class _SubcategoryCardState extends State<SubcategoryCard> {
  String selectedMode = "Mensual"; // Default

  @override
  Widget build(BuildContext context) {
    final subcategory = widget.subcategory;

    // 🔹 Calcular valores según opción seleccionada
    double expense;
    double progress;

    switch (selectedMode) {
      case "Total":
        expense = subcategory.totalExpenses;
        progress = subcategory.goalTotalProgress / 100;
        break;
      case "Anual":
        expense = subcategory.yearlyExpense;
        progress = subcategory.goalYearlyProgress / 100;
        break;
      case 'Mensual':
      default: // Mensual
        expense = subcategory.monthlyExpense;
        progress = subcategory.goalMonthlyProgress / 100;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Cabecera con título y SegmentedButton
            Text(
              subcategory.categoryName,
              style: const TextStyle(
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Total', label: Text('Total')),
                  ButtonSegment(value: 'Mensual', label: Text('Mensual')),
                  ButtonSegment(value: 'Anual', label: Text('Anual')),
                ],
                selected: {selectedMode},
                onSelectionChanged: (newSelection) {
                  setState(() => selectedMode = newSelection.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Contenido
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: getColors()[widget.index % getColors().length],
                  child: Image.asset(subcategory.iconPath, width: 36, height: 36),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child:
                            subcategory.goal == null
                                ? const Text(
                                  'Sin objetivo',
                                  style: TextStyle(fontSize: 12),
                                )
                                : expense >= subcategory.goal!
                                ? const Text(
                                  '¡Objetivo alcanzado!',
                                  style: TextStyle(
                                    color: AppColors.successColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                )
                                : Text(
                                  '${(subcategory.goal! - expense).toStringAsFixed(2)} € restantes',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 10),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade300,
                          color: getColors()[widget.index % getColors().length],
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${expense.toStringAsFixed(2)} €",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${subcategory.goal ?? 0} €",
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            // 🔹 Botones de acciones
            Row(
              children: [
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: widget.onDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Ver detalles', style: TextStyle(fontSize: 15)),
                  ),
                ),
                const Spacer(),
                if (widget.role == 'ADMIN' || widget.role == 'SUPERADMIN')
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.secondaryColor),
                    tooltip: 'Editar categoría',
                    onPressed: widget.onEdit,
                  ),
                if (widget.role == 'ADMIN' || widget.role == 'SUPERADMIN')
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Borrar categoría',
                    onPressed: widget.onDelete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
