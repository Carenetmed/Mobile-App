import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- Application Entry Point ---
void main() {
  runApp(const MyApp());
}

// --- Application Wrapper (The Root Widget) ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carenet Health',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Text',
      ),
      home: const MessagesPage(),
    );
  }
}

// --- The Page Widget (Messages Page) ---
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late String _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = 'Messages';
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
          onPressed: () {},
        ),
        title: const Text(
          'Messages',
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
                _buildMessageCard(
                  'Dr. Lagbaja has replied your message.',
                  'Reply him now',
                ),
              ],
            ),
          ),
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
            _buildTab('All'),
            _buildTab('Events'),
            _buildTab('Appointment'),
            _buildTab('Messages'),
            _buildTab('Payment'),
        ],
      ),
    );
  }

    Widget _buildTab(String text) {
      final isSelected = _selectedTab == text;
    return Expanded(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedTab = text;
              });
            },
            splashColor: Colors.grey[200]?.withOpacity(0.3),
            hoverColor: Colors.grey[100]?.withOpacity(0.5),
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
          ),
        ),
    );
  }

  Widget _buildMessageCard(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFD1D5DB),
            child: const Icon(Icons.person, size: 24, color: Colors.white),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
