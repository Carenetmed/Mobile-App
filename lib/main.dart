import 'package:app_t/core/theme/bloc/theme_bloc.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_email.dart';
import 'package:app_t/features/Authentication/presentation/pages/sign_in_phone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/constants/navigators/routeName.dart';
import 'core/constants/navigators/router.dart';
import 'core/constants/strings.dart';
import 'core/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MultiBlocProvider(
        providers: [BlocProvider(create: (context) => ThemeBloc())],
        child: BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, state) {
            return ScreenUtilInit(
              useInheritedMediaQuery: true,
              minTextAdapt: true,
              splitScreenMode: true,
              ensureScreenSize: true,
              designSize: const Size(430, 932),
              builder: (BuildContext context, Widget? child) {
                return MaterialApp(
                  title: Strings.appName,
                  debugShowCheckedModeBanner: false,
                  themeMode: state,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  home: SignInEmail(),
                  // onGenerateRoute: generateRoute,
                  // initialRoute: RouteName.splash,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
