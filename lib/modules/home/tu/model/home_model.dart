class TuHomeModel {
  final String title;
  final String subtitle;

  const TuHomeModel({
    required this.title,
    required this.subtitle,
  });

  factory TuHomeModel.placeholder() {
    return const TuHomeModel(
      title: 'Dashboard Tata Usaha',
      subtitle: 'Halaman ini disiapkan untuk role TU.',
    );
  }
}
