import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kesalahan auth yang pesannya sudah siap ditampilkan ke user (Bahasa Indonesia).
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Pembungkus FirebaseAuth: login, logout, dan pemetaan error.
class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(messageFor(e.code));
    } catch (_) {
      throw const AuthFailure('Gagal masuk. Coba lagi.');
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Kode error Firebase -> pesan untuk user.
  /// Kredensial salah sengaja dibuat satu pesan umum supaya tidak membocorkan
  /// apakah email tertentu terdaftar atau tidak.
  static String messageFor(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email atau kata sandi salah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan. Hubungi admin.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa menit lagi.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      case 'operation-not-allowed':
        return 'Login email & kata sandi belum diaktifkan di Firebase.';
      default:
        return 'Gagal masuk. Coba lagi.';
    }
  }
}

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(firebaseAuthProvider)),
);

/// Status sesi: `null` = belum login. Firebase menyimpan sesi di perangkat,
/// jadi pada pembukaan app berikutnya stream ini langsung memberi user lama.
final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).authStateChanges(),
);

/// Jeda minimum splash supaya logo tidak berkedip saat sesi cepat terbaca.
final splashGateProvider = FutureProvider<void>(
  (ref) => Future<void>.delayed(const Duration(milliseconds: 1200)),
);
