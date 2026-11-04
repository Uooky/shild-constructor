import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shild_constructor/features/shield_editor/domain/models/shield_scene.dart';
import 'package:shild_constructor/services/project_state_provider.dart';

/// Visual design aid. It does not perform code-compliant electrical sizing or
/// protection coordination; have a qualified electrician validate designs.
class ProjectScreen extends ConsumerStatefulWidget {
  const ProjectScreen({super.key});

  @override
  ConsumerState<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends ConsumerState<ProjectScreen> {
  bool _schematic = false;
  bool _wireMode = false;
  WireNode? _wireStart;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectControllerProvider);
    final scene = state.scene;
    final notifier = ref.read(projectControllerProvider.notifier);
    final selected = scene.modules.where((m) => m.id == state.selectedModuleId).firstOrNull;
    final total = scene.modules.fold<double>(0, (sum, m) => sum + m.price);

    return Column(children: [
      Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('Компоновка'), icon: Icon(Icons.dashboard_outlined)),
                ButtonSegment(value: true, label: Text('Принципиальная схема'), icon: Icon(Icons.schema_outlined)),
              ],
              selected: {_schematic},
              onSelectionChanged: (v) => setState(() { _schematic = v.first; _wireMode = false; _wireStart = null; }),
            ),
            if (!_schematic) ...[
              FilledButton.tonalIcon(
                onPressed: () => setState(() { _wireMode = !_wireMode; _wireStart = null; }),
                icon: Icon(_wireMode ? Icons.close : Icons.cable),
                label: Text(_wireMode ? 'Отмена провода' : 'Прокладывать провод'),
              ),
              FilledButton.icon(onPressed: () => _addBreaker(scene), icon: const Icon(Icons.add), label: const Text('Добавить автомат')),
              DropdownButton<NetworkPhase>(
                value: scene.networkPhase,
                onChanged: (v) { if (v != null) notifier.updateScene(scene.copyWith(networkPhase: v)); },
                items: const [
                  DropdownMenuItem(value: NetworkPhase.single, child: Text('Однофазная сеть')),
                  DropdownMenuItem(value: NetworkPhase.three, child: Text('Трёхфазная сеть')),
                ],
              ),
              SizedBox(width: 290, child: Row(children: [
                const Text('Шаг DIN, мм'),
                Expanded(child: Slider(
                  value: scene.railSpacingMm.clamp(50, 300), min: 50, max: 300, divisions: 50,
                  label: scene.railSpacingMm.round().toString(),
                  onChanged: (v) => notifier.updateScene(scene.copyWith(railSpacingMm: v)),
                )),
              ])),
              if (_wireMode) Text(_wireStart == null ? 'Нажмите начало, затем конец провода' : 'Выберите конечную точку'),
            ],
            if (selected != null && !_schematic)
              OutlinedButton.icon(onPressed: () => _editModule(selected), icon: const Icon(Icons.tune), label: const Text('Характеристики')),
            OutlinedButton.icon(onPressed: () async {
              final path = await notifier.saveCurrentProject();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Сохранено: $path')));
            }, icon: const Icon(Icons.save), label: const Text('Сохранить')),
          ]),
        ),
      ),
      Expanded(
        child: _schematic
            ? _SchematicCanvas(scene: scene)
            : LayoutBuilder(builder: (context, constraints) => InteractiveViewer(
                constrained: false,
                minScale: 0.35,
                maxScale: 2.5,
                boundaryMargin: const EdgeInsets.all(120),
                child: SizedBox(
                  width: math.max(1400, constraints.maxWidth),
                  height: math.max(950, constraints.maxHeight),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: _wireMode ? (d) => _onWireTap(d.localPosition, scene) : null,
                    child: Stack(children: [
                      Positioned.fill(child: CustomPaint(painter: _LayoutPainter(scene))),
                      for (final m in scene.modules)
                        Positioned(
                          left: m.x - 42, top: m.y - 36, width: 84, height: 72,
                          child: GestureDetector(
                            onTap: () => notifier.selectModule(m.id),
                            onDoubleTap: () => _editModule(m),
                            onPanUpdate: _wireMode ? null : (d) {
                              notifier.selectModule(m.id);
                              notifier.moveModule(m.id, d.delta.dx, d.delta.dy);
                            },
                            child: Card(
                              elevation: state.selectedModuleId == m.id ? 8 : 2,
                              color: Color(m.colorValue),
                              child: Center(child: Text('${m.name}\n${m.tripCurve}-${m.ratedCurrentA.toStringAsFixed(0)}A\n${m.price.toStringAsFixed(0)} ₽', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10))),
                            ),
                          ),
                        ),
                      if (_wireStart != null)
                        Positioned(left: _wireStart!.x + 8, top: _wireStart!.y + 8, child: const Chip(label: Text('Начало трассы'))),
                    ]),
                  ),
                ),
              )),
      ),
      if (!_schematic)
        Container(width: double.infinity, color: Colors.white, padding: const EdgeInsets.all(8), child: Text('Модулей: ${scene.modules.length} • Проводов: ${scene.wires.length} • Сумма оборудования: ${total.toStringAsFixed(2)} ₽')),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Text('Схема является эскизом, не содержит расчёта селективности, токов КЗ и сечения кабелей. Перед монтажом необходима проверка специалистом.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.deepOrange))),
    ]);
  }

  void _addBreaker(ShieldScene scene) {
    final n = scene.modules.length;
    final module = ShieldModule(
      id: 'm_${DateTime.now().microsecondsSinceEpoch}', catalogId: 'breaker', name: 'QF${n + 1}',
      type: ModuleType.breaker, x: 130 + (n % 8) * 112, y: 170 + (n ~/ 8) * 112,
      widthModules: 1, height: 62, price: 350, ratedCurrentA: 16,
      poles: scene.networkPhase == NetworkPhase.single ? 1 : 3,
      colorValue: 0xff3478c8,
    );
    final notifier = ref.read(projectControllerProvider.notifier);
    notifier.addModule(module);
    notifier.selectModule(module.id);
    _editModule(module);
  }

  void _onWireTap(Offset point, ShieldScene scene) {
    final current = WireNode(x: point.dx, y: point.dy);
    if (_wireStart == null) { setState(() => _wireStart = current); return; }
    final start = _wireStart!;
    final dx = current.x - start.x;
    final dy = current.y - start.y;
    final lengthMm = math.sqrt(dx * dx + dy * dy) * 10;
    ref.read(projectControllerProvider.notifier).addWire(WirePath(
      id: 'w_${DateTime.now().microsecondsSinceEpoch}', wireType: 'L/N/PE', material: WireMaterial.copper,
      nodes: [start, current], calculatedLengthMm: lengthMm, zoneName: 'Щит',
    ));
    setState(() { _wireStart = null; _wireMode = false; });
  }

  Future<void> _editModule(ShieldModule original) async {
    final name = TextEditingController(text: original.name);
    final current = TextEditingController(text: original.ratedCurrentA.toString());
    final price = TextEditingController(text: original.price.toString());
    final poles = TextEditingController(text: original.poles.toString());
    final curve = TextEditingController(text: original.tripCurve);
    final capacity = TextEditingController(text: original.breakingCapacityKa.toString());
    final phase = TextEditingController(text: original.phase.toString());

    await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text('Устройство ${original.name}'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        _editField(name, 'Обозначение / название'),
        _editField(current, 'Номинальный ток, A', numeric: true),
        _editField(price, 'Цена, ₽', numeric: true),
        _editField(poles, 'Число полюсов', numeric: true),
        _editField(curve, 'Тип характеристики (B/C/D)'),
        _editField(capacity, 'Отключающая способность, кА', numeric: true),
        if (ref.read(projectControllerProvider).scene.networkPhase == NetworkPhase.three)
          _editField(phase, 'Фаза (1, 2 или 3)', numeric: true),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Отмена')),
        FilledButton(onPressed: () {
          final state = ref.read(projectControllerProvider);
          final updated = state.scene.modules.map((m) => m.id != original.id ? m : m.copyWith(
            name: name.text.trim().isEmpty ? m.name : name.text.trim(),
            ratedCurrentA: double.tryParse(current.text) ?? m.ratedCurrentA,
            price: double.tryParse(price.text) ?? m.price,
            poles: int.tryParse(poles.text) ?? m.poles,
            tripCurve: curve.text.trim().isEmpty ? m.tripCurve : curve.text.trim().toUpperCase(),
            breakingCapacityKa: double.tryParse(capacity.text) ?? m.breakingCapacityKa,
            phase: (int.tryParse(phase.text) ?? m.phase).clamp(1, 3),
          )).toList();
          ref.read(projectControllerProvider.notifier).updateScene(state.scene.copyWith(modules: updated));
          Navigator.pop(dialogContext);
        }, child: const Text('Сохранить')),
      ],
    ));
    name.dispose(); current.dispose(); price.dispose(); poles.dispose(); curve.dispose(); capacity.dispose(); phase.dispose();
  }

  Widget _editField(TextEditingController controller, String label, {bool numeric = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: TextField(controller: controller, keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
  );
}

class _LayoutPainter extends CustomPainter {
  final ShieldScene scene;
  const _LayoutPainter(this.scene);
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0xffe6eaf0)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 25) canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    for (double y = 0; y < size.height; y += 25) canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    final railPaint = Paint()..color = const Color(0xff65758b)..strokeWidth = 7;
    for (var i = 0; i < 5; i++) {
      final y = 130 + i * scene.railSpacingMm;
      canvas.drawLine(Offset(70, y), Offset(size.width - 70, y), railPaint);
      _drawLabel(canvas, 'DIN ${i + 1}', Offset(8, y - 10));
    }
    for (final wire in scene.wires) {
      if (wire.nodes.length < 2) continue;
      final paint = Paint()..color = wire.material == WireMaterial.copper ? const Color(0xffd8493e) : const Color(0xff7c5c32)..strokeWidth = 3..style = PaintingStyle.stroke;
      final path = Path()..moveTo(wire.nodes.first.x, wire.nodes.first.y);
      for (final point in wire.nodes.skip(1)) { path.lineTo(point.x, point.y); }
      canvas.drawPath(path, paint);
    }
  }
  void _drawLabel(Canvas canvas, String text, Offset position) {
    final painter = TextPainter(text: TextSpan(text: text, style: const TextStyle(fontSize: 10, color: Colors.blueGrey)), textDirection: TextDirection.ltr)..layout();
    painter.paint(canvas, position);
  }
  @override
  bool shouldRepaint(covariant _LayoutPainter oldDelegate) => oldDelegate.scene != scene;
}

