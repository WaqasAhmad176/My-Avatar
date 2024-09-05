import 'package:json_annotation/json_annotation.dart';
import 'Output.dart';  // Import the Output class

part 'ApiResponse.g.dart';

@JsonSerializable()
class ApiResponse {
  final int delayTime;
  final int executionTime;
  final String id;
  final Output output;  // Use the Output class here
  final String status;

  ApiResponse({
    required this.delayTime,
    required this.executionTime,
    required this.id,
    required this.output,  // Use Output class here
    required this.status,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => _$ApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}
