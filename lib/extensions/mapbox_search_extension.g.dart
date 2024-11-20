// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mapbox_search_extension.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuggestionResponseTb _$SuggestionResponseTbFromJson(
        Map<String, dynamic> json) =>
    SuggestionResponseTb(
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => SuggestionTb.fromJson(e as Map<String, dynamic>))
          .toList(),
      attribution: json['attribution'] as String,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$SuggestionResponseTbToJson(
        SuggestionResponseTb instance) =>
    <String, dynamic>{
      'suggestions': instance.suggestions,
      'attribution': instance.attribution,
      'url': instance.url,
    };
