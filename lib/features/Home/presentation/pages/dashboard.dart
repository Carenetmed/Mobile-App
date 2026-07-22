import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/data/models/auth_session_model.dart';
import 'package:app_t/features/Authentication/data/storage/session_store.dart';
import 'package:app_t/features/Home/data/repositories/profile_repository.dart';
import 'package:app_t/features/Home/data/repositories/scheduling_repository.dart';
import 'package:app_t/features/Home/presentation/pages/appointments_shell.dart';
import 'package:app_t/features/Home/presentation/pages/home.dart';
import 'package:app_t/features/Home/presentation/pages/search_shell.dart';
import 'package:app_t/features/Home/presentation/pages/selected_dates_shell.dart';
import 'package:app_t/features/Messaging/presentation/pages/Messages.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    this.sessionStore,
    this.profileRepository,
    this.schedulingRepository,
  });

  final SessionStore? sessionStore;
  final ProfileRepository? profileRepository;
  final SchedulingRepository? schedulingRepository;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late final Future<AuthSessionModel?> _sessionFuture;
  int _index = 0;
  final Set<int> _builtIndices = <int>{0};

  SessionStore get _sessionStore => widget.sessionStore ?? sl<SessionStore>();

  @override
  void initState() {
    super.initState();
    _sessionFuture = _sessionStore.read();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthSessionModel?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = _resolvedRole(snapshot.data);
        if (role == null) {
          return const _UnavailableRolePage();
        }

        final destinations = _destinations(role);
        if (_index >= destinations.length) {
          _index = 0;
        }
        final selected = destinations[_index];

        return PopScope(
          canPop: _index == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _index != 0) {
              _selectIndex(0);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.kWhite,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: Text(
                selected.label,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontSize: FontSizes.body2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Notifications',
                  onPressed:
                      () =>
                          Navigator.pushNamed(context, RouteName.notification),
                  icon: const Icon(Icons.notifications_outlined),
                ),
                IconButton(
                  tooltip: 'Account',
                  onPressed:
                      () => Navigator.pushNamed(context, RouteName.account),
                  icon: const Icon(Icons.account_circle_outlined),
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: IndexedStack(
              index: _index,
              children: destinations.indexed
                  .map(
                    (entry) =>
                        _builtIndices.contains(entry.$1)
                            ? entry.$2.builder()
                            : const SizedBox.shrink(),
                  )
                  .toList(growable: false),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.kWhite,
              selectedItemColor: AppColors.primaryBlue11,
              unselectedItemColor: AppColors.kBlack,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: TextStyle(
                fontSize: FontSizes.footer1,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.montserrat,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: FontSizes.footer1,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.montserrat,
              ),
              currentIndex: _index,
              onTap: _selectIndex,
              items: destinations
                  .map(
                    (destination) => BottomNavigationBarItem(
                      label: destination.label,
                      icon: Icon(destination.icon),
                      activeIcon: Icon(destination.activeIcon),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        );
      },
    );
  }

  void _selectIndex(int index) {
    setState(() {
      _index = index;
      _builtIndices.add(index);
    });
  }

  _DashboardRole? _resolvedRole(AuthSessionModel? session) {
    if (session == null ||
        session.accessToken.trim().isEmpty ||
        session.refreshToken.trim().isEmpty ||
        session.user.id.trim().isEmpty) {
      return null;
    }

    return switch (session.user.role.trim().toUpperCase()) {
      'PATIENT' => _DashboardRole.patient,
      'PROFESSIONAL' => _DashboardRole.professional,
      _ => null,
    };
  }

  List<_DashboardDestination> _destinations(_DashboardRole role) {
    final professional = role == _DashboardRole.professional;
    return <_DashboardDestination>[
      _DashboardDestination(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        builder:
            () => Home(
              isProfessional: professional,
              onPrimaryAction: () => _selectIndex(1),
              onAppointments: () => _selectIndex(2),
            ),
      ),
      _DashboardDestination(
        label: professional ? 'Schedule' : 'Find Care',
        icon:
            professional
                ? Icons.calendar_month_outlined
                : Icons.search_outlined,
        activeIcon: professional ? Icons.calendar_month : Icons.manage_search,
        builder:
            () =>
                professional
                    ? SelectedDatesShellPage(
                      schedulingRepository: widget.schedulingRepository,
                      embedded: true,
                    )
                    : SearchShellPage(
                      profileRepository: widget.profileRepository,
                      schedulingRepository: widget.schedulingRepository,
                    ),
      ),
      _DashboardDestination(
        label: 'Appointments',
        icon: Icons.event_note_outlined,
        activeIcon: Icons.event_note,
        builder:
            () => AppointmentsShellPage(
              schedulingRepository: widget.schedulingRepository,
              sessionStore: _sessionStore,
              embedded: true,
            ),
      ),
      const _DashboardDestination(
        label: 'Messages',
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        builder: _embeddedMessages,
      ),
    ];
  }

  static Widget _embeddedMessages() {
    return const MessagesPage(embedded: true);
  }
}

enum _DashboardRole { patient, professional }

class _DashboardDestination {
  const _DashboardDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.builder,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget Function() builder;
}

class _UnavailableRolePage extends StatelessWidget {
  const _UnavailableRolePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_person_outlined, size: 40),
                const SizedBox(height: 16),
                Text(
                  'Your account role is unavailable.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please sign in again so CareNet can load the correct workspace.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
