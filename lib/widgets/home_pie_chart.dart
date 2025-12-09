import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/providers/providers_utils_providers.dart';
import 'package:economy_app/providers/summary_categories_provider.dart';
import 'package:economy_app/utils/list_colors_pie_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyHomePieChart extends ConsumerWidget {
  final int month;
  final int year;
  final double totalAmount;

  const MyHomePieChart({
    super.key,
    required this.month,
    required this.year,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlySummaryCategoriesState = ref.watch(
      summaryCategoriesProvider((month, year)),
    );

    final highlightIndex = ref.watch(selectedCategoryHomePieChartProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double size = constraints.biggest.shortestSide;

        // Tamaños responsivos
        final bool isDesktop = size > 180;

        // Grosor general más fino
        final double radius = isDesktop ? size * 0.22 : size * 0.20;
        final double highlightRadius = isDesktop ? size * 0.26 : size * 0.24;

        // Centro más grande (para que no se vea tan grueso el pastel)
        final double centerRadius = isDesktop ? size * 0.28 : size * 0.25;

        // Espacio entre secciones más elegante
        final double sectionSpace = isDesktop ? 4 : 2;

        // Texto más proporcionado
        final double fontSize = isDesktop ? 12 : 9;
        return monthlySummaryCategoriesState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (err, _) =>
                  Icon(Icons.pie_chart, size: size * 0.8, color: AppColors.errorColor),
          data: (listCategories) {
            // Filtrar solo positivas
            final positiveCategories =
                listCategories.where((c) => c.monthlyExpense >= 0).toList();

            if (positiveCategories.isEmpty) {
              return Icon(
                Icons.pie_chart,
                size: size * 0.8,
                color: AppColors.primaryColor,
              );
            }

            final positiveTotal = positiveCategories.fold<double>(
              0,
              (sum, c) => sum + c.monthlyExpense,
            );

            final sections =
                positiveCategories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final cat = entry.value;

                  final percentage = (cat.monthlyExpense / positiveTotal) * 100;

                  return PieChartSectionData(
                    value: cat.monthlyExpense,
                    title: '${percentage.toStringAsFixed(1)}%',
                    color: getColors()[listCategories.indexOf(cat) % getColors().length],
                    radius: index == highlightIndex ? highlightRadius : radius,
                    titleStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                    ),
                    borderSide: const BorderSide(color: Colors.black26, width: 1),
                  );
                }).toList();

            return PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: sectionSpace,
                centerSpaceRadius: centerRadius,
              ),
              duration: const Duration(milliseconds: 400),
            );
          },
        );
      },
    );
  }
}
