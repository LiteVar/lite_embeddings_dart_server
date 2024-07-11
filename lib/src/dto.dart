import 'package:json_annotation/json_annotation.dart';
import 'package:lite_embeddings_dart/lite_embeddings.dart';

part 'dto.g.dart';

@JsonSerializable()
class VersionDto {
  late String version;

  VersionDto({required this.version});

  factory VersionDto.fromJson(Map<String, dynamic> json) =>
      _$VersionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VersionDtoToJson(this);
}
//
// @JsonSerializable()
// class CreateDocsLLMDto {
//   CreateDocsTextDto createDocsText;
//   LLMConfigDto llmConfig;
//
//   CreateDocsLLMDto({required this.createDocsText, required this.llmConfig});
//
//   factory CreateDocsLLMDto.fromJson(Map<String, dynamic> json) => _$CreateDocsLLMDtoFromJson(json);
//
//   Map<String, dynamic> toJson() => _$CreateDocsLLMDtoToJson(this);
// }
//
// @JsonSerializable()
// class UpdateSegmentLLMDto {
//   UpdateSegmentDto updateSegmentDto;
//   LLMConfigDto llmConfig;
//
//   UpdateSegmentLLMDto({required this.updateSegmentDto, required this.llmConfig});
//
//   factory UpdateSegmentLLMDto.fromJson(Map<String, dynamic> json) => _$UpdateSegmentLLMDtoFromJson(json);
//
//   Map<String, dynamic> toJson() => _$UpdateSegmentLLMDtoToJson(this);
// }
//
// @JsonSerializable()
// class InsertSegmentLLMDto {
//   InsertSegmentDto insertSegmentDto;
//   LLMConfigDto llmConfig;
//
//   InsertSegmentLLMDto({required this.insertSegmentDto, required this.llmConfig});
//
//   factory InsertSegmentLLMDto.fromJson(Map<String, dynamic> json) => _$InsertSegmentLLMDtoFromJson(json);
//
//   Map<String, dynamic> toJson() => _$InsertSegmentLLMDtoToJson(this);
// }