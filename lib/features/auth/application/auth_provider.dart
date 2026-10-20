import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Status login. Tahap UI: dummy (false = belum login).
/// Nanti diganti stream dari FirebaseAuth.authStateChanges().
final authProvider = StateProvider<bool>((ref) => false);
