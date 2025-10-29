import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 🌿 Modern SkillChip with subtle animations and gradients.
/// Retains the same structure — just visually enhanced.
class SkillChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final EdgeInsets padding;

  const SkillChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leading,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });

  @override
  State<SkillChip> createState() => _SkillChipState();
}

class _SkillChipState extends State<SkillChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.96,
      upperBound: 1.04,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? null // for gradient
        : AppColors.surface;
    final fg = widget.selected ? Colors.white : AppColors.textPrimary;
    final border = widget.selected
        ? null
        : BorderSide(color: AppColors.textSecondary.withOpacity(0.15));

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.04).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: widget.selected
              ? const LinearGradient(
                  colors: [
                    Color(0xFF9D8DF1), // soft lavender
                    Color(0xFF7A6DF0), // slightly deeper tone
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: bg,
          borderRadius: BorderRadius.circular(24),
          border: border != null ? Border.fromBorderSide(border) : null,
          boxShadow: widget.selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF7A6DF0).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              if (widget.onTap != null) {
                _controller.forward(from: 0.96);
                widget.onTap!();
              }
            },
            child: Padding(
              padding: widget.padding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.leading != null) ...[
                    SizedBox(height: 20, width: 20, child: widget.leading),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: AppTextStyles.body.copyWith(
                      color: fg,
                      fontWeight: widget.selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      letterSpacing: 0.2,
                      shadows: widget.selected
                          ? [
                              const Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                              )
                            ]
                          : [],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
