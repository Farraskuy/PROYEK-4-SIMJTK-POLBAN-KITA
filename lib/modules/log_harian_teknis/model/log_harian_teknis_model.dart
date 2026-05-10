enum LogHarianSyncStatus {
  local('local'),
  synced('synced');

  const LogHarianSyncStatus(this.value);
  final String value;

  static LogHarianSyncStatus fromValue(Object? value) {
    final normalized = value.toString().trim().toLowerCase();
    return LogHarianSyncStatus.values.firstWhere(
      (status) => status.value == normalized || status.name == normalized,
      orElse: () => LogHarianSyncStatus.synced,
    );
  }
}

class LogHarianTeknisModel {
  final String id;
  final String teknisiId;
  final DateTime tanggal;
  final String keterangan;
  final LogHarianSyncStatus syncStatus;
  final DateTime createdAt;

  const LogHarianTeknisModel({
    required this.id,
    required this.teknisiId,
    required this.tanggal,
    required this.keterangan,
    this.syncStatus = LogHarianSyncStatus.synced,
    required this.createdAt,
  });

  factory LogHarianTeknisModel.fromJson(Map<String, dynamic> json) {
    return LogHarianTeknisModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      teknisiId: (json['teknisi_id'] ?? json['teknisiId'] ?? '').toString(),
      tanggal: DateTime.tryParse((json['tanggal'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      keterangan: (json['keterangan'] ?? '').toString(),
      syncStatus: LogHarianSyncStatus.fromValue(
        json['syncStatus'] ?? json['sync_status'],
      ),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'teknisi_id': teknisiId,
      'teknisiId': teknisiId,
      'tanggal': tanggal.toIso8601String(),
      'keterangan': keterangan,
      'syncStatus': syncStatus.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}