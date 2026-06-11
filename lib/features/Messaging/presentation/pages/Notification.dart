// ignore_for_file: file_names

import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _NotificationCategory { all, events, appointment, messages, payment }

class _NotificationItemData {
  const _NotificationItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.isHighlighted,
    required this.category,
    this.routeName,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final bool isHighlighted;
  final _NotificationCategory category;
  final String? routeName;
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const List<_NotificationItemData> _notifications = [
    _NotificationItemData(
      icon: Icons.calendar_today_outlined,
      title: 'Your appointment is booked',
      subtitle: 'See details',
      backgroundColor: Colors.white,
      isHighlighted: false,
      category: _NotificationCategory.appointment,
      routeName: RouteName.appointments,
    ),
    _NotificationItemData(
      icon: Icons.person_outline,
      title: 'Complete your profile',
      subtitle: 'You are 30% done. Complete to get more personalized feed',
      backgroundColor: Color(0xFFBFDBFE),
      isHighlighted: true,
      category: _NotificationCategory.all,
      routeName: RouteName.medicalEdit,
    ),
    _NotificationItemData(
      icon: Icons.wb_sunny_outlined,
      title: 'Your Circle request is approved',
      subtitle: 'You are now a member of Early Riser Elite Club',
      backgroundColor: Colors.white,
      isHighlighted: false,
      category: _NotificationCategory.events,
    ),
    _NotificationItemData(
      icon: Icons.calendar_today_outlined,
      title: '360 Club event is coming up today by 6pm',
      subtitle: 'You subscribed to this event. See details to not miss it',
      backgroundColor: Color(0xFFBFDBFE),
      isHighlighted: true,
      category: _NotificationCategory.events,
    ),
    _NotificationItemData(
      icon: Icons.mail_outline,
      title: 'Dr. Lagbaja has replied your message.',
      subtitle: 'Reply him now',
      backgroundColor: Colors.white,
      isHighlighted: false,
      category: _NotificationCategory.messages,
      routeName: RouteName.messages,
    ),
    _NotificationItemData(
      icon: Icons.calendar_today_outlined,
      title: 'It\'s Dr. Uzo\'s Birthday today.',
      subtitle: 'Wish her well!',
      backgroundColor: Colors.white,
      isHighlighted: false,
      category: _NotificationCategory.events,
    ),
    _NotificationItemData(
      icon: Icons.people_outline,
      title: '5 Specialists are having free consultations now',
      subtitle: 'Take advantage',
      backgroundColor: Colors.white,
      isHighlighted: false,
      category: _NotificationCategory.events,
    ),
    _NotificationItemData(
      icon: Icons.article_outlined,
      title: 'Dr. Tamedu has published a new article',
      subtitle: 'Read now',
      backgroundColor: Colors.white,
      isHighlighted: false,
      category: _NotificationCategory.events,
      routeName: RouteName.articles,
    ),
    _NotificationItemData(
      icon: Icons.info_outline,
      title: 'Your emergency request is approved.',
      subtitle: 'Ambulance is on the way!',
      backgroundColor: Colors.white,
      isHighlighted: false,
      category: _NotificationCategory.all,
      routeName: RouteName.emergency,
    ),
    _NotificationItemData(
      icon: Icons.description_outlined,
      title: 'Update your reading, its been 5 days already',
      subtitle: 'Connect your bluetooth or manually update reading',
      backgroundColor: Colors.white,
      isHighlighted: false,
      category: _NotificationCategory.appointment,
      routeName: RouteName.readings,
    ),
    _NotificationItemData(
      icon: Icons.mic_none,
      title: 'Dr. Lakasegbe has published a new podcast',
      subtitle: 'Listen now',
      backgroundColor: Colors.white,
      isHighlighted: false,
      category: _NotificationCategory.events,
      routeName: RouteName.podcast,
    ),
    _NotificationItemData(
      icon: Icons.add_box_outlined,
      title: 'You are missing updates',
      subtitle: 'Open feed, see what people are saying and tell us your mind!',
      backgroundColor: Colors.white,
      isHighlighted: false,
      category: _NotificationCategory.all,
      routeName: RouteName.dashboard,
    ),
  ];

  static const List<
    ({String label, _NotificationCategory category, bool enabled})
  >
  _tabs = [
    (label: 'All', category: _NotificationCategory.all, enabled: true),
    (label: 'Events', category: _NotificationCategory.events, enabled: true),
    (
      label: 'Appointment',
      category: _NotificationCategory.appointment,
      enabled: true,
    ),
    (
      label: 'Messages',
      category: _NotificationCategory.messages,
      enabled: true,
    ),
    (label: 'Payment', category: _NotificationCategory.payment, enabled: false),
  ];

  late _NotificationCategory _selectedTopTab;

  @override
  void initState() {
    super.initState();
    _selectedTopTab = _NotificationCategory.all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Color(0xFF007AFF),
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Reminders',
            onPressed: () {
              Navigator.pushNamed(context, RouteName.reminder);
            },
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Color(0xFF007AFF),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFD1D5DB),
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildNotificationList(context)),
          Container(
            height: 5,
            width: 134,
            margin: const EdgeInsets.only(bottom: 8, top: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            _tabs
                .map(
                  (tab) => _buildTab(
                    label: tab.label,
                    category: tab.category,
                    enabled: tab.enabled,
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildNotificationList(BuildContext context) {
    final visibleNotifications =
        _selectedTopTab == _NotificationCategory.all
            ? _notifications
            : _notifications
                .where((item) => item.category == _selectedTopTab)
                .toList();

    if (visibleNotifications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'This category will open up when its feature area is built.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children:
          visibleNotifications
              .map(
                (item) => _buildNotificationItem(
                  context: context,
                  icon: item.icon,
                  title: item.title,
                  subtitle: item.subtitle,
                  backgroundColor: item.backgroundColor,
                  isHighlighted: item.isHighlighted,
                  routeName: item.routeName,
                ),
              )
              .toList(),
    );
  }

  Widget _buildTab({
    required String label,
    required _NotificationCategory category,
    required bool enabled,
  }) {
    final isSelected = _selectedTopTab == category;
    return Expanded(
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: InkWell(
          onTap:
              enabled
                  ? () {
                    setState(() {
                      _selectedTopTab = category;
                    });
                  }
                  : null,
          splashColor: Colors.grey[200]?.withValues(alpha: 0.3),
          hoverColor: Colors.grey[100]?.withValues(alpha: 0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color:
                        !enabled
                            ? const Color(0xFF9CA3AF)
                            : isSelected
                            ? const Color(0xFF007AFF)
                            : Colors.black,
                    letterSpacing: -0.08,
                  ),
                ),
              ),
              Container(
                height: 2,
                color:
                    enabled && isSelected
                        ? const Color(0xFF007AFF)
                        : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required bool isHighlighted,
    String? routeName,
  }) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border:
            isHighlighted
                ? Border.all(color: const Color(0xFF93C5FD), width: 1)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighlighted ? Colors.white : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: -0.24,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                    letterSpacing: -0.08,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (routeName != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
          ],
        ],
      ),
    );

    if (routeName == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, routeName),
        child: card,
      ),
    );
  }
}
