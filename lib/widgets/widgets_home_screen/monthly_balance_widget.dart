import 'dart:io';
import 'dart:typed_data';

import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/providers/balance_monthly_provider.dart';
import 'package:economy_app/providers/report_provider.dart';
import 'package:economy_app/utils/get_month_name.dart';
import 'package:economy_app/utils/size_screen.dart';
import 'package:economy_app/widgets/home_pie_chart.dart';
import 'package:economy_app/widgets/widgets_home_screen/monthly_categories_sumary_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

// Import segons la plataforma amb un import condicional per a que no pete en compilació de mobile/web
import 'package:economy_app/utils/pdf_stub.dart'
    if (dart.library.html) 'package:economy_app/utils/pdf_web.dart';

// Llibreria per detectar plataforma web
import 'package:flutter/foundation.dart' show kIsWeb;

class MonthlyBalanceWidget extends ConsumerStatefulWidget {
  final String role;
  const MonthlyBalanceWidget({super.key, required this.role});

  @override
  ConsumerState<MonthlyBalanceWidget> createState() => _MonthlyBalanceWidgetState();
}

class _MonthlyBalanceWidgetState extends ConsumerState<MonthlyBalanceWidget> {
  late int selectedMonth;
  late int selectedYear;

  bool _isLoadingReport = false;
  Uint8List? _pdfBytes;
  String? _reportError;

  Future<void> _generateReport(int month, int year) async {
    setState(() {
      _isLoadingReport = true;
      _reportError = null;
      _pdfBytes = null;
    });

    try {
      final service = ref.read(generateReportServiceProvider);
      final bytes = await service.generateReport(month: month, year: year);
      setState(() {
        _pdfBytes = bytes;
      });
    } catch (e) {
      setState(() {
        _reportError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReport = false;
        });
      }
    }
  }

  Future<void> _openPdf(int month, int year) async {
    if (_pdfBytes == null) return;

    // 🌐 WEB
    if (kIsWeb) {
      downloadPdfWeb(_pdfBytes!, 'informe-$month-$year.pdf');
      return;
    }
    // 📱 ANDROID / iOS / DESKTOP
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/informe-$month-$year.pdf');
    await file.writeAsBytes(_pdfBytes!);
    await OpenFile.open(file.path);
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    final monthlyBalance = ref.watch(
      balancePerMonthProvider((selectedMonth, selectedYear)),
    );
    // Fem que tot el widget sigui scrollable per si hi ha molts elements a mostrar
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<int>(
                value: selectedMonth,
                items: List.generate(12, (index) {
                  final month = index + 1;
                  return DropdownMenuItem(
                    value: month,
                    child: Text(
                      getMonthName(month),
                      style: TextStyle(fontSize: isDesktop(context) ? 18 : 15),
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedMonth = value);
                  }
                },
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: selectedYear,
                items: List.generate(6, (index) {
                  final year = DateTime.now().year + index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(
                      '$year',
                      style: TextStyle(fontSize: isDesktop(context) ? 18 : 15),
                    ),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedYear = value);
                  }
                },
              ),
            ],
          ),
          // COLUMNA PRINIPAL
          const SizedBox(height: 20),
          monthlyBalance.when(
            data: (balance) {
              if (balance == null) {
                return const Text("No se ha podido cargar el saldo.");
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    elevation: 5,
                    child: Container(
                      padding:
                          isDesktop(context)
                              ? EdgeInsets.only(top: 20, left: 50, right: 50, bottom: 40)
                              : EdgeInsets.only(top: 20, left: 20, right: 5, bottom: 40),
                      width: 900,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Resumen del mes de:",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: isDesktop(context) ? 24 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${getMonthName(selectedMonth)} de $selectedYear",
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isDesktop(context) ? 20 : 15,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Saldo mensual: ${balance.saldo.toStringAsFixed(2)} €",
                                      //"Saldo mensual: 10988,00 €",
                                      style: TextStyle(
                                        fontSize: isDesktop(context) ? 18 : 14,
                                      ),
                                    ),
                                    Text(
                                      "Total gastos: ${balance.expenses.toStringAsFixed(2)} €",
                                      style: TextStyle(
                                        fontSize: isDesktop(context) ? 18 : 14,
                                      ),
                                    ),
                                    Text(
                                      "Ingresos: ${balance.income.toStringAsFixed(2)} €",
                                      style: TextStyle(
                                        fontSize: isDesktop(context) ? 18 : 14,
                                      ),
                                    ),
                                    Text(
                                      "Ahorros: ${balance.savings.toStringAsFixed(2)} €",
                                      style: TextStyle(
                                        fontSize: isDesktop(context) ? 18 : 14,
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    ElevatedButton(
                                      onPressed:
                                          _isLoadingReport
                                              ? null
                                              : () => _generateReport(
                                                selectedMonth,
                                                selectedYear,
                                              ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secondaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      child:
                                          _isLoadingReport
                                              ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                              : const Text("Generar Informe"),
                                    ),
                                    if (_pdfBytes != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.successColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed:
                                              () => _openPdf(selectedMonth, selectedYear),
                                          child: Text('Ver Informe'),
                                        ),
                                      ),
                                    if (_reportError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Text(
                                          'Error al generar el informe',
                                          style: const TextStyle(color: Colors.red),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: isDesktop(context) ? 220 : 140,
                                height: isDesktop(context) ? 220 : 140,
                                child: MyHomePieChart(
                                  month: selectedMonth,
                                  year: selectedYear,
                                  totalAmount: balance.expenses,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Card(
                      color: AppColors.secondaryColor,
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: const Text(
                            "Listado de categorías",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  MonthlySumaryWidget(
                    month: selectedMonth,
                    year: selectedYear,
                    role: widget.role,
                    ctx: context,
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (error, _) {
              return Center(
                child: Text('No hay datos.', style: const TextStyle(color: Colors.red)),
              );
            },
          ),
        ],
      ),
    );
  }
}
