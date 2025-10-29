import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 🌟 Modern animated rating stars widget
/// - Smooth gradient stars
/// - Soft glowing animation on tap
/// - Fully backward compatible with existing usage
class RatingStars extends StatefulWidget {
  final double rating;
  final double size;
  final double maxRating;
  final ValueChanged<double>? onRatingChanged;
  final EdgeInsets padding;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 22,
    this.maxRating = 5,
    this.onRatingChanged,
    this.padding = const EdgeInsets.symmetric(vertical: 6),
  });

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars>
    with SingleTickerProviderStateMixin {
  late double currentRating;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    currentRating = widget.rating.clamp(0, widget.maxRating);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.9,
      upperBound: 1.2,
    );
  }

  @override
  void didUpdateWidget(covariant RatingStars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) {
      currentRating = widget.rating.clamp(0, widget.maxRating);
    }
  }

  Widget _buildStar(int index) {
    final pos = index + 1;
    IconData icon;

    if (currentRating >= pos) {
      icon = Icons.star_rounded;
    } else if (currentRating > index && currentRating < pos) {
      icon = Icons.star_half_rounded;
    } else {
      icon = Icons.star_border_rounded;
    }

    bool isFilled = currentRating >= pos;

    return GestureDetector(
      onTap: widget.onRatingChanged == null
          ? null
          : () async {
              setState(() => currentRating = pos.toDouble());
              widget.onRatingChanged?.call(currentRating);
              _controller.forward(from: 0.9);
            },
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 1.1).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutBack,
        )),
        child: ShaderMask(
          shaderCallback: (Rect bounds) => const LinearGradient(
            colors: [Color(0xFFFFC107), Color(0xFFFFA726)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Icon(
            icon,
            size: widget.size,
            color: isFilled ? AppColors.accent : AppColors.textSecondary,
            shadows: isFilled
                ? [
                    Shadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 8,
                    )
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          widget.maxRating.toInt(),
          (i) => _buildStar(i),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
