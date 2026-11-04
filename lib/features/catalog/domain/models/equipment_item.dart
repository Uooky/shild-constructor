import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment_item.freezed.dart';
part 'equipment_item.g.dart';

@freezed
abstract class EquipmentItem with _$EquipmentItem {
  const EquipmentItem._();

  const factory EquipmentItem({
    required String id,
    required String name,
    required String manufacturer,
    required String article,
    required double widthModules,
    required double price,
    @Default(0xFF4CAF50) int colorValue,
    @Default({}) Map<String, dynamic> parameters,
  }) = _EquipmentItem;

  factory EquipmentItem.fromJson(Map<String, dynamic> json) =>
      _$EquipmentItemFromJson(json);

  Color get color => Color(colorValue);
}
