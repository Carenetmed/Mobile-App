import 'package:get_it/get_it.dart';

/// Global service locator. Register dependencies here as features are built.
final GetIt sl = GetIt.instance;

/// Call once from [main] before [runApp].
Future<void> configureDependencies() async {
  // Phase 0: locator ready. Phase 2+ will register ApiService, repositories, etc.
}
