import 'package:flutter/material.dart';
import 'package:shild_constructor/screens/estimate_screen.dart';
import 'package:shild_constructor/screens/export_screen.dart';
import 'package:shild_constructor/screens/project_screen.dart';
import 'package:shild_constructor/screens/version_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final screens = const [
    ProjectScreen(),
    EstimateScreen(),
    ExportScreen(),
    VersionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shild Constructor'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_rounded),
            label: const Text('Сохранить'),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('PDF'),
          ),
        ],
      ),
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.design_services_rounded), label: 'Проект'),
          NavigationDestination(icon: Icon(Icons.calculate_rounded), label: 'Смета'),
          NavigationDestination(icon: Icon(Icons.file_download_rounded), label: 'Экспорт'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'Версии'),
        ],
      ),
    );
  }
}
