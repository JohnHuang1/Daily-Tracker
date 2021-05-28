import 'package:daily_tracker/services/authentication_service.dart';
import 'package:daily_tracker/services/dialog_service.dart';
import 'package:daily_tracker/services/firestore_service.dart';
import 'package:daily_tracker/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => FirestoreService());
}