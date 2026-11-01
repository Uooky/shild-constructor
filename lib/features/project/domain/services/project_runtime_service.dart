import 'dart:convert';
import 'package:shild_constructor/features/estimate/domain/models/estimate.dart';
import 'package:shild_constructor/features/project/domain/models/project.dart';
import 'package:shild_constructor/features/project/domain/models/project_state.dart';
import 'package:shild_constructor/features/shield_editor/domain/models/shield_scene.dart';

class ProjectRuntimeService {
  ProjectState create({
    required String name,
    required String objectName,
    required String author,
  }) {
    final now = DateTime.now();

    const initialScene = ShieldScene(
      id: 'scene_demo',
      gridVisible: true,
      scale: 1.0,
    );

    final project = Project(
      id: 'project_${now.microsecondsSinceEpoch}',
      name: name,
      objectName: objectName,
      author: author,
      createdAt: now,
      updatedAt: now,
      sceneJson: jsonEncode(initialScene.toJson()),
    );

    final estimate = Estimate(
      id: 'estimate_${project.id}',
      projectId: project.id,
      subtotal: 72000,
      markupPercent: 15,
      discountPercent: 5,
      total: 72000 + 10800 - 3600,
    );

    return ProjectState(
      project: project,
      scene: initialScene,
      estimate: estimate,
    );
  }

  ProjectState updateScene(ProjectState current, ShieldScene scene) {
    final updatedProject = current.project.copyWith(
      sceneJson: jsonEncode(scene.toJson()),
      updatedAt: DateTime.now(),
    );

    return current.copyWith(
      project: updatedProject,
      scene: scene,
      isDirty: true,
    );
  }
}
