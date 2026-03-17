import 'package:alumini_screen/src/providers/auth_provider.dart';
import 'package:alumini_screen/src/providers/mentorship_provider.dart';
import 'package:alumini_screen/src/providers/chat_provider.dart';
import 'package:alumini_screen/src/providers/notification_provider.dart';
import 'package:alumini_screen/src/providers/ui_provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alumini_screen/src/pages/features/Auth/login_page.dart';

void main() {
  final providers = [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => MentorshipProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ChangeNotifierProvider(create: (_) => UIProvider()),
  ];

  if (kIsWeb) {
    runApp(DevicePreview(
      builder: (context) => MultiProvider(
        providers: providers,
        child: const MyApp(),
      ),
    ));
  } else {
    runApp(MultiProvider(
      providers: providers,
      child: const MyApp(),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}