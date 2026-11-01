import 'package:flutter/material.dart';

class VersionScreen extends StatelessWidget {
  const VersionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final versions = [
      {'label': 'v1', 'comment': 'Начальный проект', 'date': '31.10.2026', 'auto': false},
      {'label': 'auto-1', 'comment': 'Автосохранение после добавления модулей', 'date': '31.10.2026', 'auto': true},
      {'label': 'v2', 'comment': 'Скорректирована прокладка проводов', 'date': '31.10.2026', 'auto': false},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Версии проекта', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            for (final item in versions)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: (item['auto'] as bool) ? Colors.orange.shade100 : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item['auto'] as bool ? Icons.auto_awesome_rounded : Icons.history_rounded,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['label'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(item['comment'] as String, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(item['date'] as String, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
