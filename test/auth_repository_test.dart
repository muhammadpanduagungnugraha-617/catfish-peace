import 'package:catfish_peace/features/auth/application/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRepository.messageFor', () {
    test('semua jenis kredensial salah memberi satu pesan yang sama', () {
      const wrong = 'Email atau kata sandi salah.';
      for (final code in [
        'invalid-credential',
        'invalid-login-credentials',
        'wrong-password',
        'user-not-found',
      ]) {
        expect(AuthRepository.messageFor(code), wrong, reason: code);
      }
    });

    test('kode lain dipetakan ke pesan yang sesuai', () {
      expect(AuthRepository.messageFor('invalid-email'),
          'Format email tidak valid.');
      expect(AuthRepository.messageFor('user-disabled'),
          'Akun ini dinonaktifkan. Hubungi admin.');
      expect(AuthRepository.messageFor('too-many-requests'),
          'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.');
      expect(AuthRepository.messageFor('network-request-failed'),
          'Tidak ada koneksi internet. Periksa jaringan Anda.');
    });

    test('kode tak dikenal jatuh ke pesan umum', () {
      expect(AuthRepository.messageFor('kode-aneh'), 'Gagal masuk. Coba lagi.');
    });
  });
}
