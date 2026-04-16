import 'dart:io';
import 'package:alumini_screen/src/alumni/shared/core/theme/app_theme.dart';
import 'package:alumini_screen/src/alumni/shared/providers/auth_provider.dart';
import 'package:alumini_screen/src/alumni/shared/providers/chat_provider.dart';
import 'package:alumini_screen/src/alumni/shared/providers/mentorship_provider.dart';
import 'package:alumini_screen/src/alumni/shared/providers/notification_provider.dart';
import 'package:alumini_screen/src/alumni/shared/providers/ui_provider.dart';
import 'package:alumini_screen/src/admin/shared/providers/admin_provider.dart';
import 'package:alumini_screen/src/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:alumini_screen/src/login/auth_dispatcher.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Global HTTP overrides to allow self-signed certificates (OpenShift routes)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

/// Entry point of the application.
void main() async {
  // Required before any async call in main()
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Resolve the backend server IP BEFORE the app renders, so login()
  // always has the correct address ready.
  await AuthProvider.resolveServerIp();

  final List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ChangeNotifierProvider(create: (_) => UIProvider()),
    ChangeNotifierProvider(create: (_) => AdminProvider()),

    // MentorshipProvider depends on ChatProvider and AuthProvider for ID-aware fetching
    ChangeNotifierProxyProvider2<ChatProvider, AuthProvider, MentorshipProvider>(
      create: (_) => MentorshipProvider(),
      update: (_, chat, auth, mentorship) => (mentorship ?? MentorshipProvider())
        ..setChatProvider(chat)
        ..syncWithAuth(auth),
    ),
  ];

  if (kIsWeb) {
    runApp(DevicePreview(
      enabled: true,
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
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Alumni Connect',
      theme: AppTheme.lightTheme,
      home: const AuthDispatcher(),
      routes: {
        '/home': (context) => const AuthDispatcher(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}