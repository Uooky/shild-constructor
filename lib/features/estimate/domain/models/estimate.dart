import 'package:freezed_annotation/freezed_annotation.dart';

part 'estimate.freezed.dart';
part 'estimate.g.dart';

@freezed
class Estimate with _$Estimate {
  const factory Estimate({
    required String id,
    required String projectId,
    @Default(0.0) double subtotal,
    @Default(0.0) double markupPercent,
    @Default(0.0) double discountPercent,
    @Default([]) List<EstimateLine> lines,
    @Default(0.0) double total,
  }) = _Estimate;

  factory Estimate.fromJson(Map<String, dynamic> json) =>
      _$EstimateFromJson(json);
}

@freezed
class EstimateLine with _$EstimateLine {
  const factory EstimateLine({
    required String id,
    required String equipmentId,
    required String name,
    @Default(1) int quantity,
    @Default(0.0) double unitPrice,
    @Default(0.0) double lineTotal,
  }) = _EstimateLine;

  factory EstimateLine.fromJson(Map<String, dynamic> json) =>
      _$EstimateLineFromJson(json);
}
