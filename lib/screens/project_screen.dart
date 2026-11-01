import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shild_constructor/features/catalog/domain/models/equipment_item.dart';
import 'package:shild_constructor/features/shield_editor/domain/models/shield_scene.dart';
import 'package:shild_constructor/services/pdf_export_service.dart';
import 'package:shild_constructor/services/project_state_provider.dart';

class ProjectScreen extends ConsumerStatefulWidget {
  const ProjectScreen({super.key});

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  String activeTool = 'select';
  bool gridVisible = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectControllerProvider);
    final selectedModule = state.scene.modules.firstWhereOrNull(
      (m) => m.id == state.selectedModuleId,
    );

    final wireLength = state.scene.wires.fold<double>(
      0,
      (sum, wire) => sum + _wireLength(wire.nodes),
    );

    final fillPercent = (state.scene.modules.length / 72.0) * 100.0;

    final catalog = [
      EquipmentItem(
        id: '1',
        name: 'Автомат 1P',
        manufacturer: 'IEK',
        article: 'C25',
        widthModules: 1,
        price: 350,
        colorValue: 0xFF4CAF50,
      ),
      EquipmentItem(
        id: '2',
        name: 'Автомат 2P',
        manufacturer: 'ABB',
        article: 'C40',
        widthModules: 2,
        price: 620,
        colorValue: 0xFF2196F3,
      ),
      EquipmentItem(
        id: '3',
        name: 'УЗО 2P',
        manufacturer: 'Schneider',
        article: 'F204',
        widthModules: 2,
        price: 890,
        colorValue: 0xFFFFA000,
      ),
      EquipmentItem(
        id: '4',
        name: 'Клеммник',
        manufacturer: 'DEKraft',
        article: 'KLM-12',
        widthModules: 2,
        price: 280,
        colorValue: 0xFF7E57C2,
      ),
    ];

    return Row(
      children: [
        Container(
          width: 280,
          color: Colors.white,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Поиск оборудования',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              for (final item in catalog)
                GestureDetector(
                  onTap: () {
                    final module = ShieldModule(
                      id: 'mod_${DateTime.now().microsecondsSinceEpoch}',
                      catalogId: item.id,
                      name: item.name,
                      type: ModuleType.breaker,
                      x: 260 + state.scene.modules.length * 22,
                      y: 230 + state.scene.modules.length * 16,
                      widthModules: item.widthModules,
                      height: 90,
                      colorValue: item.colorValue,
                    );

                    ref.read(projectControllerProvider.notifier).addModule(module);
                    ref.read(projectControllerProvider.notifier).selectModule(module.id);
                  },
                  child: Container(
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
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.electrical_services_rounded, color: Colors.white, size: 17),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text('${item.manufacturer} • ${item.article}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Text('${item.widthModules.toStringAsFixed(0)} mod', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTapDown: (details) {
              final local = details.localPosition;

              if (activeTool == 'note') {
                final note = NoteItem(
                  id: 'note_${DateTime.now().microsecondsSinceEpoch}',
                  text: 'Заметка',
                  x: local.dx,
                  y: local.dy,
                  alignment: NoteAlignment.left,
                  colorValue: 0xFF1F2937,
                );

                ref.read(projectControllerProvider.notifier).addNote(note);
                ref.read(projectControllerProvider.notifier).selectNote(note.id);
                return;
              }

              if (activeTool == 'wire') {
                final wire = WirePath(
                  id: 'wire_${DateTime.now().microsecondsSinceEpoch}',
                  wireType: 'phase',
                  material: WireMaterial.copper,
                  nodes: [
                    WireNode(x: local.dx, y: local.dy),
                    WireNode(x: local.dx + 100, y: local.dy + 70),
                    WireNode(x: local.dx + 200, y: local.dy + 30),
                  ],
                  calculatedLengthMm: 180,
                  zoneName: 'Основная зона',
                );

                ref.read(projectControllerProvider.notifier).addWire(wire);
                ref.read(projectControllerProvider.notifier).selectWire(wire.id);
                return;
              }

              if (activeTool == 'delete') {
                ref.read(projectControllerProvider.notifier).removeSelected();
                return;
              }

              if (activeTool == 'select') {
                for (final module in state.scene.modules) {
                  final hitX = (local.dx - module.x).abs() <= module.widthModules * 18;
                  final hitY = (local.dy - module.y).abs() <= module.height / 2;
                  if (hitX && hitY) {
                    ref.read(projectControllerProvider.notifier).selectModule(module.id);
                    return;
                  }
                }
              }
            },
            onPanUpdate: (details) {
              if (activeTool == 'move' && selectedModule != null) {
                ref.read(projectControllerProvider.notifier).moveModule(
                      selectedModule.id,
                      details.delta.dx,
                      details.delta.dy,
                    );
              }
            },
            child: Container(
              color: const Color(0xFFF5F7FB),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BoardPainter(
                        scene: state.scene,
                        selectedModuleId: state.selectedModuleId,
                        selectedWireId: state.selectedWireId,
                        selectedNoteId: state.selectedNoteId,
                        gridVisible: gridVisible,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Заполнение: ${fillPercent.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 18,
                    top: 18,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => gridVisible = !gridVisible),
                      icon: const Icon(Icons.grid_on_rounded),
                      label: Text(gridVisible ? 'Сетка ON' : 'Сетка OFF'),
                    ),
                  ),
                  Positioned(
                    right: 18,
                    top: 60,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text('Инструмент: $activeTool'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 330,
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Свойства', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Divider(),
              if (selectedModule != null) ...[
                Text('Выбран: ${selectedModule.name}', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _PropertyRow('X', selectedModule.x.round().toString()),
                _PropertyRow('Y', selectedModule.y.round().toString()),
                _PropertyRow('Ширина', selectedModule.widthModules.toStringAsFixed(1)),
                _PropertyRow('Высота', selectedModule.height.toStringAsFixed(0)),
                const Divider(),
                const Text('Параметры', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const _PropertyRow('Тип', 'автомат'),
                const _PropertyRow('Ток', '25 A'),
                const _PropertyRow('Положение', 'DIN-рейка'),
              ] else if (state.selectedWireId != null) ...[
                const Text('Выбран провод'),
                const SizedBox(height: 8),
                const _PropertyRow('Тип', 'phase'),
                const _PropertyRow('Материал', 'медь'),
                const _PropertyRow('Зона', 'основная'),
              ] else if (state.selectedNoteId != null) ...[
                const Text('Выбрана заметка'),
              ] else ...[
                const Text('Ничего не выбрано'),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F9FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Итоги', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text('Длина проводов: ${wireLength.toStringAsFixed(0)} мм'),
                    Text('Тепловые потери: ${(state.scene.modules.length * 0.12).toStringAsFixed(2)} кВт'),
                    Text('КЗ: ${(6.4 + state.scene.modules.length * 0.04).toStringAsFixed(2)} кА'),
                    Text('Смета: ${state.estimate.total.toStringAsFixed(0)} ₽'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final savedPath = await ref.read(projectControllerProvider.notifier).saveCurrentProject();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Сохранено: $savedPath')),
                          );
                        }
                      },
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Сохранить'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final path = await _inputPath(context);
                        if (path == null || path.isEmpty) return;

                        final project = await ref.read(projectControllerProvider.notifier).openProjectAtPath(path);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(project == null ? 'Не удалось открыть файл' : 'Открыт: ${project.name}'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.folder_open_rounded),
                      label: const Text('Открыть'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final pdf = PdfExportService();
                        final file = await pdf.exportProject(
                          projectName: state.project.name,
                          objectName: state.project.objectName ?? 'Не указан',
                          author: state.project.author ?? 'Не указан',
                          dateText: DateTime.now().toLocal().toString(),
                          drawingSummary: 'Монтажный чертёж: ${state.scene.modules.length} модулей, ${state.scene.wires.length} проводов',
                          equipmentSummary: state.scene.modules.map((m) => m.name).join(', '),
                          estimateSummary: 'Сумма проекта: ${state.estimate.total.toStringAsFixed(0)} ₽',
                          calculationsSummary: 'Заполнение: ${fillPercent.toStringAsFixed(1)}%\nДлина проводов: ${wireLength.toStringAsFixed(0)} мм\nКЗ: ${(6.4 + state.scene.modules.length * 0.04).toStringAsFixed(2)} кА',
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('PDF создан: ${file.path}')),
                          );
                        }
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text('Экспорт PDF'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<String?> _inputPath(BuildContext context) async {
    final controller = TextEditingController();

    return await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Открыть проект'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '/storage/emulated/0/Download/Квартира_72_2.shield.json',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Открыть'),
          ),
        ],
      ),
    );
  }

  double _wireLength(List<WireNode> nodes) {
    if (nodes.length < 2) return 0;

    double total = 0;
    for (int i = 1; i < nodes.length; i++) {
      final prev = nodes[i - 1];
      final current = nodes[i];
      total += math.sqrt(
        (current.x - prev.x) * (current.x - prev.x) +
            (current.y - prev.y) * (current.y - prev.y),
      );
    }
    return total;
  }
}

extension IterableX<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}

