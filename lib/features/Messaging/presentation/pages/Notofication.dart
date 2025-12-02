import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
          onPressed: () {},
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildNotificationItem(
                  Icons.calendar_today_outlined,
                  'Your appointment is booked',
                  'See details',
                  Colors.white,
                  false,
                ),
                _buildNotificationItem(
                  Icons.person_outline,
                  'Complete your profile',
                  'You are 30% done. Complete to get more personalized feed',
                  const Color(0xFFBFDBFE),
                  true,
                ),
                _buildNotificationItem(
                  Icons.wb_sunny_outlined,
                  'Your Circle request is approved',
                  'You are now a member of Early Riser Elite Club',
                  Colors.white,
                  false,
                ),
                _buildNotificationItem(
                  Icons.calendar_today_outlined,
                  '360 Club event is coming up today by 6pm',
                  'You subscribed to this event. See details to not miss it',
                  const Color(0xFFBFDBFE),
                  true,
                ),
                _buildNotificationItem(
                  Icons.mail_outline,
                  'Dr. Lagbaja has replied your message.',
                  'Reply him now',
                  Colors.white,
                  false,
                ),
                _buildNotificationItem(
                  Icons.calendar_today_outlined,
                  'It\'s Dr. Uzo\'s Birthday today.',
                  'Wish her well!',
                  Colors.white,
                  false,
                ),
                _buildNotificationItem(
                  Icons.people_outline,
                  '5 Specialists are having free consultations now',
                  'Take advantage',
                  Colors.white,
                  false,
                ),
                _buildNotificationItem(
                  Icons.article_outlined,
                  'Dr. Tamedu has published a new article',
                  'Read now',
                  Colors.white,
                  false,
                ),
                _buildNotificationItem(
                  Icons.info_outline,
                  'Your emergency request is approved.',
                  'Ambulance is on the way!',
                  Colors.white,
                  false,
                ),
                _buildNotificationItem(
                  Icons.description_outlined,
                  'Update your reading, its been 5 days already',
                  'Connect your bluetooth or manually update reading',
                  Colors.white,
                  false,
                ),
                _buildNotificationItem(
                  Icons.mic_none,
                  'Dr. Lakasegbe has published a new podcast',
                  'Listen now',
                  Colors.white,
                  false,
                ),
                _buildNotificationItem(
                  Icons.add_box_outlined,
                  'You are missing updates',
                  'Open feed, see what people are saying and tell us your mind!',
                  Colors.white,
                  false,
                ),
              ],
            ),
          ),
          _buildBottomNavigationBar(),
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
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTab('All', true),
          _buildTab('Events', false),
          _buildTab('Appointment', false),
          _buildTab('Messages', false),
          _buildTab('Payment', false),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF007AFF) : Colors.black,
                letterSpacing: -0.08,
              ),
            ),
          ),
          Container(
            height: 2,
            color: isSelected ? const Color(0xFF007AFF) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    IconData icon,
    String title,
    String subtitle,
    Color backgroundColor,
    bool isHighlighted,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: const Color(0xFF93C5FD), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            child: Icon(
              icon,
              size: 20,
              color: Colors.black,
            ),
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
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false),
          _buildNavItem(Icons.search, 'Search', false),
          _buildNavItem(Icons.article_outlined, 'Articles', false),
          _buildNavItem(Icons.calendar_today_outlined, 'Appointments', false),
          _buildNavItem(Icons.notifications_outlined, 'Alert', true),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: isSelected ? const Color(0xFF007AFF) : Colors.black,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: isSelected ? const Color(0xFF007AFF) : Colors.black,
            letterSpacing: -0.08,
          ),
        ),
      ],
    );
  }
}
