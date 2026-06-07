import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';

void main() {
  group('UserModel Tests', () {
    test('fromJson and toJson roundtrip', () {
      final json = <String, dynamic>{
        '_id': 'usr-123',
        'nomor_induk': '241511010',
        'password_hash': 'hashed-password',
        'name': 'Mahasiswa Polban',
        'role': 'mahasiswa',
        'isActive': true,
        'createdAt': '2026-05-03T00:00:00.000Z',
        'email': '241511010@students.example',
        'programStudy': 'D4 Teknik Informatika',
        'photoUrl': 'https://example.test/photo.png',
        'source': 'test',
      };

      final model = UserModel.fromJson(json);

      expect(model.id, equals('usr-123'));
      expect(model.username, equals('241511010'));
      expect(model.nomorInduk, equals('241511010'));
      expect(model.passwordHash, equals('hashed-password'));
      expect(model.role, equals('mahasiswa'));
      expect(model.isActive, isTrue);
      expect(model.createdAt, equals('2026-05-03T00:00:00.000Z'));
      expect(model.email, equals('241511010@students.example'));

      final generatedJson = model.toJson();
      
      expect(generatedJson['_id'], equals('usr-123'));
      expect(generatedJson['nomor_induk'], equals('241511010'));
      expect(generatedJson['password_hash'], equals('hashed-password'));
      expect(generatedJson['role'], equals('mahasiswa'));
      expect(generatedJson['isActive'], isTrue);
      expect(generatedJson['email'], equals('241511010@students.example'));
      expect(generatedJson['programStudy'], equals('D4 Teknik Informatika'));
    });

    test('copyWith updates fields correctly', () {
      final model = UserModel.fromJson(<String, dynamic>{
        '_id': 'usr-123',
        'nomor_induk': '241511010',
        'password_hash': 'hashed',
        'name': 'Mahasiswa',
        'role': 'mahasiswa',
        'isActive': true,
      });

      final updatedModel = model.copyWith(
        name: 'Mahasiswa Edited',
        isActive: false,
      );

      expect(updatedModel.id, equals('usr-123'));
      expect(updatedModel.name, equals('Mahasiswa Edited'));
      expect(updatedModel.isActive, isFalse);
      expect(updatedModel.role, equals('mahasiswa'));
      expect(updatedModel.passwordHash, equals('hashed'));
    });
  });
}
