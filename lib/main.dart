import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:remainder_portal/presentation/screens/splash_screen.dart';
import 'package:remainder_portal/app/theme/portal_theme.dart';
import 'package:remainder_portal/data/services/monitoring_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
    print("🔥 Firebase App Check activated successfully.");
  } catch (e) {
    print("⚠️ Firebase initialization bypassed (running in local offline development mode): $e");
  }

  // Initialize monitoring (Crashlytics/Performance)
  await MonitoringService().initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Remainder Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF8F6F0),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFB8860B),
          secondary: Color(0xFF007791),
          surface: Color(0xFFFFFFFF),
        ),
        extensions: <ThemeExtension<dynamic>>[
          PortalTheme.dark(),
        ],
      ),
      home: const SplashScreen(),
    );
  }
}
