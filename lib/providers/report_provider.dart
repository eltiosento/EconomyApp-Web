import 'package:economy_app/providers/dio_provider.dart';
import 'package:economy_app/services/generate_report_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final generateReportServiceProvider = Provider<GenerateReportService>((ref) {
  final dio = ref.watch(dioProvider);
  return GenerateReportService(dio);
});
