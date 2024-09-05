// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ApiResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse _$ApiResponseFromJson(Map<String, dynamic> json) => ApiResponse(
      delayTime: (json['delayTime'] as num).toInt(),
      executionTime: (json['executionTime'] as num).toInt(),
      id: json['id'] as String,
      output: Output.fromJson(json['output'] as Map<String, dynamic>),
      status: json['status'] as String,
    );

Map<String, dynamic> _$ApiResponseToJson(ApiResponse instance) =>
    <String, dynamic>{
      'delayTime': instance.delayTime,
      'executionTime': instance.executionTime,
      'id': instance.id,
      'output': instance.output,
      'status': instance.status,
    };
