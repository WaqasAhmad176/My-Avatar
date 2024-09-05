import 'package:json_annotation/json_annotation.dart';

part 'Output.g.dart';

@JsonSerializable()
class Output {
  final int id;
  final List<String> output;
  final String status;

  Output({
    required this.id,
    required this.output,
    required this.status,
  });

  factory Output.fromJson(Map<String, dynamic> json) => _$OutputFromJson(json);
  Map<String, dynamic> toJson() => _$OutputToJson(this);
}
