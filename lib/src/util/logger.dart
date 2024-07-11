import 'dart:io';
import 'package:logging/logging.dart';
import '../config.dart';

enum LogModule { http, ws, agent }

EmbeddingsLogger logger = EmbeddingsLogger(config.log.level);

class EmbeddingsLogger {
  static final EmbeddingsLogger _singleton = EmbeddingsLogger._internal();
  static Level _level = Level.INFO;

  factory EmbeddingsLogger(Level level) {
    _level = level;
    return _singleton;
  }

  Logger? _logger;
  late File _logFile;

  EmbeddingsLogger._internal() {
    _logger = Logger('LiteEmbeddingsServerLogger');
    Logger.root.level = _level;
    _logFile = File(
        '${Directory.current.path}${Platform.pathSeparator}log${Platform.pathSeparator}embeddings.log');
    _logFile.createSync(recursive: true);

    Logger.root.onRecord.listen((record) {
      final message =
          '${record.level.name}: ${record.time}: PID $pid: ${record.message}';
      print(message);
      _logFile.writeAsStringSync('$message\n', mode: FileMode.append);
    });
  }

  void log(LogModule module, String message,
      {String detail = "", Level level = Level.INFO}) {
    _logger?.log(level, "[${module.name.toUpperCase()}] $message - $detail");
  }
}