class _PropertyRow extends StatelessWidget {
  const _PropertyRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final ShieldScene scene;
  final String? selectedModuleId;
  final String? selectedWireId;
  final String? selectedNoteId;
  final bool gridVisible;

  BoardPainter({
    required this.scene,
    required this.selectedModuleId,
    required this.selectedWireId,
    required this.selectedNoteId,
    required this.gridVisible,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF5F7FB);
    canvas.drawRect(Offset.zero & size, bg);

    if (gridVisible) {
      final grid = Paint()
        ..color = const Color(0xFFE5EAF3)
        ..strokeWidth = 1;

      for (double x = 0; x <= size.width; x += 25) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      }

      for (double y = 0; y <= size.height; y += 25) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
      }
    }

    final body = Paint()..color = const Color(0xFFEDEFF5);
    canvas.drawRect(const Rect.fromLTWH(120, 80, 900, 700), body);

    final rail = Paint()..color = const Color(0xFFDDE5F1);
    canvas.drawRect(const Rect.fromLTWH(180, 120, 260, 560), rail);

    for (final module in scene.modules) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(module.x, module.y),
          width: module.widthModules * 35,
          height: module.height,
        ),
        const Radius.circular(10),
      );

      final selected = selectedModuleId == module.id;
      final fill = Paint()
        ..color = selected ? Color(module.colorValue).withOpacity(0.9) : Color(module.colorValue);

      canvas.drawRRect(rect, fill);

      final border = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 2.0 : 1.1
        ..color = selected ? Colors.black : Colors.black26;

      canvas.drawRRect(rect, border);

      final label = TextPainter(
        text: TextSpan(
          text: module.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      label.layout();
      label.paint(canvas, Offset(module.x - 24, module.y - 8));
    }

    for (final wire in scene.wires) {
      if (wire.nodes.length < 2) continue;

      final path = Path()..moveTo(wire.nodes.first.x, wire.nodes.first.y);
      for (int i = 1; i < wire.nodes.length; i++) {
        path.lineTo(wire.nodes[i].x, wire.nodes[i].y);
      }

      final paint = Paint()
        ..color = wire.material == WireMaterial.copper ? const Color(0xFF3B82F6) : const Color(0xFFB7791F)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, paint);

      final label = TextPainter(
        text: TextSpan(
          text: '${wire.calculatedLengthMm.toStringAsFixed(0)} мм',
          style: const TextStyle(fontSize: 10, color: Color(0xFF475569)),
        ),
        textDirection: TextDirection.ltr,
      );
      label.layout();

      final center = Offset(
        (wire.nodes.first.x + wire.nodes.last.x) / 2,
        (wire.nodes.first.y + wire.nodes.last.y) / 2,
      );

      label.paint(canvas, center);
    }

    for (final note in scene.notes) {
      final selected = selectedNoteId == note.id;
      final label = TextPainter(
        text: TextSpan(
          text: note.text,
          style: TextStyle(
            fontSize: 14,
            color: selected ? const Color(0xFF1D4ED8) : Color(note.colorValue),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      label.layout();
      label.paint(canvas, Offset(note.x, note.y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
