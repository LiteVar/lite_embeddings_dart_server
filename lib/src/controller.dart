import 'dart:async';
import 'dart:convert';
import 'package:lite_embeddings_dart/lite_embeddings.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'dto.dart';
import 'config.dart';
import 'util/logger.dart';

class VDBType {
  static final String CHROMA = "chroma";
}

final embeddingsController = EmbeddingsController();

class EmbeddingsController {
  late EmbeddingsService embeddingsService;

  EmbeddingsController() { _init(); }

  Future<Response> getVersion(Request request) async {
    logger.log(LogModule.http, "Request getVersion");
    VersionDto versionDto = VersionDto(version: config.version);
    logger.log(LogModule.http, "Response getVersion", detail: jsonEncode(versionDto.toJson()));
    return Response.ok(jsonEncode(versionDto.toJson()));
  }

  void _init() {
    String vdbType = config.vdb.type;
    String vdbBaseUrl = config.vdb.baseUrl;
    VectorDatabase vectorDatabase;
    if (vdbType.toLowerCase() == VDBType.CHROMA) {
      vectorDatabase = Chroma(baseUrl: vdbBaseUrl);
      embeddingsService = EmbeddingsService(vectorDatabase);
      embeddingsService.init();
      logger.log(LogModule.http, "EmbeddingsController init", detail: "vectorDatabase type: " + vdbType);
    } else {
      logger.log(LogModule.http, "EmbeddingsController init", detail: "vectorDatabase type: " + vdbType + ", NOT supported", level: Level.WARNING);
    }
  }

