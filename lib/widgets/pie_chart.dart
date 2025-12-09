import 'package:economy_app/models/summary_category_subcategories.dart';
import 'package:economy_app/utils/list_colors_pie_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyPieChart extends StatelessWidget {
  final SummaryCategorySubcategories data;
  final int? highlightIndex;

  const MyPieChart({super.key, required this.data, this.highlightIndex});

  @override
  Widget build(BuildContext context) {
    double totalAmount = data.monthlyExpense;

    // 1.Filtramos las subcategorías con totalExpenses > 0
    final positiveSubs =
        data.subcategories.where((sub) => sub.monthlyExpense >= 0).toList();

    // 2.Si no queda ninguna, mostramos un fallback (o un widget vacío)
    if (positiveSubs.isEmpty) {
      return const Icon(Icons.pie_chart, size: 125, color: Colors.grey);
    }

    // 3.Recalculamos el total solo de las positivas
    final positiveTotal = positiveSubs.fold<double>(
      0,
      (sum, sub) => sum + sub.monthlyExpense,
    );

    // 4.Construimos las secciones desde la lista filtrada
    final sections =
        positiveSubs.asMap().entries.map((entry) {
          final index = entry.key;
          final sub = entry.value;
          final percentage = (sub.monthlyExpense / positiveTotal) * 100;
          final isHighlighted = index == highlightIndex;
          return PieChartSectionData(
            value: sub.monthlyExpense,
            title: '${percentage.toStringAsFixed(1)}%',
            color: getColors()[data.subcategories.indexOf(sub) % getColors().length],
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              shadows: [
                Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black26),
              ],
            ),
            borderSide: const BorderSide(color: Colors.black38, width: 1),
            radius: isHighlighted ? 70 : 55,
          );
        }).toList();

    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          "${totalAmount.toString()} €",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            shadows: [Shadow(offset: Offset(0, 2), blurRadius: 4, color: Colors.black38)],
          ),
        ),
        PieChart(
          duration: const Duration(milliseconds: 300),
          PieChartData(sectionsSpace: 10, centerSpaceRadius: 65, sections: sections),
        ),
      ],
    );
  }
}
