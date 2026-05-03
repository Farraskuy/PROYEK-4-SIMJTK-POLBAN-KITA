enum KategoriFasilitasSyncStatus {
  local('local'),
  synced('synced');

  const KategoriFasilitasSyncStatus(this.value);
  final String value;

  static KategoriFasilitasSyncStatus fromValue(Object? value) {
    final normalized = value.toString().trim().toLowerCase();
    return KategoriFasilitasSyncStatus.values.firstWhere(
      (status) => status.value == normalized || status.name == normalized,
      orElse: () => KategoriFasilitasSyncStatus.synced,
    );
  }
}

class KategoriFasilitasModel {
  final String id;
  final String namaKategori;
  final String iconUrl;
  final KategoriFasilitasSyncStatus syncStatus;
  final String deskripsi;

  const KategoriFasilitasModel({
    required this.id,
    required this.namaKategori,
    required this.iconUrl,
    this.syncStatus = KategoriFasilitasSyncStatus.synced,
    this.deskripsi = '',
  });

  String get iconName => iconUrl;

  factory KategoriFasilitasModel.fromJson(Map<String, dynamic> json) {
    return KategoriFasilitasModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      namaKategori:
          (json['nama_kategori'] ?? json['namaKategori'] ?? '').toString(),
      iconUrl: (json['icon_url'] ?? json['iconUrl'] ?? '').toString(),
      syncStatus: KategoriFasilitasSyncStatus.fromValue(
        json['syncStatus'] ?? json['sync_status'],
      ),
      deskripsi: (json['deskripsi'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'nama_kategori': namaKategori,
      'namaKategori': namaKategori,
      'icon_url': iconUrl,
      'iconUrl': iconUrl,
      'syncStatus': syncStatus.value,
      'deskripsi': deskripsi,
    };
  }

  static List<KategoriFasilitasModel> dummyList() => const [
    KategoriFasilitasModel(
      id: 'kat-001',
      namaKategori: 'Jaringan',
      iconUrl: 'wifi',
      deskripsi: 'Masalah koneksi jaringan internet',
    ),
    KategoriFasilitasModel(
      id: 'kat-002',
      namaKategori: 'PC',
      iconUrl: 'computer',
      deskripsi: 'Kerusakan perangkat komputer',
    ),
    KategoriFasilitasModel(
      id: 'kat-003',
      namaKategori: 'AC',
      iconUrl: 'ac_unit',
      deskripsi: 'Gangguan pendingin ruangan',
    ),
    KategoriFasilitasModel(
      id: 'kat-004',
      namaKategori: 'Proyektor',
      iconUrl: 'videocam',
      deskripsi: 'Gangguan proyektor kelas/lab',
    ),
  ];
}
