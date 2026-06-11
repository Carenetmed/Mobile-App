import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/pages/circles_shell.dart';
import 'package:app_t/features/Home/presentation/pages/home.dart';
import 'package:app_t/features/Home/presentation/pages/post_shell.dart';
import 'package:app_t/features/Home/presentation/pages/search_shell.dart';
import 'package:app_t/features/Messaging/presentation/pages/Notification.dart';
import 'package:app_t/features/Home/presentation/widget/drawer.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late int _index;

  final Map<String, Widget> navItems = {
    "Home": SvgImage(imgName: AssetsIcon.home),
    "Search": SvgImage(imgName: AssetsIcon.searchOutline),
    "Post": SvgImage(imgName: AssetsIcon.add),
    "Circles": SvgImage(imgName: AssetsIcon.sunny),
    "Notifications": const Icon(Icons.notifications_outlined),
  };

  @override
  void initState() {
    super.initState();
    _index = 0;
  }

  List<Widget> navBarView = [
    const Home(),
    const SearchShellPage(),
    const PostShellPage(),
    const CirclesShellPage(),
    const NotificationsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CarenetDraw(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.kWhite,
        selectedItemColor: AppColors.primaryBlue11,
        unselectedItemColor: AppColors.kBlack,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontSize: FontSizes.footer1,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.montserrat,
          color: AppColors.primaryBlue11,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: FontSizes.footer1,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.montserrat,
          color: AppColors.kBlack,
        ),
        currentIndex: _index,
        onTap: (index) {
          setState(() => _index = index);
        },
        items: [
          ...navItems.entries.map(
            (item) =>
                BottomNavigationBarItem(label: item.key, icon: item.value),
          ),
        ],
      ),
      body: navBarView[_index],
    );
  }
}
