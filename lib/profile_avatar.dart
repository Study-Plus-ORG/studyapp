import 'package:flutter/material.dart';

const profileImagePaths = [
  'lib/icons/WhatsApp Image 2026-09-24 at 10.04.33 (1).jpeg',
  'lib/icons/WhatsApp Image 2026-09-24 at 10.04.33.jpeg',
  'lib/icons/WhatsApp Image 2026-09-24 at 10.04.34 (1).jpeg',
  'lib/icons/WhatsApp Image 2026-09-24 at 10.04.34 (2).jpeg',
  'lib/icons/WhatsApp Image 2026-09-24 at 10.04.34.jpeg',
  'lib/icons/WhatsApp Image 2026-09-24 at 10.04.35 (1).jpeg',
  'lib/icons/WhatsApp Image 2026-09-24 at 10.04.35.jpeg',
];

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.imagePath,
    this.radius = 24,
    this.showFallback = true,
  });

  final String? imagePath;
  final double radius;
  final bool showFallback;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && profileImagePaths.contains(imagePath);
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF7DE2C3),
      foregroundColor: const Color(0xFF061B1A),
      backgroundImage: hasImage ? AssetImage(imagePath!) : null,
      child: hasImage || !showFallback
          ? null
          : Icon(Icons.person_rounded, size: radius),
    );
  }
}
