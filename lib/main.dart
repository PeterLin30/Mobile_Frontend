import 'package:flutter/material.dart';

import 'pages/profile_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MikroHubApp());
}

class MikroHubApp extends StatelessWidget {
  const MikroHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MikroHub UMKM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5CC8CC),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Color(0xFF202124),
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}
