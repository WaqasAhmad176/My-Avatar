// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Output.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Output _$OutputFromJson(Map<String, dynamic> json) => Output(
      id: (json['id'] as num).toInt(),
      output:
          (json['output'] as List<dynamic>).map((e) => e as String).toList(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$OutputToJson(Output instance) => <String, dynamic>{
      'id': instance.id,
      'output': instance.output,
      'status': instance.status,
    };
