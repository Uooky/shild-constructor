import 'dart:math' as math;
import 'package:shild_constructor/features/shield_editor/domain/models/shield_scene.dart';

class SceneService {
  double calcWireLength(List<WireNode> nodes) {
    if (nodes.length < 2) return 0;

    double total = 0;
    for (int i = 1; i < nodes.length; i++) {
      final prev = nodes[i - 1];
      final current = nodes[i];
      total += math.sqrt(
        math.pow(current.x - prev.x, 2) + math.pow(current.y - prev.y, 2),
      );
    }
    return total;
  }

  double occupancyPercent(ShieldScene scene) {
    return (scene.modules.length / 72.0) * 100.0;
  }

  double totalWireLength(ShieldScene scene) {
    return scene.wires.fold<double>(
      0,
      (sum, w) => sum + calcWireLength(w.nodes),
    );
  }
}
