import 'package:flutter/material.dart';
import 'package:shild_constructor/screens/estimate_screen.dart';
import 'package:shild_constructor/screens/export_screen.dart';
import 'package:shild_constructor/screens/project_screen.dart';
import 'package:shild_constructor/screens/schematic_editor_screen.dart';
import 'package:shild_constructor/screens/version_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final screens = const [ProjectScreen(), SchematicEditorScreen(), EstimateScreen(), ExportScreen(), VersionScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Shild Constructor')),
    body: IndexedStack(index: _index, children: screens),
    bottomNavigationBar: NavigationBar(selectedIndex: _index, onDestinationSelected: (value) => setState(() => _index = value), destinations: const [
      NavigationDestination(icon: Icon(Icons.design_services_rounded), label: 'Проект'),
      NavigationDestination(icon: Icon(Icons.schema_outlined), label: 'Схема'),
      NavigationDestination(icon: Icon(Icons.calculate_rounded), label: 'Смета'),
      NavigationDestination(icon: Icon(Icons.file_download_rounded), label: 'Экспорт'),
      NavigationDestination(icon: Icon(Icons.history_rounded), label: 'Версии'),
    ]),
  );
}
