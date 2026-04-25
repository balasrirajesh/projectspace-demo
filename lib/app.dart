import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'package:graduway/routing/app_router.dart';
import 'package:graduway/theme/app_theme.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:graduway/alumni/shared/providers/auth_provider.dart';
import 'package:graduway/providers/app_providers.dart';

class GraduWayApp extends ConsumerStatefulWidget {
  const GraduWayApp({super.key});

  @override
  ConsumerState<GraduWayApp> createState() => _GraduWayAppState();
}

class _GraduWayAppState extends ConsumerState<GraduWayApp> {
  @override
  void initState() {
    super.initState();
    // Schedule a sync after the first frame to catch initial state
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  void _sync() {
    if (!mounted) return;
    final legacyAuth = legacy.Provider.of<AuthProvider>(context, listen: false);
    ref.read(authProvider.notifier).syncWithLegacy(legacyAuth);
    
    // Add a listener for future changes
    legacyAuth.addListener(() {
      if (mounted) {
        ref.read(authProvider.notifier).syncWithLegacy(legacyAuth);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'GraduWay — Aditya College',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}
