import 'package:flutter/material.dart';
import '../models/announcement.dart';
import '../themes/jfm_themes.dart';

/// Announcement Banner Widget
/// 
/// Displays announcements with priority-based colors and animations.
/// Supports swipe to dismiss and tap to action.
class AnnouncementBanner extends StatefulWidget {
  final Announcement announcement;
  final JfmThemeData theme;
  final VoidCallback onDismiss;

  const AnnouncementBanner({
    Key? key,
    required this.announcement,
    required this.theme,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<AnnouncementBanner> createState() => _AnnouncementBannerState();
}

class _AnnouncementBannerState extends State<AnnouncementBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.announcement.colors;
    final backgroundColor = _hexToColor(colors.background);
    final textColor = _hexToColor(colors.text);
    final accentColor = _hexToColor(colors.accent);

    return SlideTransition(
      position: _slideAnimation,
      child: Dismissible(
        key: Key(widget.announcement.id),
        direction: DismissDirection.horizontal,
        onDismissed: (_) => widget.onDismiss(),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                backgroundColor,
                backgroundColor.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Handle action URL if present
                  if (widget.announcement.actionUrl != null) {
                    // Launch URL
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Priority Icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withOpacity(0.3),
                        ),
                        child: Icon(
                          _getPriorityIcon(widget.announcement.priority),
                          color: textColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.announcement.title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.announcement.message,
                              style: TextStyle(
                                color: textColor.withOpacity(0.9),
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Action or Close
                      if (widget.announcement.actionLabel != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.announcement.actionLabel!,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: textColor.withOpacity(0.7),
                            size: 20,
                          ),
                          onPressed: widget.onDismiss,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPriorityIcon(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.low:
        return Icons.info_outline;
      case AnnouncementPriority.normal:
        return Icons.notifications_outlined;
      case AnnouncementPriority.high:
        return Icons.priority_high;
      case AnnouncementPriority.urgent:
        return Icons.warning_amber_rounded;
    }
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

/// Compact Announcement Chip
/// 
/// Small version for use in headers or compact spaces
class AnnouncementChip extends StatelessWidget {
  final Announcement announcement;
  final JfmThemeData theme;
  final VoidCallback onTap;

  const AnnouncementChip({
    Key? key,
    required this.announcement,
    required this.theme,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = announcement.colors;
    final backgroundColor = _hexToColor(colors.background);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              announcement.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}
