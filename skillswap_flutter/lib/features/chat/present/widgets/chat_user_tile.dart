import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';

/// ChatUserTile - displays a conversation summary row
/// Expected fields passed in constructor:
/// - conversationId
/// - otherUid
/// - otherName
/// - lastMessage
/// - lastAt (DateTime?)
/// - unreadCount (int)
class ChatUserTile extends StatelessWidget {
  final String conversationId;
  final String otherUid;
  final String otherName;
  final String lastMessage;
  final DateTime? lastAt;
  final int unreadCount;
  final VoidCallback? onTap;

  const ChatUserTile({
    super.key,
    required this.conversationId,
    required this.otherUid,
    required this.otherName,
    this.lastMessage = '',
    this.lastAt,
    this.unreadCount = 0,
    this.onTap,
  });

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.15),
        child: Text(
          otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
          style: AppTextStyles.subheading.copyWith(color: AppColors.primary),
        ),
      ),
      title: Text(otherName, style: AppTextStyles.subheading),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lastAt != null) Text(_formatTime(lastAt), style: AppTextStyles.caption),
          const SizedBox(height: 8),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount.toString(),
                style: AppTextStyles.caption.copyWith(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
