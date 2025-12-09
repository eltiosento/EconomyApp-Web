import 'package:economy_app/models/auth_response.dart';
import 'package:economy_app/models/balance.dart';
import 'package:economy_app/providers/auth_provider.dart';
import 'package:economy_app/providers/dio_provider.dart';
import 'package:economy_app/services/balance_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final balanceServiceProvider = Provider<BalanceService>((ref) {
  final dio = ref.watch(dioProvider);
  return BalanceService(dio);
});

final balanceGlobalProvider = AsyncNotifierProvider<BalanceNotifier, Balance?>(
  BalanceNotifier.new,
);

class BalanceNotifier extends AsyncNotifier<Balance?> {
  @override
  Future<Balance?> build() async {
    // Observem l'estat d'autenticació per saber si hi ha un token vàlid.
    // El provider d'autenticació és un AsyncNotifierProvider, així que podem obtenir el seu valor amb ref.watch()
    // Per tant amb .value si es un AuthResponse, o null.
    final authState = ref.watch(authProvider);
    final AuthResponse? authResponse = authState.value;

    // Si es null, vol dir que no hi ha cap usuari loguejat, així que retornem null. authState També s'encarrega de saber si el token està caducat o no.
    if (authResponse == null) {
      return null;
    }

    // Demanem el servei directament sense emmagatzemar-lo com a camp.
    final service = ref.watch(balanceServiceProvider);
    // Cridem el servei per obtenir el saldo
    // i actualitzem l'estat del provider amb el resultat.
    // Si hi ha un error, el provider (service) es posarà en estat d'error automàticament.
    return await service.getSummaryGlobalBalance();
  }
}
