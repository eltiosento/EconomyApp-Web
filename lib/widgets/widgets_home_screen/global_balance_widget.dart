//import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/models/balance.dart';
import 'package:economy_app/providers/balance_global_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalBalanceWidget extends ConsumerWidget {
  const GlobalBalanceWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceState = ref.watch(balanceGlobalProvider);

    return balanceState.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) {
        //final message = error is ApiError ? error.message : error.toString();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo global:',
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Patrimonio:',
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text('Ahorros:', style: const TextStyle(fontSize: 15, color: Colors.white)),
            const SizedBox(height: 10),
            //Text(message, style: const TextStyle(color: Colors.red)),
          ],
        );
      },
      data: (Balance? balance) {
        if (balance != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo global: ${balance.saldo} €',
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Patrimonio: ${balance.patrimony} €',
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Ahorros: ${balance.savings} €',
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ],
          );
        } else {
          return const Center(child: Text('No se ha podido cargar el saldo.'));
        }
      },
    );
  }
}
