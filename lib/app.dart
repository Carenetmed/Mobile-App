import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/constants/navigators/router.dart';
import 'package:app_t/core/constants/strings.dart';
import 'package:app_t/core/theme/bloc/theme_bloc.dart';
import 'package:app_t/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Root widget for the CareNet app. Routing is configured here only.
class CarenetApp extends StatelessWidget {
  const CarenetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => ThemeBloc())],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return ScreenUtilInit(
            useInheritedMediaQuery: true,
            minTextAdapt: true,
            splitScreenMode: true,
            ensureScreenSize: true,
            designSize: const Size(430, 932),
            builder: (context, child) {
              return MaterialApp(
                title: Strings.appName,
                debugShowCheckedModeBanner: false,
                themeMode: themeMode,
                theme: lightTheme,
                darkTheme: darkTheme,
                initialRoute: RouteName.splash,
                onGenerateRoute: generateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
