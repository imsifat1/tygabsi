import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/tyg_absi/presentation/splash_screen.dart';
import 'theme/app_theme.dart';
import 'features/tyg_absi/presentation/tyg_absi_screen.dart';

void main() {
  runApp(const ProviderScope(child: TygAbsiApp()));
}

class TygAbsiApp extends StatelessWidget {
  const TygAbsiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TyG-ABSI',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AnimatedSplashScreen(),
    );
  }
}
