import 'package:flutter/material.dart';

class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      ['Название проекта', 'Квартира 72/2'],
      ['Объект', 'ЖК «Лесная Поляна»'],
      ['Дата', '31.10.2026'],
      ['Автор', 'Иван Петров'],
      ['Щит', 'ЩМП-12'],
      ['Смета', '74 000 ₽'],
      ['Расчёты', 'Проверены'],
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
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
                  const Text('Экспорт в PDF', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('PDF включает титульный лист, монтажный чертёж, спецификацию, смету и результаты расчётов.'),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('Экспортировать отчёт'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(1.8),
                },
                children: [
                  for (final row in data)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(row[0], style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(row[1]),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
