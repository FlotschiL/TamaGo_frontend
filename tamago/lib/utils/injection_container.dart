import 'package:get_it/get_it.dart';
import 'package:tamago/utils/api_manager.dart'; // Your ApiClient file
import 'package:flutter/material.dart';
import 'injection_container.dart' as di;
import 'package:tamago/pages/living.dart'; // Your ApiClient file
final sl = GetIt.instance; // sl stands for Service Locator

void init() {
  // Register ApiClient as a Singleton (only one instance exists)
  sl.registerLazySingleton(() => ApiClient());
}
void main() { 
  // Initialize dependency injection
  di.init(); 
  runApp(const LivingRoomPage());
}