// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ApiRequest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiRequest _$ApiRequestFromJson(Map<String, dynamic> json) => ApiRequest(
      webhook: json['webhook'] as String,
      input: Input.fromJson(json['input'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ApiRequestToJson(ApiRequest instance) =>
    <String, dynamic>{
      'webhook': instance.webhook,
      'input': instance.input,
    };

Input _$InputFromJson(Map<String, dynamic> json) => Input(
      prompt: json['prompt'] as String,
      style: json['style'] as String,
      job_id: (json['job_id'] as num).toInt(),
      image: json['image'] as String,
      uuid: json['uuid'] as String,
      task: json['task'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      adjustment: (json['adjustment'] as num).toDouble(),
    );

Map<String, dynamic> _$InputToJson(Input instance) => <String, dynamic>{
      'prompt': instance.prompt,
      'style': instance.style,
      'job_id': instance.job_id,
      'image': instance.image,
      'uuid': instance.uuid,
      'task': instance.task,
      'width': instance.width,
      'height': instance.height,
      'adjustment': instance.adjustment,
    };
