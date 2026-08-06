// social_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialButton extends StatelessWidget {
  final String iconName;
  final String label;
  final double horizontalPadding;
  final VoidCallback onPressed;


  const SocialButton({
    super.key,
    required this.iconName,
    required this.label,
    this.horizontalPadding = 70,
    required this.onPressed,
  });


  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: SvgPicture.asset(
        'assets/svgs/$iconName.svg',
        width:25,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
        ),
         label: Text(label, style: const TextStyle(color: Color.fromARGB(255, 231, 230, 230)),)); 
    
    
  }
}