import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shild_constructor/features/estimate/domain/models/estimate.dart';
import 'package:shild_constructor/features/project/domain/models/project.dart';
import 'package:shild_constructor/features/shield_editor/domain/models/shield_scene.dart';

part 'project_state.freezed.dart';

@freezed
abstract class ProjectState with _$ProjectState {
  const factory ProjectState({
    required Project project,
    required ShieldScene scene,
    required Estimate estimate,
    @Default(false) bool isDirty,
    String? selectedModuleId,
    String? selectedWireId,
    String? selectedNoteId,
  }) = _ProjectState;
}
