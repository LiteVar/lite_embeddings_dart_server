import 'package:shelf_router/shelf_router.dart';
import 'controller.dart';

final Router apiRouter = Router();

void apiRoutes() {
  apiRouter.get('/version', embeddingsController.getVersion);
  apiRouter.post('/init', embeddingsController.init);
  apiRouter.post('/docs/create-by-text', embeddingsController.createDocsByText);
  apiRouter.post('/docs/create', embeddingsController.createDocs);
  apiRouter.post('/docs/delete', embeddingsController.deleteDocs);
  apiRouter.get('/docs/list', embeddingsController.listDocs);
  apiRouter.post('/docs/rename', embeddingsController.renameDocs);
  apiRouter.post('/docs/query', embeddingsController.queryDocs);
  apiRouter.post('/docs/batch-query', embeddingsController.batchQueryDocs);
  apiRouter.post('/docs/multi-query', embeddingsController.multiDocsQuery);
  apiRouter.post('/segment/list', embeddingsController.listSegment);
  apiRouter.post('/segment/insert', embeddingsController.insertSegment);
  apiRouter.post('/segment/update', embeddingsController.updateSegment);
  apiRouter.post('/segment/delete', embeddingsController.deleteSegment);
  apiRouter.post('/dispose', embeddingsController.dispose);
}
