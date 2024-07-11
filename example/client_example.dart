import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dotenv/dotenv.dart';
import 'package:lite_embeddings_dart/lite_embeddings.dart';
import 'package:lite_embeddings_dart_server/src/config.dart';
import 'package:lite_embeddings_dart_server/src/dto.dart';

String prompt = "Get some tool status.";

final String embeddingsModel = "text-embedding-ada-002";

Config config = initConfig();

Dio dio = Dio(BaseOptions(
  baseUrl:
  "http://127.0.0.1:${config.server.port}${config.server.apiPathPrefix}",
  // headers: {"Authorization": "Bearer <KEY>"}
));

Future<void> main() async {
  init(_buildLLMConfigDto());

  String fileName = "Moore's Law for Everything.md";
  String fileText = await _buildDocsText(fileName);
  String separator = "<!--SEPARATOR-->";

  print("fileName: $fileName, fileTextSize: ${fileText.length}, separator: $separator");

  /// List All Docs
  List<DocsInfoDto>? docsInfoDtoList = await listDocs();
  print("docsNameDtoList: ${jsonEncode(docsInfoDtoList)}");

  /// Create New Docs
  // CreateDocsTextDto createDocsTextDto = CreateDocsTextDto(docsName: fileName, text: fileText, separator: separator, metadata: {"vdb": "chroma", "embeddings_model": embeddingsModel});
  // DocsInfoDto? docsInfoDto = await createDocsByText(createDocsTextDto);
  // print("docsInfoDto: ${docsInfoDto?.toJson()}");

  /// List Segments
  // String docsId = "<FROM DocsInfoDto>";
  // DocsIdDto docsIdDto = DocsIdDto(docsId: docsId);
  // DocumentInfoDto? documentInfoDto = await listSegments(docsIdDto);
  // print("documentInfoDto: ${jsonEncode(documentInfoDto?.toJson())}");

  /// Query
  // String questText = "Who is author?";
  // QueryDto queryDto = QueryDto(docsId: docsId, queryText: questText, nResults: 3);
  // QueryResultDto? queryResultDto = await queryDocs(queryDto);
  // print("queryResultDto: ${jsonEncode(queryResultDto)}");

  /// Update Segment
  // SegmentInfoDto segmentInfoDto = SegmentInfoDto(id: segmentId, text: newText, metadata: metadata);
  // UpdateSegmentDto updateSegmentDto = UpdateSegmentDto(docsId: docsId, segment: segmentInfoDto);
  // await updateSegment(updateSegmentDto);

  /// Insert Segment
  // SegmentDto segmentDto = SegmentDto(text: newText, metadata: metadata);
  // InsertSegmentDto insertSegmentDto = InsertSegmentDto(docsId: docsId, segment: segmentDto, index: 2);
  // await insertSegment(insertSegmentDto);

  /// Delete Segment
  // DeleteSegmentDto deleteSegmentDto = DeleteSegmentDto(docsId: docsId, id: segmentId);
  // await deleteSegment(deleteSegmentDto);

  /// Rename Docs
  // DocsInfoDto docsInfoDto = DocsInfoDto(docsId: docsId, docsName: newDocsName);
  // DocsInfoDto? docsInfoDtoResult = await renameDocs(docsInfoDto);

  /// Delete Docs
  // DocsIdDto docsIdDto = DocsIdDto(docsId: docsId);
  // await deleteDocs(docsIdDto);

  await dispose();
}

LLMConfigDto _buildLLMConfigDto() {
  DotEnv env = DotEnv();
  env.load(['example/.env']);
  return LLMConfigDto(
      baseUrl: env["baseUrl"]!, apiKey: env["apiKey"]!, model: embeddingsModel);
}

Future<String> _buildDocsText(String docsName) async {
  String folder = "${Directory.current.path}${Platform.pathSeparator}example${Platform.pathSeparator}docs";
  File file = File(folder + Platform.pathSeparator + docsName);
  String docsString = await file.readAsString();
  return docsString;
}

Future<void> sleep(int seconds) async {
  for (int i = seconds; i > 0; i--) {
    print(i);
    await Future.delayed(Duration(seconds: 1));
  }
}

