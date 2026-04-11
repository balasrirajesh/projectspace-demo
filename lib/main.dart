import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:device_preview/device_preview.dart';
import 'package:alumini_screen/src/shared/providers/auth_provider.dart';
import 'package:alumini_screen/src/shared/providers/mentorship_provider.dart';
import 'package:alumini_screen/src/shared/providers/chat_provider.dart';
import 'package:alumini_screen/src/shared/providers/notification_provider.dart';
import 'package:alumini_screen/src/shared/providers/ui_provider.dart';
import 'package:alumini_screen/src/features/auth/login_page.dart';
import 'package:alumini_screen/src/core/theme/app_theme.dart';

/// Entry point of the application.
void main() async {
  // Required before any async call in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Resolve the backend server IP BEFORE the app renders, so login()
  // always has the correct address ready.
  await AuthProvider.resolveServerIp();

  final List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ChangeNotifierProvider(create: (_) => UIProvider()),

    // MentorshipProvider depends on ChatProvider
    ChangeNotifierProxyProvider<ChatProvider, MentorshipProvider>(
      create: (_) => MentorshipProvider(),
      update: (_, chat, mentorship) => (mentorship ?? MentorshipProvider())..setChatProvider(chat),
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
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}