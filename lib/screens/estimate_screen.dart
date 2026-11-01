import 'package:flutter/material.dart';

class EstimateScreen extends StatelessWidget {
  const EstimateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {'name': 'Автомат 1P', 'qty': 4, 'price': 350.0},
      {'name': 'Автомат 2P', 'qty': 2, 'price': 620.0},
      {'name': 'УЗО 2P', 'qty': 1, 'price': 890.0},
      {'name': 'Клеммник', 'qty': 3, 'price': 280.0},
    ];

    final subtotal = data.fold<double>(
      0,
      (sum, item) => sum + (item['qty'] as int) * (item['price'] as double),
    );

    final markup = subtotal * 0.15;
    final discount = subtotal * 0.05;
    final total = subtotal + markup - discount;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.calculate_rounded),
                SizedBox(width: 10),
                Text('Смета проекта', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  for (final item in data)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(child: Text(item['name'] as String)),
                          Text('${item['qty']}'),
                          const SizedBox(width: 18),
                          Text('${(item['price'] as double).toStringAsFixed(0)} ₽'),
                        ],
                      ),
                    ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Подытог'),
                      Text('${subtotal.toStringAsFixed(0)} ₽'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Наценка 15%'),
                      Text('${markup.toStringAsFixed(0)} ₽'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Скидка 5%'),
                      Text('${discount.toStringAsFixed(0)} ₽'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Итого', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('${total.toStringAsFixed(0)} ₽', style: const TextStyle(fontWeight: FontWeight.w700)),
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
