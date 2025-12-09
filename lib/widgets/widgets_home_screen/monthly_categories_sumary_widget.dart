import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/category_summary.dart';
import 'package:economy_app/providers/providers_utils_providers.dart';
import 'package:economy_app/providers/summary_categories_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:economy_app/utils/list_colors_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MonthlySumaryWidget extends ConsumerWidget {
  final int month;
  final int year;
  final String role;
  final BuildContext ctx;
  const MonthlySumaryWidget({
    super.key,
    required this.month,
    required this.year,
    required this.role,
    required this.ctx,
  });

  Future<void> _confirmDelete(int categoryId, WidgetRef ref, BuildContext context) async {
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
      if (!context.mounted) return;
      await _deleteCategory(categoryId, ref, context);
      // Invalidem el servici de les categories resum, per a no tindre que iterar tots els mesos i anys, i automaticament invalidem els providers fills, que son el summaryCategoriesProvider (el que trobem a la pantalla principal) i el summaryCategorySubcategoriesProvider (el que trobem a la pantalla  on es mostra el pastís i les subcategories).
      ref.invalidate(summaryCategoriesServiceProvider);
    }
  }

  Future<void> _deleteCategory(int categoryId, WidgetRef ref, BuildContext ctx) async {
    try {
      await ref
          .read(summaryCategoriesProvider((month, year)).notifier)
          .deleteCategory(categoryId);
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Categoria borrada correctamente.'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    } catch (e) {
      final message = e is ApiError ? e.message : 'Error inesperado';
      if (!ctx.mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('Error al borrar: $message'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlySummaryCategoriesState = ref.watch(
      summaryCategoriesProvider((month, year)),
    );

    return monthlySummaryCategoriesState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (err, _) => Center(
            child: Text('No hay datos.', style: const TextStyle(color: Colors.red)),
            //SelectableText('Error: ${err.toString()}',style: const TextStyle(color: Colors.red),),
          ),
      data: (summary) {
        if (summary.isEmpty) {
          return const Center(child: Text('No se han podiddo cargar las categorias.'));
        }
        /*
        return ListView.builder(
          // Desactivem el scroll perque qui crida a aquest widget ja te un scroll activat
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: summary.length,
          itemBuilder: (context, index) {
            final SummaryCategory monthSummary = summary[index];
            return SummaryCategoryCard(
              summary: monthSummary,
              index: index,
              month: month,
              year: year,
              role: role,
              ctx: context,
              ref: ref,
            );
          },
        );
        */
        return LayoutBuilder(
          builder: (context, constraints) {
            int columns = 1;

            if (constraints.maxWidth >= 1100) {
              columns = 3;
            } else if (constraints.maxWidth >= 750) {
              columns = 2;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: summary.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns, // --> 2 columnas
                crossAxisSpacing: 10, // --> espacio entre columnas
                mainAxisSpacing: 5, // --> espacio entre filas
                mainAxisExtent: 260, // --> altura de cada card
              ),
              itemBuilder: (context, index) {
                return SummaryCategoryCard(
                  summary: summary[index],
                  index: index,
                  month: month,
                  year: year,
                  role: role,
                  ctx: context,
                  ref: ref,
                );
              },
            );
          },
        );
      },
    );
  }
}

class SummaryCategoryCard extends StatefulWidget {
  final SummaryCategory summary;
  final int index;
  final int month;
  final int year;
  final String role;
  final BuildContext ctx;
  final WidgetRef ref;

  const SummaryCategoryCard({
    super.key,
    required this.summary,
    required this.index,
    required this.month,
    required this.year,
    required this.role,
    required this.ctx,
    required this.ref,
  });

  @override
  State<SummaryCategoryCard> createState() => _SummaryCategoryCardState();
}

class _SummaryCategoryCardState extends State<SummaryCategoryCard> {
  //bool showMonthly = false;
  String selected = 'Mensual'; //valor por defecto

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final ref = widget.ref;

    // Datos dinámicos según el modo para el boton de seleccion (Switch)
    //final expense = showMonthly ? summary.totalExpenses : summary.monthlyExpense;
    //final progress = showMonthly ? summary.goalTotalProgress / 100 : summary.goalMonthlyProgress / 100;

    // 🔹 Selección dinámica según el SegmentedButton
    double expense;
    double progress;

