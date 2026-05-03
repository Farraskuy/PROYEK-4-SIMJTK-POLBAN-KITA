import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';

void main() {
  test('UserModel menerima field lama dan baru', () {
    final model = UserModel.fromJson(<String, dynamic>{
      '_id': 'usr-123',
      'nomor_induk': '241511010',
      'password_hash': 'hashed-password',
      'name': 'Mahasiswa Polban',
      'role': 'staff',
      'isActive': true,
      'createdAt': '2026-05-03T00:00:00.000Z',
      'email': '241511010@students.example',
      'programStudy': 'D4 Teknik Informatika',
      'photoUrl': 'https://example.test/photo.png',
      'source': 'test',
    });

    expect(model.id, equals('usr-123'));
    expect(model.username, equals('241511010'));
    expect(model.nomorInduk, equals('241511010'));
    expect(model.passwordHash, equals('hashed-password'));
    expect(model.role, equals('teknisi'));
    expect(model.isActive, isTrue);
    expect(model.createdAt, equals('2026-05-03T00:00:00.000Z'));
    expect(model.email, equals('241511010@students.example'));

    final json = model.toJson();
    expect(json['_id'], equals('usr-123'));
    expect(json['nomor_induk'], equals('241511010'));
    expect(json['password_hash'], equals('hashed-password'));
    expect(json['role'], equals('teknisi'));
  });
}