import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:provider/single_child_widget.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// NagaSai Imports
import 'package:graduway/app.dart';

// Rajesh Imports
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/alumni/shared/providers/chat_provider.dart';
import 'package:graduway/alumni/shared/providers/mentorship_provider.dart';
import 'package:graduway/alumni/shared/providers/notification_provider.dart';
import 'package:graduway/alumni/shared/providers/ui_provider.dart';
import 'package:graduway/admin/shared/providers/admin_provider.dart';

/// Global HTTP overrides to allow self-signed certificates (OpenShift routes)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  // Required before any async call in main()
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
  }
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found. Ensure it exists at the root.");
  }

  // Resolve the backend server IP BEFORE the app renders
  await AuthProvider.resolveServerIp();

  // Rajesh's Provider List
  final List<SingleChildWidget> legacyProviders = [
    legacy_provider.ChangeNotifierProvider(create: (_) => AuthProvider()),
    legacy_provider.ChangeNotifierProvider(create: (_) => ChatProvider()),
    legacy_provider.ChangeNotifierProvider(create: (_) => NotificationProvider()),
    legacy_provider.ChangeNotifierProvider(create: (_) => UIProvider()),
    legacy_provider.ChangeNotifierProvider(create: (_) => AdminProvider()),

    legacy_provider.ChangeNotifierProxyProvider2<ChatProvider, AuthProvider, MentorshipProvider>(
      create: (_) => MentorshipProvider(),
      update: (_, chat, auth, mentorship) => (mentorship ?? MentorshipProvider())
        ..setChatProvider(chat)
        ..syncWithAuth(auth),
    ),
  ];

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => ProviderScope(
        child: legacy_provider.MultiProvider(
          providers: legacyProviders,
          child: const GraduWayApp(),
        ),
      ),
    ),
  );
}
