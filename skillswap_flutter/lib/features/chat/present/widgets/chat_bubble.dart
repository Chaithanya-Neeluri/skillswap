import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime? createdAt;
  final String? status;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.createdAt,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);
    final bg = isMe ? AppColors.primary : AppColors.surface;
    final fg = isMe ? Colors.white : AppColors.textPrimary;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 2, offset: const Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: AppTextStyles.body.copyWith(color: fg)),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (createdAt != null)
                  Text(
                    '${createdAt!.hour.toString().padLeft(2, '0')}:${createdAt!.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.caption.copyWith(color: fg.withOpacity(0.9)),
                  ),
                const SizedBox(width: 6),
                if (isMe)
                  Icon(
                    status == 'read' ? Icons.done_all : Icons.done,
                    size: 16,
                    color: fg.withOpacity(0.9),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
