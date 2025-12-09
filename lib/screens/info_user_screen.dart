import 'dart:io';

import 'package:economy_app/core/app_colors.dart';
import 'package:economy_app/models/api_error.dart';
import 'package:economy_app/providers/auth_provider.dart';
import 'package:economy_app/providers/dio_provider.dart';
import 'package:economy_app/providers/user_dto_provider.dart';
import 'package:economy_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class InfoUserScreen extends ConsumerWidget {
  const InfoUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final baseUrl = ref.read(dioProvider).options.baseUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text('Información del usuario'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.backgroundColor1, AppColors.backgroundColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 25, right: 25, bottom: 25),
                child: Container(
                  height: 850,
                  width: 700,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white54],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 15,
                        offset: const Offset(5, 8),
                      ),
                    ],
                  ),
                  child: userState.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) {
                      final message =
                          error is ApiError ? error.message : error.toString();
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(color: AppColors.primaryColor),
                        child: Center(
                          child: Text(
                            'Error: $message',
                            style: const TextStyle(color: Colors.red, fontSize: 20),
                          ),
                        ),
                      );
                    },
                    data: (user) {
                      if (user == null) {
                        return const Center(
                          child: Text(
                            'No se ha podido cargar el usuario, inicia sesión.',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        );
                      } else {
                        final String imageUrl =
                            '$baseUrl/media/image-profile/${user.profileImage}';
                        return Column(
                          children: [
                            const SizedBox(height: 30),

                            Stack(
                              children: [
                                user.profileImage != null
                                    ? CircleAvatar(
                                      radius: 80,
                                      backgroundImage: NetworkImage(imageUrl),
                                    )
                                    : const CircleAvatar(
                                      radius: 80,
                                      backgroundColor: Colors.grey,
                                      child: Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                Positioned(
                                  bottom: 5, // Distancia desde abajo
                                  left: 5,
                                  child: CircleAvatar(
                                    radius: 20,
                                    child: CircleAvatar(
                                      backgroundColor: AppColors.secondaryColor,
                                      radius: 40,
                                      child: IconButton(
                                        onPressed:
                                            () => _pickAndUpload(
                                              context,
                                              ref,
                                              user.id,
                                              imageUrl,
                                            ),
                                        icon: const Icon(
                                          Icons.photo_camera_outlined,
                                          size: 25,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              user.username,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Card(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    ListTile(
                                      //Redondear los bordes del ListTile la parte superior
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      tileColor: AppColors.primaryColor, // COLOR DE FONDO
                                      leading: const Icon(
                                        Icons.edit_note_rounded,
                                        color: Colors.white,
                                      ),
                                      title: Text(
                                        'EDITAR DATOS',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.EDIT_USER_PROFILE,
                                            arguments: {'userDto': user},
                                          );
                                        },
                                      ),
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.person_outlined,
                                        color: AppColors.secondaryColor,
                                      ),
                                      title: Row(
                                        children: [
                                          Text(
                                            'Nombre:  ',
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${user.firtName ?? ""} ${user.lastName ?? ""}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: AppColors.secondaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: const Divider(),
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.email_outlined,
                                        color: AppColors.secondaryColor,
                                      ),
                                      title: Row(
                                        children: [
                                          Text(
                                            'Email:  ',
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                          Expanded(
                                            child: Text(
                                              user.email,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: AppColors.secondaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: const Divider(),
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.admin_panel_settings_outlined,
                                        color: AppColors.secondaryColor,
                                      ),
                                      title: Row(
                                        children: [
                                          Text(
                                            'Rol:  ',
                                            style: const TextStyle(fontSize: 15),
                                          ),
                                          Text(
                                            user.role,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: AppColors.secondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Card(
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.lock_outline,
                                        color: AppColors.secondaryColor,
                                      ),
                                      title: Text(
                                        'Cabiar contreseña',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.arrow_forward_ios_outlined,
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.EDIT_USER_PASSWORD,
                                          );
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      child: const Divider(),
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.person_outline,
                                        color: AppColors.secondaryColor,
                                      ),
                                      title: Text(
                                        'Cabiar nombre de usuario',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.arrow_forward_ios_outlined,
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.EDIT_USERNAME,
                                            arguments: {'userName': user.username},
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  ref.read(authProvider.notifier).logout();
                                  // Actualitzem el userProvider perque com que hem tancat sessió, hem de refrescar l'estat de l'usuari.
                                  // Això es fa perque el provider d'usuari depen de l'authProvider, i si aquest canvia, el d'usuari també ha de canviar.
                                  ref.invalidate(userProvider);
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.LOGIN,
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Cerrar sesión',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Funcion para seleccionar y subir la imagen de perfil
  Future<void> _pickAndUpload(
    BuildContext context,
    WidgetRef ref,
    int userId,
    String imgUrl,
  ) async {
    final picker = ImagePicker();

    // 1) Elegir imagen
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (!context.mounted || picked == null) return;

    // 2) Leer bytes (Web y Móvil)
    Uint8List bytes = await picked.readAsBytes();

    // 3) Crear File SOLO en móvil
    File? file;
    if (!kIsWeb) {
      file = File(picked.path);
    }

    if (!context.mounted) return;

    // 4) Previsualización
    final shouldUpload = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirmar imagen'),
            content:
                kIsWeb
                    ? Image.memory(bytes, width: 200, height: 200)
                    : Image.file(file!, width: 200, height: 200),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Subir'),
              ),
            ],
          ),
    );

    if (!context.mounted || shouldUpload != true) return;

    // 5)Pugem i mostrem Loader
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Subiendo imagen...'), duration: Duration(days: 1)),
    );

    try {
      // 6) SUBIR imagen → adapta automáticamente según plataforma
      await ref
          .read(userProvider.notifier)
          .uploadProfileImage(
            imageFile: file,
            bytes: kIsWeb ? bytes : null,
            fileName: picked.name,
          );

      // 7) Evitar cache y refrescar
      await NetworkImage(imgUrl).evict();
      ref.invalidate(userProvider);

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Imagen actualizada', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primaryColor,
          ),
        );
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e is ApiError ? e.message : 'Error inesperado'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  /*
  Future<void> _pickAndUpload(
    BuildContext context,
    WidgetRef ref,
    int userId,
    String imgUrl,
  ) async {
    final picker = ImagePicker();

    // 1) Obrim galeria (poder afegir també ImageSource.camera si vols)
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (!context.mounted) return;
    if (picked == null) return;

    final file = File(picked.path);

    // 2) Mostrem diàleg de confirmació amb previsualització
    final shouldUpload = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirmar imagen'),
            content: Image.file(file, width: 200, height: 200),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Subir'),
              ),
            ],
          ),
    );
    if (!context.mounted) return;
    if (shouldUpload != true) return;

    // 3) Pugem i mostrem loader
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Subiendo imagen...'), duration: Duration(days: 1)),
    );

    try {
      await ref.read(userProvider.notifier).uploadProfileImage(file);
      // 1) Evitem la imatge antiga per forçar la recàrrega de la nova
      await NetworkImage(imgUrl).evict();
      ref.invalidate(
        userProvider,
      ); // Refresquem l'estat de l'usuari per mostrar la nova imatge
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Imagen actualizada', style: TextStyle(color: Colors.white)),
            backgroundColor: AppColors.primaryColor,
          ),
        );
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e is ApiError ? e.message : 'Error inesperado'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }
  */
}
