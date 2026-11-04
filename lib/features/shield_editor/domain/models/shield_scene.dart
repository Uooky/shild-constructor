import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shield_scene.freezed.dart';
part 'shield_scene.g.dart';

enum ModuleType { breaker, relay, rcd, terminal, meter, custom }
enum WireMaterial { copper, aluminum }
enum NoteAlignment { left, center, right }

class OffsetJsonConverter implements JsonConverter<Offset, Map<String, dynamic>> {
  const OffsetJsonConverter();

  @override
  Offset fromJson(Map<String, dynamic> json) => Offset(
        (json['dx'] as num).toDouble(),
        (json['dy'] as num).toDouble(),
      );

  @override
  Map<String, dynamic> toJson(Offset object) => {
        'dx': object.dx,
        'dy': object.dy,
      };
}

@freezed
abstract class ShieldScene with _$ShieldScene {
  const factory ShieldScene({
    required String id,
    @Default(1.0) double scale,
    @OffsetJsonConverter() @Default(Offset.zero) Offset panOffset,
    @Default(true) bool gridVisible,
    @Default(25.0) double gridSize,
    @Default([]) List<DinRail> dinRails,
    @Default([]) List<ShieldModule> modules,
    @Default([]) List<WirePath> wires,
    @Default([]) List<NoteItem> notes,
  }) = _ShieldScene;

  factory ShieldScene.fromJson(Map<String, dynamic> json) =>
      _$ShieldSceneFromJson(json);
}

@freezed
abstract class DinRail with _$DinRail {
  const factory DinRail({
    required String id,
    required double x,
    required double y,
    required double width,
    required double height,
    @Default(0.0) double spacing,
    @Default(1.0) double moduleCount,
  }) = _DinRail;

  factory DinRail.fromJson(Map<String, dynamic> json) => _$DinRailFromJson(json);
}

@freezed
abstract class ShieldModule with _$ShieldModule {
  const ShieldModule._();

  const factory ShieldModule({
    required String id,
    required String catalogId,
    required String name,
    required ModuleType type,
    required double x,
    required double y,
    required double widthModules,
    required double height,
    @Default(0.0) double rotation,
    @Default(0xFF4CAF50) int colorValue,
  }) = _ShieldModule;

  factory ShieldModule.fromJson(Map<String, dynamic> json) =>
      _$ShieldModuleFromJson(json);

  Color get color => Color(colorValue);
}

@freezed
abstract class WireNode with _$WireNode {
  const factory WireNode({
    required double x,
    required double y,
  }) = _WireNode;

  factory WireNode.fromJson(Map<String, dynamic> json) => _$WireNodeFromJson(json);
}

@freezed
abstract class WirePath with _$WirePath {
  const factory WirePath({
    required String id,
    required String wireType,
    required WireMaterial material,
    required List<WireNode> nodes,
    @Default(0.0) double calculatedLengthMm,
    @Default('') String zoneName,
  }) = _WirePath;

  factory WirePath.fromJson(Map<String, dynamic> json) => _$WirePathFromJson(json);
}

@freezed
abstract class NoteItem with _$NoteItem {
  const NoteItem._();

  const factory NoteItem({
    required String id,
    required String text,
    required double x,
    required double y,
    @Default(NoteAlignment.left) NoteAlignment alignment,
    @Default(0xFF1F2937) int colorValue,
  }) = _NoteItem;

  factory NoteItem.fromJson(Map<String, dynamic> json) =>
      _$NoteItemFromJson(json);

  Color get color => Color(colorValue);
}
