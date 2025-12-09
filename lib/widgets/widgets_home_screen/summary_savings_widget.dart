import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/category_summary.dart';
import 'package:economy_app/providers/providers_utils_providers.dart';
import 'package:economy_app/providers/savings_categories_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:economy_app/utils/list_colors_pie_chart.dart';
import 'package:economy_app/utils/size_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SummarySavingsWidget extends ConsumerStatefulWidget {
  final String role;
  const SummarySavingsWidget({super.key, required this.role});

  @override
  ConsumerState<SummarySavingsWidget> createState() => _SummarySavingsWidgetState();
}

class _SummarySavingsWidgetState extends ConsumerState<SummarySavingsWidget> {
  @override
  Widget build(BuildContext context) {
    final savingCategories = ref.watch(savingCategoriesProvider);

    return SingleChildScrollView(
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
                  'Resumen total de los ahorros',
                  textAlign: isDesktop(context) ? TextAlign.center : TextAlign.left,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                subtitle: Text(
                  'Aquí puedes ver resumidas todas tus categorías de ahorros junto con el progreso hacia los objetivos establecidos.',
                  textAlign: isDesktop(context) ? TextAlign.center : TextAlign.left,
                  style: TextStyle(fontSize: 15, color: AppColors.secondaryColor),
                ),
                trailing: Image.asset('assets/icons/savings.png', width: 50, height: 50),
              ),
            ),
          ),
          savingCategories.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (err, _) => Center(
                  child: Text('No hay datos.', style: const TextStyle(color: Colors.red)),
                ),
            data: (savingCategoriesData) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      color: AppColors.secondaryColor,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                        child: Center(
                          child: Row(
                            mainAxisAlignment:
                                isDesktop(context)
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Categorías de ahorros",
                                style: TextStyle(fontSize: 20, color: Colors.white),
                              ),
                              Builder(
                                builder:
                                    (buttonContext) => IconButton(
                                      icon: const Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        final RenderBox button =
                                            buttonContext.findRenderObject() as RenderBox;
                                        final RenderBox overlay =
                                            Overlay.of(
                                                  buttonContext,
                                                ).context.findRenderObject()
                                                as RenderBox;

                                        await showMenu(
                                          context: buttonContext,
                                          position: RelativeRect.fromRect(
                                            Rect.fromPoints(
                                              button.localToGlobal(
                                                Offset.zero,
                                                ancestor: overlay,
                                              ),
                                              button.localToGlobal(
                                                button.size.bottomRight(Offset.zero),
                                                ancestor: overlay,
                                              ),
                                            ),
                                            Offset.zero & overlay.size,
                                          ),
                                          items: [
                                            PopupMenuItem(
                                              // Opcional: evitar que parezca “seleccionable”
                                              enabled: false,
                                              child: Text(
                                                "Para borrar o crear las distintas categorías de ahorros y para una mayor edición, vaya a la pestaña de movimientos.",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: AppColors.secondaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  savingCategoriesData.isEmpty
                      ? const Center(
                        child: Text(
                          'Todavía no hay categorías de ahorros registradas.',
                          style: TextStyle(fontSize: 18, color: AppColors.errorColor),
                        ),
                      )
                      : LayoutBuilder(
                        builder: (context, constraints) {
                          int columns = 1;

                          if (constraints.maxWidth >= 1100) {
                            columns = 3;
                          } else if (constraints.maxWidth >= 750) {
                            columns = 2;
                          }
                          return GridView.builder(
                            physics:
                                const NeverScrollableScrollPhysics(), // Desactivem el scroll perque qui crida a aquest widget ja te un scroll activat
                            shrinkWrap: true,
                            itemCount: savingCategoriesData.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns, // --> 2 columnas
                              crossAxisSpacing: 0, // --> espacio entre columnas
                              mainAxisSpacing: 5, // --> espacio entre filas
                              mainAxisExtent: 220, // --> altura de cada card
                            ),
                            itemBuilder: (context, index) {
                              final SummaryCategory summaryCategory =
                                  savingCategoriesData[index];
                              return GoalCard(
                                summaryCategory: summaryCategory,
                                ref: ref,
                                indexColor:
                                    savingCategoriesData.indexOf(summaryCategory) %
                                    getColors().length,
                                role: widget.role,
                              );
                            },
                          );
                        },
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.summaryCategory,
    required this.ref,
    required this.indexColor,
    required this.role,
  });

  final SummaryCategory summaryCategory;
  final WidgetRef ref;
  final int indexColor;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: isDesktop(context) ? 15 : 25,
      ),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Cabecera
            Text(
              summaryCategory.categoryName,
              style: const TextStyle(
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 8),

            // 🔹 Estado del objetivo
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: getColors()[indexColor],
                  child: Image.asset(summaryCategory.iconPath, width: 36, height: 36),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child:
                            summaryCategory.goal == null
                                ? const Text(
                                  'Sin objetivo',
                                  style: TextStyle(fontSize: 12),
                                )
                                : summaryCategory.totalExpenses >= summaryCategory.goal!
                                ? const Text(
                                  '¡Objetivo alcanzado!',
                                  style: TextStyle(
                                    color: AppColors.successColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                )
                                : Text(
                                  '${(summaryCategory.goal! - summaryCategory.totalExpenses).toStringAsFixed(2)} € restantes',
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
                          value: summaryCategory.goalTotalProgress / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade300,
                          color: getColors()[indexColor],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 🔹 Datos numéricos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${summaryCategory.totalExpenses.toStringAsFixed(2)} €",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${summaryCategory.goal ?? 0} €",
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
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.SUBCATEGORY_DETAILS,
                        arguments: {
                          'summaryCategory': summaryCategory,
                          'month': DateTime.now().month,
                          'year': DateTime.now().year,
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
                    child: const Text('Ver detalles', style: TextStyle(fontSize: 15)),
                  ),
                ),
                const Spacer(),

                if (role == 'ADMIN' || role == 'SUPERADMIN')
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.secondaryColor),
                    onPressed: () {
                      ref.read(selectedSubcategoryIconProvider.notifier).state =
                          summaryCategory.iconPath;
                      Navigator.pushNamed(
                        context,
                        AppRoutes.NEW_EDIT_CATEGORY,
                        arguments: {'category': summaryCategory},
                      );
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
ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summaryCategory.categoryName,
              style: const TextStyle(
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child:
                  summaryCategory.goal == null
                      ? const Text('Sin objetivo', style: TextStyle(fontSize: 12))
                      : summaryCategory.totalExpenses >= summaryCategory.goal!
                      ? const Text(
                        '¡Objetivo alcanzado!',
                        style: TextStyle(
                          color: AppColors.successColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                      : Text(
                        '${summaryCategory.goal! - summaryCategory.totalExpenses} €',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
            ),
            LinearProgressIndicator(
              value: summaryCategory.goalTotalProgress / 100,
              color: getColors()[indexColor],
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${summaryCategory.totalExpenses} €',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${summaryCategory.goal ?? 0} €',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: getColors()[indexColor],
          child: Image.asset(summaryCategory.iconPath, width: 40, height: 40),
        ),
        onTap:
            () => Navigator.pushNamed(
              context,
              AppRoutes.SUBCATEGORY_DETAILS,
              arguments: {
                'summaryCategory': summaryCategory,
                'month': DateTime.now().month,
                'year': DateTime.now().year,
              },
            ),
        onLongPress: () {
          ref.read(selectedSubcategoryIconProvider.notifier).state =
              summaryCategory.iconPath;
          Navigator.pushNamed(
            context,
            AppRoutes.NEW_EDIT_CATEGORY,
            arguments: {'category': summaryCategory},
          );
        },
      ),


*/