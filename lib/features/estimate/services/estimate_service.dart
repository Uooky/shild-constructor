import 'package:shild_constructor/features/catalog/domain/models/equipment_item.dart';
import 'package:shild_constructor/features/estimate/domain/models/estimate.dart';

class EstimateService {
  Estimate build({
    required String projectId,
    required List<EquipmentItem> items,
    double markupPercent = 15,
    double discountPercent = 5,
  }) {
    final lines = <EstimateLine>[];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      lines.add(
        EstimateLine(
          id: '${item.id}_$i',
          equipmentId: item.id,
          name: item.name,
          quantity: 1,
          unitPrice: item.price,
          lineTotal: item.price,
        ),
      );
    }

    final subtotal = lines.fold<double>(0, (sum, line) => sum + line.lineTotal);
    final markup = subtotal * (markupPercent / 100);
    final discount = subtotal * (discountPercent / 100);
    final total = subtotal + markup - discount;

    return Estimate(
      id: 'estimate_$projectId',
      projectId: projectId,
      subtotal: subtotal,
      markupPercent: markupPercent,
      discountPercent: discountPercent,
      lines: lines,
      total: total,
    );
  }
}
