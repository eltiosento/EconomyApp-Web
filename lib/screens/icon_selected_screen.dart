import 'dart:convert';

import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/providers/providers_utils_providers.dart';
import 'package:economy_app/utils/size_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IconSelectedScreen extends ConsumerWidget {
  const IconSelectedScreen({super.key});

  Future<List<String>> _loadIconsPaths() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final manifest = json.decode(manifestContent) as Map<String, dynamic>;

    final imagePaths =
        manifest.keys.where((String key) => key.startsWith('assets/icons/')).toList();

    return imagePaths;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona una imagen'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<String>>(
        future: _loadIconsPaths(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las imágenes'));
          } else {
            final imagePaths = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    isDesktop(context)
                        ? 8
                        : isSmollTable(context)
                        ? 5
                        : 3,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                final imagePath = imagePaths[index];

                return IconButton(
                  onPressed: () {
                    ref.read(selectedSubcategoryIconProvider.notifier).state = imagePath;
                    Navigator.pop(context);
                  },
                  icon: Image.asset(imagePath, height: 100, width: 100),
                );
              },
            );
          }
        },
      ),
    );
  }
}