Future<VersionDto?> getVersion() async {
  try {
    Response response = await dio.get('/version');
    final payload = response.data as String;
    final data = jsonDecode(payload);
    VersionDto versionDto = VersionDto.fromJson(data);
    print("[getVersion->RES] " + versionDto.toJson().toString());
    return versionDto;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<void> init(LLMConfigDto llmConfigDto) async {
  try {
    Response response = await dio.post('/init', data: llmConfigDto.toJson());
    final payload = response.data as String;
    print("[init->RES] " + payload);
  } catch (e) {
    print(e);
  }
}

Future<DocsInfoDto?> createDocsByText(CreateDocsTextDto createDocsTextDto) async {
  try {
    Response response = await dio.post('/docs/create-by-text', data: createDocsTextDto.toJson());
    final payload = response.data as String;
    final data = jsonDecode(payload);
    DocsInfoDto docsInfoDto = DocsInfoDto.fromJson(data);
    print("[createDocsByText->RES] " + docsInfoDto.toJson().toString());
    return docsInfoDto;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<DocsInfoDto?> createDocs(DocumentDto documentDto) async {
  try {
    Response response = await dio.post('/docs/create', data: documentDto.toJson());
    final payload = response.data as String;
    final data = jsonDecode(payload);
    DocsInfoDto docsInfoDto = DocsInfoDto.fromJson(data);
    print("[createDocs->RES] " + docsInfoDto.toJson().toString());
    return docsInfoDto;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<DocsIdDto?> deleteDocs(DocsIdDto docsIdDto) async {
  try {
    Response response = await dio.post('/docs/delete', data: docsIdDto.toJson());
    final payload = response.data as String;
    final data = jsonDecode(payload);
    DocsIdDto docsIdDtoResult = DocsIdDto.fromJson(data);
    print("[deleteDocs->RES] " + docsIdDtoResult.toJson().toString());
    return docsIdDtoResult;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<List<DocsInfoDto>?> listDocs() async {
  try {
    Response response = await dio.get('/docs/list');
    final payload = response.data as String;
    final data = jsonDecode(payload) as List<dynamic>;
    List<DocsInfoDto> docsInfoDtoList = data.map((docsInfoDtoJson) => DocsInfoDto.fromJson(docsInfoDtoJson)).toList();
    print("[listDocs->RES] " + jsonEncode(docsInfoDtoList));
    return docsInfoDtoList;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<DocsInfoDto?> renameDocs(DocsInfoDto docsInfoDto) async {
  try {
    Response response = await dio.post('/docs/rename', data: docsInfoDto.toJson());
    final payload = response.data as String;
    final data = jsonDecode(payload);
    DocsInfoDto docsInfoDtoResult = DocsInfoDto.fromJson(data);
    print("[renameDocs->RES] " + docsInfoDtoResult.toJson().toString());
    return docsInfoDto;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<QueryResultDto?> queryDocs(QueryDto queryDto) async {
  try {
    Response response = await dio.post('/docs/query', data: queryDto.toJson());
    final payload = response.data as String;
    final data = jsonDecode(payload);
    QueryResultDto queryResultDto = QueryResultDto.fromJson(data);
    print("[queryDocs->RES] " + queryResultDto.toJson().toString());
    return queryResultDto;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<List<QueryResultDto>?> batchQueryDocs(BatchQueryDto batchQueryDto) async {
  try {
    Response response = await dio.post('/docs/batch-query', data: batchQueryDto.toJson());
    final payload = response.data as String;
    final data = jsonDecode(payload) as List<dynamic>;
    List<QueryResultDto> queryResultDtoList = data.map((queryResultDtoJson) => QueryResultDto.fromJson(queryResultDtoJson)).toList();
    print("[batchQueryDocs->RES] " + jsonEncode(queryResultDtoList));
    return queryResultDtoList;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<DocumentInfoDto?> listSegments(DocsIdDto docsIdDto) async {
  try {
    Response response = await dio.post('/segment/list', data: docsIdDto.toJson());
    final payload = response.data as String?;
    if(payload == null) return null;
    final data = jsonDecode(payload);
    DocumentInfoDto documentInfoDto = DocumentInfoDto.fromJson(data);
    print("[listSegment->RES] " + documentInfoDto.toJson().toString());
    return documentInfoDto;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<SegmentIdDto?> insertSegment(InsertSegmentDto insertSegmentDto) async {
  try {
    Response response = await dio.post('/segment/insert', data: insertSegmentDto.toJson());
    final payload = response.data as String;
    final data = jsonDecode(payload);
    SegmentIdDto segmentIdDto = SegmentIdDto.fromJson(data);
    print("[insertSegment->RES] " + segmentIdDto.toJson().toString());
    return segmentIdDto;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<SegmentIdDto?> updateSegment(UpdateSegmentDto updateSegmentDto) async {
  try {
    Response response = await dio.post('/segment/update', data: updateSegmentDto.toJson());
    final payload = response.data as String;
    final data = jsonDecode(payload);
    SegmentIdDto segmentIdDto = SegmentIdDto.fromJson(data);
    print("[updateSegment->RES] " + segmentIdDto.toJson().toString());
    return segmentIdDto;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<SegmentIdDto?> deleteSegment(DeleteSegmentDto deleteSegmentDto) async {
  try {
    Response response = await dio.post('/segment/delete', data: deleteSegmentDto.toJson());
    final payload = response.data as String;
    final data = jsonDecode(payload);
    SegmentIdDto segmentIdDto = SegmentIdDto.fromJson(data);
    print("[deleteSegment->RES] " + segmentIdDto.toJson().toString());
    return segmentIdDto;
  } catch (e) {
    print(e);
  }
  return null;
}

Future<void> dispose() async {
  try {
    Response response = await dio.post('/dispose');
    final payload = response.data as String;
    print("[deleteSegment->RES] " + payload);
  } catch (e) {
    print(e);
  }
}