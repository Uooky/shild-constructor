import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shild_constructor/features/shield_editor/domain/models/shield_scene.dart';
import 'package:shild_constructor/services/project_state_provider.dart';

/// Drafting aid only. It does not calculate cable cross-sections, short-circuit
/// currents, selectivity, or compliance with local electrical regulations.
class SchematicEditorScreen extends ConsumerStatefulWidget {
  const SchematicEditorScreen({super.key});
  @override
  ConsumerState<SchematicEditorScreen> createState() => _SchematicEditorScreenState();
}

class _SchematicEditorScreenState extends ConsumerState<SchematicEditorScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectControllerProvider);
    final scene = state.scene;
    final notifier = ref.read(projectControllerProvider.notifier);
    return Column(children: [
      Material(color: Colors.white, child: Padding(padding: const EdgeInsets.all(8), child: Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        const Text('Схема питания:'),
        DropdownButton<NetworkPhase>(value: scene.networkPhase, items: const [
          DropdownMenuItem(value: NetworkPhase.single, child: Text('1 фаза')),
          DropdownMenuItem(value: NetworkPhase.three, child: Text('3 фазы')),
        ], onChanged: (v) { if (v != null) notifier.updateScene(scene.copyWith(networkPhase: v)); }),
        FilledButton.icon(onPressed: () => _editGroup(), icon: const Icon(Icons.add), label: const Text('Добавить группу нагрузки')),
      ]))),
      Expanded(child: Row(children: [
        SizedBox(width: 330, child: ListView(padding: const EdgeInsets.all(10), children: [
          const Text('Группы и нагрузки', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 8),
          if (scene.circuitGroups.isEmpty) const Text('Групп пока нет. Создайте группу и назначьте ей устройства.'),
          for (final group in scene.circuitGroups)
            Card(child: ListTile(
              title: Text(group.name),
              subtitle: Text('Фаза ${group.phase} • ${group.designLoadW.toStringAsFixed(0)} Вт • ${group.moduleIds.length} устройств${group.notes.isEmpty ? '' : '\n${group.notes}'}'),
              isThreeLine: group.notes.isNotEmpty,
              onTap: () => _editGroup(group),
              trailing: IconButton(tooltip: 'Удалить группу', icon: const Icon(Icons.delete_outline), onPressed: () {
                final latest = ref.read(projectControllerProvider);
                notifier.updateScene(latest.scene.copyWith(circuitGroups: latest.scene.circuitGroups.where((g) => g.id != group.id).toList()));
              }),
            )),
          const Divider(),
          const Text('Устройства не в группе', style: TextStyle(fontWeight: FontWeight.bold)),
          for (final module in scene.modules.where((m) => !scene.circuitGroups.any((g) => g.moduleIds.contains(m.id))))
            ListTile(dense: true, leading: const Icon(Icons.electrical_services), title: Text(module.name), subtitle: Text('${module.tripCurve}-${module.ratedCurrentA.toStringAsFixed(0)} A • ${module.phase} фаза')),
        ])),
        const VerticalDivider(width: 1),
        Expanded(child: LayoutBuilder(builder: (context, c) => SingleChildScrollView(child: CustomPaint(
          size: Size(c.maxWidth, _drawingHeight(scene)),
          painter: _CircuitPainter(scene),
        )))),
      ])),
      const Padding(padding: EdgeInsets.all(8), child: Text('Схема — эскиз. Перед монтажом проверьте защиту, нагрузки, кабели и соответствие нормативам с квалифицированным специалистом.', textAlign: TextAlign.center, style: TextStyle(color: Colors.deepOrange))),
    ]);
  }

  double _drawingHeight(ShieldScene scene) => (scene.circuitGroups.length * 150 + 160).clamp(500, 3000).toDouble();

  Future<void> _editGroup([CircuitGroup? existing]) async {
    final currentState = ref.read(projectControllerProvider);
    final scene = currentState.scene;
    final name = TextEditingController(text: existing?.name ?? 'Группа ${scene.circuitGroups.length + 1}');
    final load = TextEditingController(text: (existing?.designLoadW ?? 0).toString());
    final notes = TextEditingController(text: existing?.notes ?? '');
    var phase = existing?.phase ?? 1;
    final selected = <String>{...?existing?.moduleIds};
    final result = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
      title: Text(existing == null ? 'Новая группа нагрузки' : 'Изменить группу'),
      content: SizedBox(width: 520, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Название группы')),
        TextField(controller: load, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Расчётная нагрузка, Вт')),
        if (scene.networkPhase == NetworkPhase.three) DropdownButtonFormField<int>(value: phase, decoration: const InputDecoration(labelText: 'Фаза'), items: const [1, 2, 3].map((p) => DropdownMenuItem(value: p, child: Text('Фаза $p'))).toList(), onChanged: (v) { if (v != null) setDialogState(() => phase = v); }),
        TextField(controller: notes, decoration: const InputDecoration(labelText: 'Примечание')),
        const SizedBox(height: 12),
        const Align(alignment: Alignment.centerLeft, child: Text('Устройства группы', style: TextStyle(fontWeight: FontWeight.bold))),
        for (final module in scene.modules) CheckboxListTile(
          dense: true, contentPadding: EdgeInsets.zero, value: selected.contains(module.id),
          title: Text(module.name), subtitle: Text('${module.tripCurve}-${module.ratedCurrentA.toStringAsFixed(0)} A'),
          onChanged: (checked) => setDialogState(() { if (checked == true) { selected.add(module.id); } else { selected.remove(module.id); } }),
        ),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Сохранить'))],
    )));
    if (result == true && name.text.trim().isNotEmpty) {
      final group = CircuitGroup(id: existing?.id ?? 'g_${DateTime.now().microsecondsSinceEpoch}', name: name.text.trim(), phase: scene.networkPhase == NetworkPhase.single ? 1 : phase, designLoadW: double.tryParse(load.text.replaceAll(',', '.')) ?? 0, moduleIds: selected.toList(), notes: notes.text.trim());
      final latest = ref.read(projectControllerProvider);
      final groups = [...latest.scene.circuitGroups.where((g) => g.id != group.id), group];
      final modules = latest.scene.modules.map((m) => selected.contains(m.id) ? m.copyWith(phase: group.phase) : m).toList();
      ref.read(projectControllerProvider.notifier).updateScene(latest.scene.copyWith(circuitGroups: groups, modules: modules));
    }
    name.dispose(); load.dispose(); notes.dispose();
  }
}

