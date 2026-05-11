class TuHomeModel {
  final String title;
  final String subtitle;
  final int pendingLetters;
  final int monthlyAgenda;
  final List<String> priorities;

  const TuHomeModel({
    required this.title,
    required this.subtitle,
    required this.pendingLetters,
    required this.monthlyAgenda,
    required this.priorities,
  });

  factory TuHomeModel.placeholder() {
    return const TuHomeModel(
      title: 'Dashboard Tata Usaha',
      subtitle: 'Administrasi akademik dan layanan jurusan',
      pendingLetters: 18,
      monthlyAgenda: 5,
      priorities: [
        'Validasi surat keterangan aktif kuliah',
        'Publikasi agenda akademik minggu ini',
        'Rekap permintaan layanan mahasiswa',
      ],
    );
  }
}
