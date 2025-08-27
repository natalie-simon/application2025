import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'activity_category.g.dart';

@JsonSerializable()
class ActivityCategory extends Equatable {
  final int id;
  @JsonKey(name: 'lbl_categorie')
  final String label;
  @JsonKey(name: 'avec_equipement')
  final bool withEquipment;
  final String couleur;

  const ActivityCategory({
    required this.id,
    required this.label,
    required this.withEquipment,
    required this.couleur,
  });

  factory ActivityCategory.fromJson(Map<String, dynamic> json) =>
      _$ActivityCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityCategoryToJson(this);

  @override
  List<Object?> get props => [id, label, withEquipment, couleur];

  @override
  String toString() => 'ActivityCategory(id: $id, label: $label)';
}