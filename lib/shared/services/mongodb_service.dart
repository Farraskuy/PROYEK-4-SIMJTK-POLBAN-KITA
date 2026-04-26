import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/log_service.dart';

class MonggoDBServices {
  static final MonggoDBServices _instance = MonggoDBServices._internal();

  MonggoDBServices._internal();

  factory MonggoDBServices() {
    return _instance;
  }

  Db? _db;

  bool get isConnected => _db?.state == State.open;

  Future<void> connect() async {
    if (isConnected) {
      await LogService.writeLog(
        "Already connected to MongoDB",
        source: "mongodb_service.dart",
      );

      return;
    }

    final String uri = dotenv.env['MONGODB_URI'] ?? '';

    if (uri.isEmpty) {
      throw Exception("MONGODB_URI is not set in .env file");
    }

    try {
      _db = await Db.create(uri);
      await _db!.open();

      await LogService.writeLog(
        "Successfully connected to MongoDB",
        source: "mongodb_service.dart",
      );
    } catch (e) {
      await LogService.writeLog(
        "Failed to connect to MongoDB: $e",
        source: "mongodb_service.dart",
        level: 1,
      );

      rethrow;
    }
  }

  DbCollection getCollection(String collectionName) {
    if (!isConnected) {
      throw Exception("Not connected to MongoDB");
    }

    return _db!.collection(collectionName);
  }

  Future<void> insertData(String collectionName, Map<String, dynamic> data) async {
    try {
      final collection = getCollection(collectionName);
      await collection.insertOne(data);

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

  Future<List<Map<String, dynamic>>> fetch(String collection, SelectorBuilder filter) async {
    try {
      final coll = getCollection(collection);
      final data = await coll.find(filter).toList();

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

  Future<void> updateData(String collectionName, String id, Map<String, dynamic> newData) async {
    try {
      final collection = getCollection(collectionName);
      await collection.updateOne({'_id': id}, {'\$set': newData});

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
      final collection = getCollection(collectionName);
      await collection.updateOne(filter, newData);
  
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

  Future<void> deleteData(String collectionName, String id) async {
    try {
      final collection = getCollection(collectionName);
      await collection.deleteOne({'_id': id});

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

  Future<void> close() async {
    if (isConnected) {
      await _db!.close();

      await LogService.writeLog(
        "MongoDB connection closed",
        source: "mongodb_service.dart",
      );
    }
  }
}
