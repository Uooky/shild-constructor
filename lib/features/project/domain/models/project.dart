import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

@freezed
abstract class Project with _$Project {
  const factory Project({
    required String id,
    required String name,
    String? objectName,
    String? author,
    @Default('') String note,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String sceneJson,
    @Default([]) List<ProjectVersion> versions,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}

@freezed
abstract class ProjectVersion with _$ProjectVersion {
  const factory ProjectVersion({
    required String id,
    required String label,
    required String comment,
    required bool isAutomatic,
    required DateTime createdAt,
    required String snapshotJson,
  }) = _ProjectVersion;

  factory ProjectVersion.fromJson(Map<String, dynamic> json) =>
      _$ProjectVersionFromJson(json);
}
