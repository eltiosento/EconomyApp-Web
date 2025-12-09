import 'package:flutter_riverpod/flutter_riverpod.dart';

// Creem dos providers per guardar el mes i l'any seleccionats en posterior widgets
// on no podem accedir al mes i any seleccionats d'aquesta manera centralitzem la informació
// i la podem utilitzar en qualsevol widget que ho necessiti.
// Fem us de watch per obtindre els valors actualitzats
// i desde els widgets on estan els selesctors de mes i any
// reassignem els valors seleccionats amb ref.read(selectedMonthProvider.notifier).state = value;
final selectedMonthProvider = StateProvider<int>((ref) => DateTime.now().month);
final selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

// Per guardar la categoria seleccionada al pie chart
final selectedCategoryHomePieChartProvider = StateProvider<int?>((ref) => -1);

final selectedSubcategoryIconProvider = StateProvider<String>((ref) => '');
