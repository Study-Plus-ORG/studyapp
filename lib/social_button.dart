// social_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final String iconName;
  final String label;
  final double horizontalPadding;
  final VoidCallback onPressed;
  final Widget? prefixIcon;

  const SocialButton({
    super.key,
    required this.iconName,
    required this.label,
    this.horizontalPadding = 70,
    required this.onPressed,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: const BorderSide(color: Color.fromARGB(141, 233, 233, 233), width: 2),
        ),
      ),
      onPressed: onPressed,
      icon: prefixIcon ??
          SvgPicture.asset(
            'assets/svgs/$iconName',
            width: 25,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
      label: Text(
        label,
        style: const TextStyle(color: Color.fromARGB(255, 231, 230, 230)),
      ),
    );
  }
}