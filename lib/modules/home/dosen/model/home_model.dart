class DosenHomeModel {
  final String title;
  final String subtitle;

  const DosenHomeModel({
    required this.title,
    required this.subtitle,
  });

  factory DosenHomeModel.placeholder() {
    return const DosenHomeModel(
      title: 'Dashboard Dosen',
      subtitle: 'Halaman ini disiapkan untuk role dosen.',
    );
  }
}
