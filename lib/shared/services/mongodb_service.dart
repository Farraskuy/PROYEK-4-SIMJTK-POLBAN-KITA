import 'dart:async';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/log_service.dart';

class MonggoDBServices {
  static final MonggoDBServices _instance = MonggoDBServices._internal();
  static const Duration _connectionTimeout = Duration(seconds: 10);
  static const Duration _operationTimeout = Duration(seconds: 15);
  static const Duration _closeTimeout = Duration(seconds: 3);

  MonggoDBServices._internal();

  factory MonggoDBServices() {
    return _instance;
  }

  Db? _db;
  Future<void>? _connectInFlight;
  Future<void>? _reconnectInFlight;

  bool get isConnected => _db?.state == State.open;

  Future<T> _withTimeout<T>(
    Future<T> future, {
    required String action,
    required Duration timeout,
  }) {
    return future.timeout(
      timeout,
      onTimeout: () => throw TimeoutException(
        "$action timed out after ${timeout.inSeconds} seconds",
        timeout,
      ),
    );
  }

  Future<void> connect() async {
    if (_connectInFlight != null) {
      return _connectInFlight!;
    }

    final completer = Completer<void>();
    _connectInFlight = completer.future;

    try {
      await _openConnection();
      completer.complete();
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _connectInFlight = null;
    }
  }

  Future<void> _openConnection() async {
    if (isConnected) {
      await LogService.writeLog(
        "Already connected to MongoDB",
        source: "mongodb_service.dart",
      );

      return;
    }

    final String rawUri = dotenv.env['MONGODB_URI'] ?? '';

    if (rawUri.isEmpty) {
      throw Exception("MONGODB_URI is not set in .env file");
    }

    final uri = _normalizeMongoUri(rawUri);

    try {
      if (_db != null) {
        if (_db!.state == State.open) {
          await _db!.close();
        }
        _db = null;
      }

      final db = await _withTimeout(
        Db.create(uri),
        action: "Create MongoDB connection",
        timeout: _connectionTimeout,
      );

      _db = db;
      await _withTimeout(
        db.open(),
        action: "Open MongoDB connection",
        timeout: _connectionTimeout,
      );

      await LogService.writeLog(
        "Successfully connected to MongoDB",
        source: "mongodb_service.dart",
      );
    } catch (e) {
      final db = _db;
      _db = null;
      if (db != null) {
        unawaited(db.close().timeout(_closeTimeout).catchError((_) {}));
      }

      await LogService.writeLog(
        "Failed to connect to MongoDB: $e",
        source: "mongodb_service.dart",
        level: 1,
      );

      rethrow;
    }
  }

  Future<void> ensureConnected() async {
    if (!isConnected) {
      await connect();
      return;
    }
  }

  String _normalizeMongoUri(String rawUri) {
    final uri = Uri.parse(rawUri);
    if (uri.scheme != 'mongodb+srv') {
      return rawUri;
    }

    final queryParameters = Map<String, String>.from(uri.queryParameters);
    queryParameters.putIfAbsent('tls', () => 'true');
    queryParameters.putIfAbsent('safeAtlas', () => 'true');
    return uri.replace(queryParameters: queryParameters).toString();
  }

  Future<void> refreshConnection() async {
    await ensureConnected();

    try {
      await _withTimeout(
        _db!.pingCommand(),
        action: "Ping MongoDB connection",
        timeout: _operationTimeout,
      );
    } catch (e) {
      if (_isRecoverableConnectionError(e)) {
        await LogService.writeLog(
          "MongoDB connection stale, reconnecting...",
          source: "mongodb_service.dart",
          level: 1,
        );

        await _reconnect();
        return;
      }

      rethrow;
    }
  }

  Future<void> _reconnect() async {
    if (_reconnectInFlight != null) {
      return _reconnectInFlight!;
    }

    final completer = Completer<void>();
    _reconnectInFlight = completer.future;

    try {
      await close(shouldLog: false);
      await connect();
      completer.complete();
    } catch (e, st) {
      completer.completeError(e, st);
      rethrow;
    } finally {
      _reconnectInFlight = null;
    }
  }

  bool _isRecoverableConnectionError(Object error) {
    if (error is SocketException) {
      return true;
    }

    if (error is TimeoutException) {
      return true;
    }

    final message = error.toString().toLowerCase();
    return message.contains('not connected') ||
        message.contains('connection closed') ||
        message.contains('connection reset') ||
        message.contains('broken pipe') ||
        message.contains('socket');
  }

