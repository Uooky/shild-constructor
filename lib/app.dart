import 'package:flutter/material.dart';
import 'package:shild_constructor/screens/home_screen.dart';

class ShildConstructorApp extends StatelessWidget {
  const ShildConstructorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shild Constructor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2557D6)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: const HomeScreen(),
    );
  }
}