class _SchematicCanvas extends StatelessWidget {
  final ShieldScene scene;
  const _SchematicCanvas({required this.scene});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) => SingleChildScrollView(
    child: CustomPaint(size: Size(math.max(c.maxWidth, 900), math.max(650, 150 + scene.modules.length * 130)), painter: _SchematicPainter(scene)),
  ));
}

class _SchematicPainter extends CustomPainter {
  final ShieldScene scene;
  const _SchematicPainter(this.scene);
  @override
  void paint(Canvas canvas, Size size) {
    final phases = scene.networkPhase == NetworkPhase.single ? const ['L'] : const ['L1', 'L2', 'L3'];
    const left = 75.0;
    final phaseY = <double>[];
    final phasePaint = Paint()..color = const Color(0xffbd2525)..strokeWidth = 2;
    for (var i = 0; i < phases.length; i++) {
      final y = 54.0 + i * 22;
      phaseY.add(y);
      canvas.drawLine(Offset(left, y), Offset(size.width - 28, y), phasePaint);
      _label(canvas, phases[i], Offset(18, y - 9), const Color(0xffbd2525));
    }
    final neutralY = 62.0 + phases.length * 22;
    canvas.drawLine(Offset(left, neutralY), Offset(size.width - 28, neutralY), Paint()..color = Colors.blue..strokeWidth = 2);
    _label(canvas, 'N', const Offset(34, 112), Colors.blue);
    final earthY = neutralY + 22;
    canvas.drawLine(Offset(left, earthY), Offset(size.width - 28, earthY), Paint()..color = Colors.green.shade700..strokeWidth = 2);
    _label(canvas, 'PE', Offset(25, earthY - 9), Colors.green.shade700);

    for (var i = 0; i < scene.modules.length; i++) {
      final module = scene.modules[i];
      final x = left + 60 + i * 150;
      final index = scene.networkPhase == NetworkPhase.single ? 0 : (module.phase - 1).clamp(0, 2);
      final y = phaseY[index];
      final pen = Paint()..color = Colors.black87..strokeWidth = 1.8;
      canvas.drawLine(Offset(x, y), Offset(x, 165), pen);
      final rect = Rect.fromCenter(center: Offset(x, 178), width: 42, height: 28);
      canvas.drawRect(rect, Paint()..color = Colors.white);
      canvas.drawRect(rect, Paint()..color = Colors.black87..style = PaintingStyle.stroke);
      canvas.drawLine(Offset(x - 9, 185), Offset(x + 9, 171), pen);
      canvas.drawLine(Offset(x, 192), Offset(x, neutralY), pen);
      _label(canvas, '${module.name}\n${module.poles}P ${module.tripCurve}-${module.ratedCurrentA.toStringAsFixed(0)}A\n${module.breakingCapacityKa.toStringAsFixed(1)} kA\n${module.price.toStringAsFixed(0)} ₽', Offset(x - 50, neutralY + 34), Colors.black87, width: 120);
    }
  }
  void _label(Canvas canvas, String text, Offset position, Color color, {double width = 90}) {
    final painter = TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: 11, color: color)), textDirection: TextDirection.ltr, maxLines: 5)..layout(maxWidth: width);
    painter.paint(canvas, position);
  }
  @override
  bool shouldRepaint(covariant _SchematicPainter oldDelegate) => oldDelegate.scene != scene;
}
