import 'package:json_annotation/json_annotation.dart';

part 'ApiRequest.g.dart';


@JsonSerializable()
class ApiRequest {
  final String webhook;
  final Input input;

  ApiRequest({
    required this.webhook,
    required this.input,
  });

  factory ApiRequest.fromJson(Map<String, dynamic> json) => _$ApiRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ApiRequestToJson(this);
}

@JsonSerializable()
class Input {
  final String prompt;
  final String style;
  final int job_id;
  final String image;
  final String uuid;
  final String task;
  final int width;
  final int height;
  final double adjustment;

  Input({
    required this.prompt,
    required this.style,
    required this.job_id,
    required this.image,
    required this.uuid,
    required this.task,
    required this.width,
    required this.height,
    required this.adjustment,
  });

  factory Input.fromJson(Map<String, dynamic> json) => _$InputFromJson(json);
  Map<String, dynamic> toJson() => _$InputToJson(this);
}
