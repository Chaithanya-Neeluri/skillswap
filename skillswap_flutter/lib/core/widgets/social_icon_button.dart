import 'package:flutter/material.dart';

class SocialIconButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;
  final double size;
  final Color? backgroundColor;

  const SocialIconButton({
    super.key,
    required this.assetPath,
    required this.onTap,
    this.size = 45,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? Colors.white.withOpacity(0.15),
          border: Border.all(color: Colors.white24),
        ),
        child:
     
        Image.asset(assetPath, fit: BoxFit.fill),
        
      ),
    );
  }
}