  Future<Response> createDocsByText(Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    try {
      final CreateDocsTextRequestDto createDocsTextRequestDto = CreateDocsTextRequestDto.fromJson(data);
      logger.log(LogModule.http, "Request createDocsByText", detail: payload, level: Level.FINEST);

      CreateDocsResultDto createDocsResultDto = await embeddingsService.createDocsByText(createDocsTextRequestDto);

      logger.log(LogModule.http, "Response createDocsByText", detail: jsonEncode(createDocsResultDto.toJson()));
      return Response.ok(jsonEncode(createDocsResultDto.toJson()));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response createDocsByText VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    }  on FormatException catch (e) {
      logger.log(LogModule.http, "Response createDocsByText FormatException: ${e}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response createDocsByText Exception: ${e}", detail: payload, level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

  Future<Response> createDocs(Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    try {
      final CreateDocsRequestDto createDocsRequestDto = CreateDocsRequestDto.fromJson(data);
      logger.log(LogModule.http, "Request createDocs", detail: payload, level: Level.FINEST);

      CreateDocsResultDto createDocsResultDto = await embeddingsService.createDocs(createDocsRequestDto);

      logger.log(LogModule.http, "Response createDocs", detail: jsonEncode(createDocsResultDto.toJson()));
      return Response.ok(jsonEncode(createDocsResultDto.toJson()));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response createDocs VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    }  on FormatException catch (e) {
      logger.log(LogModule.http, "Response createDocs FormatException: ${e}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response createDocs Exception: ${e}", detail: payload, level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

  Future<Response> deleteDocs(Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    try {
      final DocsIdDto docsIdDto = DocsIdDto.fromJson(data);
      logger.log(LogModule.http, "Request deleteDocs", detail: payload, level: Level.FINEST);

      await embeddingsService.deleteDocs(docsIdDto);

      logger.log(LogModule.http, "Response deleteDocs", detail: jsonEncode(docsIdDto.toJson()));
      return Response.ok(jsonEncode(docsIdDto.toJson()));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response deleteDocs VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    }  on FormatException catch (e) {
      logger.log(LogModule.http, "Response deleteDocs FormatException: ${e}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response deleteDocs Exception: ${e}", detail: payload, level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

  Future<Response> listDocs(Request request) async {
    try {
      logger.log(LogModule.http, "Request listDocs", detail: "", level: Level.FINEST);

      List<DocsInfoDto> docsInfoDtoList = await embeddingsService.listDocs();

      logger.log(LogModule.http, "Response listDocs", detail: jsonEncode(docsInfoDtoList));
      return Response.ok(jsonEncode(docsInfoDtoList));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response listDocs VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: "", level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    }  on FormatException catch (e) {
      logger.log(LogModule.http, "Response listDocs FormatException: ${e}", detail: "", level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response listDocs Exception: ${e}", detail: "", level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

  Future<Response> renameDocs(Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    try {
      final DocsInfoDto docsInfoDto = DocsInfoDto.fromJson(data);
      logger.log(LogModule.http, "Request renameDocs", detail: payload, level: Level.FINEST);

      await embeddingsService.renameDocs(docsInfoDto);

      logger.log(LogModule.http, "Response renameDocs", detail: jsonEncode(docsInfoDto.toJson()));
      return Response.ok(jsonEncode(docsInfoDto.toJson()));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response renameDocs VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    }  on FormatException catch (e) {
      logger.log(LogModule.http, "Response renameDocs FormatException: ${e}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response renameDocs Exception: ${e}", detail: payload, level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

  Future<Response> queryDocs(Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    try {
      final QueryRequestDto queryRequestDto = QueryRequestDto.fromJson(data);
      logger.log(LogModule.http, "Request queryDocs", detail: payload, level: Level.FINEST);

      QueryResultDto queryResultDto = await embeddingsService.query(queryRequestDto);

      logger.log(LogModule.http, "Response queryDocs", detail: jsonEncode(queryResultDto.toJson()));
      return Response.ok(jsonEncode(queryResultDto.toJson()));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response queryDocs VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    }  on FormatException catch (e) {
      logger.log(LogModule.http, "Response queryDocs FormatException: ${e}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response queryDocs Exception: ${e}", detail: payload, level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

  Future<Response> batchQueryDocs(Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    try {
      final BatchQueryRequestDto batchQueryRequestDto = BatchQueryRequestDto.fromJson(data);
      logger.log(LogModule.http, "Request batchQueryDocs", detail: payload, level: Level.FINEST);

      List<QueryResultDto> queryResultDtoList = await embeddingsService.batchQuery(batchQueryRequestDto);

      logger.log(LogModule.http, "Response batchQueryDocs", detail: jsonEncode(queryResultDtoList));
      return Response.ok(jsonEncode(queryResultDtoList));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response batchQueryDocs VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    }  on FormatException catch (e) {
      logger.log(LogModule.http, "Response batchQueryDocs FormatException: ${e}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response batchQueryDocs Exception: ${e}", detail: payload, level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

  Future<Response> multiDocsQuery(Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    try {
      final MultiDocsQueryRequestDto multiDocsQueryRequestDto = MultiDocsQueryRequestDto.fromJson(data);
      logger.log(LogModule.http, "Request multiDocsQuery", detail: payload, level: Level.FINEST);

      MultiDocsQueryResultDto multiDocsQueryResultDto = await embeddingsService.multiDocsQuery(multiDocsQueryRequestDto);

      logger.log(LogModule.http, "Response multiDocsQuery", detail: jsonEncode(multiDocsQueryResultDto.toJson()));
      return Response.ok(jsonEncode(multiDocsQueryResultDto.toJson()));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response multiDocsQuery VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    } on FormatException catch (e) {
      logger.log(LogModule.http, "Response multiDocsQuery FormatException: ${e}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response multiDocsQuery Exception: ${e}", detail: payload, level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

  Future<Response> listSegment(Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    try {
      final DocsIdDto docsIdDto = DocsIdDto.fromJson(data);
      logger.log(LogModule.http, "Request listSegment", detail: payload, level: Level.FINEST);

      DocsFullInfoDto? docsFullInfoDto = await embeddingsService.listSegments(docsIdDto);

      logger.log(LogModule.http, "Response listSegment", detail: jsonEncode(docsFullInfoDto?.toJson()));
      return Response.ok(jsonEncode(docsFullInfoDto?.toJson()));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response listSegment VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    }  on FormatException catch (e) {
      logger.log(LogModule.http, "Response listSegment FormatException: ${e}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response listSegment Exception: ${e}", detail: payload, level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

  Future<Response> insertSegment(Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    try {
      final InsertSegmentDto insertSegmentDto = InsertSegmentDto.fromJson(data);
      logger.log(LogModule.http, "Request insertSegment", detail: payload, level: Level.FINEST);

      SegmentUpsertResultDto segmentUpsertResultDto = await embeddingsService.insertSegment(insertSegmentDto);

      logger.log(LogModule.http, "Response insertSegment", detail: jsonEncode(segmentUpsertResultDto.toJson()));
      return Response.ok(jsonEncode(segmentUpsertResultDto.toJson()));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response insertSegment VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    }  on FormatException catch (e) {
      logger.log(LogModule.http, "Response insertSegment FormatException: ${e}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response insertSegment Exception: ${e}", detail: payload, level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

  Future<Response> updateSegment(Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    try {
      final UpdateSegmentDto updateSegmentDto = UpdateSegmentDto.fromJson(data);
      logger.log(LogModule.http, "Request updateSegment", detail: payload, level: Level.FINEST);

      SegmentIdDto segmentIdDto = await embeddingsService.updateSegment(updateSegmentDto);

      logger.log(LogModule.http, "Response updateSegment", detail: jsonEncode(segmentIdDto.toJson()));
      return Response.ok(jsonEncode(segmentIdDto.toJson()));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response updateSegment VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    }  on FormatException catch (e) {
      logger.log(LogModule.http, "Response updateSegment FormatException: ${e}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response updateSegment Exception: ${e}", detail: payload, level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

  Future<Response> deleteSegment(Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    try {
      final DeleteSegmentDto deleteSegmentDto = DeleteSegmentDto.fromJson(data);
      logger.log(LogModule.http, "Request deleteSegment", detail: payload, level: Level.FINEST);

      SegmentIdDto segmentIdDto = await embeddingsService.deleteSegment(deleteSegmentDto);

      logger.log(LogModule.http, "Response deleteSegment", detail: jsonEncode(segmentIdDto.toJson()));
      return Response.ok(jsonEncode(segmentIdDto.toJson()));
    } on VectorDatabaseException catch (e) {
      logger.log(LogModule.http, "Response deleteSegment VectorDatabaseException: ${jsonEncode(e.toJson())}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: jsonEncode(e.toJson()));
    }  on FormatException catch (e) {
      logger.log(LogModule.http, "Response deleteSegment FormatException: ${e}", detail: payload, level: Level.WARNING);
      return Response.badRequest(body: e);
    } catch (e) {
      logger.log(LogModule.http, "Response deleteSegment Exception: ${e}", detail: payload, level: Level.WARNING);
      return Response.internalServerError(body: e);
    }
  }

}
