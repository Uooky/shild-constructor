import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shild_constructor/features/project/data/project_file_service.dart';
import 'package:shild_constructor/features/project/domain/models/project.dart';
import 'package:shild_constructor/features/project/domain/models/project_state.dart';
import 'package:shild_constructor/features/project/domain/services/project_runtime_service.dart';
import 'package:shild_constructor/features/shield_editor/domain/models/shield_scene.dart';

final projectFileServiceProvider = Provider<ProjectFileService>((ref) {
  return ProjectFileService();
});

final projectControllerProvider =
    StateNotifierProvider<ProjectController, ProjectState>((ref) {
  return ProjectController(projectFileService: ref.read(projectFileServiceProvider));
});

class ProjectController extends StateNotifier<ProjectState> {
  final ProjectFileService projectFileService;

  ProjectController({required this.projectFileService})
      : super(ProjectRuntimeService().create(
          name: 'Квартира 72/2',
          objectName: 'ЖК "Лесная Поляна"',
          author: 'Иван Петров',
        ));

  void updateScene(ShieldScene scene) {
    final runtime = ProjectRuntimeService();
    state = runtime.updateScene(state, scene);
  }

  void addModule(ShieldModule module) {
    updateScene(state.scene.copyWith(modules: [...state.scene.modules, module]));
  }

  void addWire(WirePath wire) {
    updateScene(state.scene.copyWith(wires: [...state.scene.wires, wire]));
  }

  void addNote(NoteItem note) {
    updateScene(state.scene.copyWith(notes: [...state.scene.notes, note]));
  }

  void selectModule(String id) {
    state = state.copyWith(selectedModuleId: id);
  }

  void selectWire(String id) {
    state = state.copyWith(selectedWireId: id);
  }

  void selectNote(String id) {
    state = state.copyWith(selectedNoteId: id);
  }

  void moveModule(String id, double dx, double dy) {
    final modules = state.scene.modules.map((module) {
      if (module.id != id) return module;
      return module.copyWith(
        x: module.x + dx,
        y: module.y + dy,
      );
    }).toList();

    updateScene(state.scene.copyWith(modules: modules));
  }

  void removeSelected() {
    final moduleId = state.selectedModuleId;
    if (moduleId != null) {
      final scene = state.scene.copyWith(
        modules: state.scene.modules.where((m) => m.id != moduleId).toList(),
      );
      updateScene(scene);
      state = state.copyWith(selectedModuleId: null);
      return;
    }

    final wireId = state.selectedWireId;
    if (wireId != null) {
      final scene = state.scene.copyWith(
        wires: state.scene.wires.where((w) => w.id != wireId).toList(),
      );
      updateScene(scene);
      state = state.copyWith(selectedWireId: null);
      return;
    }

    final noteId = state.selectedNoteId;
    if (noteId != null) {
      final scene = state.scene.copyWith(
        notes: state.scene.notes.where((n) => n.id != noteId).toList(),
      );
      updateScene(scene);
      state = state.copyWith(selectedNoteId: null);
    }
  }

  Future<String> saveCurrentProject() async {
    final project = state.project.copyWith(
      sceneJson: jsonEncode(state.scene.toJson()),
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(project: project);
    return projectFileService.saveProject(project);
  }

  Future<Project?> openProjectAtPath(String path) async {
    final project = await projectFileService.openProject(path);
    if (project == null) return null;

    final scene = ShieldScene.fromJson(jsonDecode(project.sceneJson));
    state = state.copyWith(
      project: project,
      scene: scene,
      isDirty: false,
    );
    return project;
  }
}