    switch (selected) {
      case 'Total':
        expense = summary.totalExpenses;
        progress = summary.goalTotalProgress / 100;
        break;
      case 'Anual':
        expense = summary.yearlyExpense;
        progress = summary.goalYearlyProgress / 100;
        break;
      case 'Mensual':
      default:
        expense = summary.monthlyExpense;
        progress = summary.goalMonthlyProgress / 100;
        break;
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
            // 🔹 Cabecera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    summary.categoryName,
                    style: const TextStyle(
                      color: AppColors.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // alinear a la derecha
            Align(
              alignment: Alignment.centerRight,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Total', label: Text('Total')),
                  ButtonSegment(value: 'Mensual', label: Text('Mensual')),
                  ButtonSegment(value: 'Anual', label: Text('Anual')),
                ],
                selected: {selected},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    selected = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ), // 🔹 hace que se vea más pequeño
                ),
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 Estado del objetivo
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (ref.read(selectedCategoryHomePieChartProvider.notifier).state ==
                        widget.index) {
                      ref.read(selectedCategoryHomePieChartProvider.notifier).state = -1;
                    } else {
                      ref.read(selectedCategoryHomePieChartProvider.notifier).state =
                          widget.index;
                    }
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: getColors()[widget.index % getColors().length],
                    child: Image.asset(summary.iconPath, width: 36, height: 36),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child:
                            summary.goal == null
                                ? const Text(
                                  'Sin objetivo',
                                  style: TextStyle(fontSize: 12),
                                )
                                : expense >= summary.goal!
                                ? const Text(
                                  '¡Objetivo alcanzado!',
                                  style: TextStyle(
                                    color: AppColors.successColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                )
                                : Text(
                                  '${(summary.goal! - expense).toStringAsFixed(2)} € restantes',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 10),

                      // 🔹 Barra de progreso
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

                      // 🔹 Datos numéricos
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
                            "${summary.goal ?? 0} €",
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

            // 🔹 Icono y acciones
            Row(
              children: [
                SizedBox(
                  width: 165,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.LIST_SUBCATEGORIES,
                        arguments: {
                          'summaryCategory': summary,
                          'month': widget.month,
                          'year': widget.year,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Subcategorías', style: TextStyle(fontSize: 15)),
                  ),
                ),
                const Spacer(),

                if (widget.role == 'ADMIN' || widget.role == 'SUPERADMIN')
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.secondaryColor),
                    tooltip: "Editar categoría",
                    onPressed: () {
                      ref.read(selectedSubcategoryIconProvider.notifier).state =
                          summary.iconPath;
                      Navigator.pushNamed(
                        context,
                        AppRoutes.NEW_EDIT_CATEGORY,
                        arguments: {'category': summary},
                      );
                    },
                  ),
                if ((widget.role == 'ADMIN' || widget.role == 'SUPERADMIN') &&
                    summary.id > 6)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: "Borrar categoría",
                    onPressed: () {
                      MonthlySumaryWidget(
                        month: widget.month,
                        year: widget.year,
                        role: widget.role,
                        ctx: widget.ctx,
                      )._confirmDelete(summary.id, ref, widget.ctx);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

/*
Card(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              elevation: 5,
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monthSummary.categoryName,
                      style: const TextStyle(
                        color: AppColors.secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child:
                          monthSummary.goal == null
                              ? const Text('Sin objetivo', style: TextStyle(fontSize: 12))
                              : monthSummary.monthlyExpense >= monthSummary.goal!
                              ? const Text(
                                '¡Objetivo alcanzado!',
                                style: TextStyle(
                                  color: AppColors.successColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              )
                              : Text(
                                '${(monthSummary.goal! - monthSummary.monthlyExpense).toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: LinearProgressIndicator(
                        value: monthSummary.goalMonthlyProgress / 100,
                        color:
                            getColors()[summary.indexOf(monthSummary) %
                                getColors().length],
                        //hacer la barra mas gruessa
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${monthSummary.monthlyExpense} €',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${monthSummary.goal ?? 0} €',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                leading: GestureDetector(
                  onTap: () {
                    if (ref.read(selectedCategoryHomePieChartProvider.notifier).state ==
                        index) {
                      ref.read(selectedCategoryHomePieChartProvider.notifier).state = -1;
                    } else {
                      ref.read(selectedCategoryHomePieChartProvider.notifier).state =
                          index;
                    }
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        getColors()[summary.indexOf(monthSummary) % getColors().length],
                    child: Image.asset(monthSummary.iconPath, width: 40, height: 40),
                  ),
                ),

                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.LIST_SUBCATEGORIES,
                    arguments: {
                      'summaryCategory': monthSummary,
                      'month': month,
                      'year': year,
                    },
                  );
                },
                onLongPress: () {
                  if (role == 'ADMIN' || role == 'SUPERADMIN') {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppColors.primaryColor,
                      builder:
                          (context) => Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.edit,
                                    color: AppColors.backgroundColor2,
                                  ),
                                  title: const Text(
                                    'Editar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // Posem al provide de la icona la icona seleccionada
                                    // per poder cambirala desde la pantalla de edició.
                                    ref
                                        .read(selectedSubcategoryIconProvider.notifier)
                                        .state = monthSummary.iconPath;
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.NEW_EDIT_CATEGORY,
                                      arguments: {'category': monthSummary},
                                    );
                                  },
                                ),
                                monthSummary.id > 6
                                    ? ListTile(
                                      leading: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      title: const Text(
                                        'Borrar',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _confirmDelete(monthSummary.id, ref, ctx);
                                      },
                                    )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ),
                    );
                  }
                } /*
                trailing:
                    role == 'ADMIN' || role == 'SUPERADMIN'
                        ? monthSummary.id > 6
                            ? PopupMenuButton<String>(
                              color: AppColors.primaryColor,
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  await _confirmDelete(monthSummary.id, ref, ctx);
                                } else if (value == 'edit') {
                                  // Posem al provide de la icona la icona seleccionada
                                  // per poder cambirala desde la pantalla de edició.
                                  ref
                                      .read(selectedSubcategoryIconProvider.notifier)
                                      .state = monthSummary.iconPath;
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.NEW_EDIT_CATEGORY,
                                    arguments: {'category': monthSummary},
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
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        trailing: Icon(
                                          Icons.edit,
                                          color: AppColors.backgroundColor2,
                                        ),
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        title: Text(
                                          'Borrar',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        trailing: Icon(Icons.delete, color: Colors.red),
                                      ),
                                    ),
                                  ],
                            )
                            : IconButton(
                              onPressed: () {
                                // Posem al provide de la icona seleccionada
                                // per poder cambirala desde la pantalla de edició.
                                ref.read(selectedSubcategoryIconProvider.notifier).state =
                                    monthSummary.iconPath;
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.NEW_EDIT_CATEGORY,
                                  arguments: {'category': monthSummary},
                                );
                              },
                              icon: Icon(Icons.edit),
                            )
                        : SizedBox.shrink(),
*/,
              ),
            );

 */
