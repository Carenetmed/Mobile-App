import 'dart:async';

import 'package:app_t/core/presentation/carenet_presentation.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await CareNetPresentation.initialize();
  await testMain();
}
