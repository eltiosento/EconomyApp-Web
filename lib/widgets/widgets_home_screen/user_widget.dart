import 'package:economy_app/models/user_dto.dart';
import 'package:economy_app/providers/dio_provider.dart';
import 'package:economy_app/utils/size_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserWidget extends ConsumerWidget {
  final UserDto userDto;
  const UserWidget({super.key, required this.userDto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baseUrl = ref.read(dioProvider).options.baseUrl;
    final String imageUrl = '$baseUrl/media/image-profile/${userDto.profileImage}';

    return (userDto.profileImage != null)
        ? Column(
          children: [
            CircleAvatar(
              radius: isDesktop(context) ? 70 : 50,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(height: 10),
            Text(
              '¡Hola, ${userDto.username}!',
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ],
        )
        : Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 10),
            Text(
              '¡Hola, ${userDto.username}!',
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
          ],
        );
  }
}