  Future<T> _executeWithReconnect<T>(
    Future<T> Function() operation, {
    required String action,
  }) async {
    await ensureConnected();

    try {
      return await _withTimeout(
        operation(),
        action: action,
        timeout: _operationTimeout,
      );
    } catch (e) {
      if (_isRecoverableConnectionError(e)) {
        await LogService.writeLog(
          "$action gagal karena koneksi terputus, mencoba reconnect sekali...",
          source: "mongodb_service.dart",
          level: 1,
        );

        await _reconnect();
        return _withTimeout(
          operation(),
          action: "$action setelah reconnect",
          timeout: _operationTimeout,
        );
      }

      rethrow;
    }
  }

  DbCollection getCollection(String collectionName) {
    if (!isConnected) {
      throw Exception("Not connected to MongoDB");
    }

    return _db!.collection(collectionName);
  }

  Future<void> insertData(
    String collectionName,
    Map<String, dynamic> data,
  ) async {
    try {
      await _executeWithReconnect(() async {
        final collection = getCollection(collectionName);
        await collection.insertOne(data);
      }, action: "Insert data ke $collectionName");

      await LogService.writeLog(
        "Data inserted into $collectionName",
        source: "mongodb_service.dart",
      );
    } catch (e) {
      await LogService.writeLog(
        "Failed to insert data into MongoDB: $e",
        source: "mongodb_service.dart",
        level: 1,
      );

      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetch(
    String collection,
    SelectorBuilder filter,
  ) async {
    try {
      final data = await _executeWithReconnect(() async {
        final coll = getCollection(collection);
        return coll.find(filter).toList();
      }, action: "Fetch data dari $collection");

      await LogService.writeLog(
        "Data retrieved from $collection",
        source: "mongodb_service.dart",
      );

      return data;
    } catch (e) {
      await LogService.writeLog(
        "Failed to retrieve data from MongoDB: $e",
        source: "mongodb_service.dart",
        level: 1,
      );

      rethrow;
    }
  }

  Future<void> updateData(
    String collectionName,
    String id,
    Map<String, dynamic> newData,
  ) async {
    try {
      await _executeWithReconnect(() async {
        final collection = getCollection(collectionName);
        await collection.updateOne({'_id': id}, {'\$set': newData});
      }, action: "Update data di $collectionName");

      await LogService.writeLog(
        "Data updated in $collectionName",
        source: "mongodb_service.dart",
      );
    } catch (e) {
      await LogService.writeLog(
        "Failed to update data in MongoDB: $e",
        source: "mongodb_service.dart",
        level: 1,
      );

      rethrow;
    }
  }

  Future<void> updateOneByFilter(
    String collectionName,
    SelectorBuilder filter,
    Map<String, dynamic> newData,
  ) async {
    try {
      await _executeWithReconnect(() async {
        final collection = getCollection(collectionName);
        await collection.updateOne(filter, _asSetUpdate(newData));
      }, action: "Update data by filter di $collectionName");

      await LogService.writeLog(
        "Data updated in $collectionName by filter",
        source: "mongodb_service.dart",
      );
    } catch (e) {
      await LogService.writeLog(
        "Failed to update data by filter in MongoDB: $e",
        source: "mongodb_service.dart",
        level: 1,
      );

      rethrow;
    }
  }

  Map<String, dynamic> _asSetUpdate(Map<String, dynamic> data) {
    final hasOperator = data.keys.any((key) => key.startsWith(r'$'));
    if (hasOperator) {
      return data;
    }

    final fields = Map<String, dynamic>.from(data)..remove('_id');
    return {r'$set': fields};
  }

  Future<void> deleteData(String collectionName, String id) async {
    try {
      await _executeWithReconnect(() async {
        final collection = getCollection(collectionName);
        await collection.deleteOne({'_id': id});
      }, action: "Delete data di $collectionName");

      await LogService.writeLog(
        "Data deleted from $collectionName",
        source: "mongodb_service.dart",
      );
    } catch (e) {
      await LogService.writeLog(
        "Failed to delete data from MongoDB: $e",
        source: "mongodb_service.dart",
        level: 1,
      );

      rethrow;
    }
  }

  Future<void> close({bool shouldLog = true}) async {
    if (_db == null) {
      return;
    }

    if (isConnected) {
      await _withTimeout(
        _db!.close(),
        action: "Close MongoDB connection",
        timeout: _closeTimeout,
      );

      if (shouldLog) {
        await LogService.writeLog(
          "MongoDB connection closed",
          source: "mongodb_service.dart",
        );
      }
    }

    _db = null;
  }
}