class _CircuitPainter extends CustomPainter {
  final ShieldScene scene;
  const _CircuitPainter(this.scene);
  @override
  void paint(Canvas canvas, Size size) {
    final phaseNames = scene.networkPhase == NetworkPhase.single ? const ['L'] : const ['L1', 'L2', 'L3'];
    const left = 60.0;
    final top = 48.0;
    final bars = <double>[];
    for (var i = 0; i < phaseNames.length; i++) {
      final y = top + i * 22;
      bars.add(y);
      canvas.drawLine(Offset(left, y), Offset(size.width - 15, y), Paint()..color = const Color(0xffc62828)..strokeWidth = 2);
      _text(canvas, phaseNames[i], Offset(16, y - 9), const Color(0xffc62828));
    }
    final neutralY = top + phaseNames.length * 22;
    final earthY = neutralY + 22;
    canvas.drawLine(Offset(left, neutralY), Offset(size.width - 15, neutralY), Paint()..color = Colors.blue..strokeWidth = 2);
    canvas.drawLine(Offset(left, earthY), Offset(size.width - 15, earthY), Paint()..color = Colors.green.shade700..strokeWidth = 2);
    _text(canvas, 'N', const Offset(24, 108), Colors.blue);
    _text(canvas, 'PE', Offset(20, earthY - 9), Colors.green.shade700);

    for (var groupIndex = 0; groupIndex < scene.circuitGroups.length; groupIndex++) {
      final group = scene.circuitGroups[groupIndex];
      final y0 = 150.0 + groupIndex * 150;
      final x = left + 110;
      final phaseIndex = scene.networkPhase == NetworkPhase.single ? 0 : (group.phase - 1).clamp(0, 2);
      final line = Paint()..color = Colors.black87..strokeWidth = 1.8;
      canvas.drawLine(Offset(x, bars[phaseIndex]), Offset(x, y0), line);
      final symbol = Rect.fromCenter(center: Offset(x, y0 + 15), width: 42, height: 28);
      canvas.drawRect(symbol, Paint()..color = Colors.white);
      canvas.drawRect(symbol, Paint()..color = Colors.black87..style = PaintingStyle.stroke);
      canvas.drawLine(Offset(x - 9, y0 + 22), Offset(x + 9, y0 + 8), line);
      canvas.drawLine(Offset(x, y0 + 29), Offset(x, neutralY), line);
      final equipment = scene.modules.where((m) => group.moduleIds.contains(m.id)).map((m) => '${m.name} ${m.poles}P ${m.tripCurve}-${m.ratedCurrentA.toStringAsFixed(0)}A').join('\n');
      _text(canvas, '${group.name} • фаза ${group.phase}\n${group.designLoadW.toStringAsFixed(0)} Вт\n$equipment', Offset(x + 32, y0 - 5), Colors.black87, width: 300);
      canvas.drawLine(Offset(x + 40, y0 + 15), Offset(size.width - 24, y0 + 15), Paint()..color = Colors.black26..strokeWidth = 1);
    }
  }
  void _text(Canvas canvas, String text, Offset at, Color color, {double width = 300}) {
    final painter = TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: 11, color: color)), textDirection: TextDirection.ltr, maxLines: 8)..layout(maxWidth: width);
    painter.paint(canvas, at);
  }
  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) => oldDelegate.scene != scene;
}
