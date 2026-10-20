import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/pool_control.dart';

/// Tahap UI: state lokal. Nanti setiap setter menulis ke RTDB `kolam_control`
/// dan state dibaca dari stream-nya.
class PoolControlNotifier extends Notifier<PoolControl> {
  @override
  PoolControl build() => const PoolControl();

  void setModeOtomatis(bool v) => state = state.copyWith(modeOtomatis: v);
  void setPompaBuangAir(bool v) => state = state.copyWith(pompaBuangAir: v);
  void setPompaIsiAir(bool v) => state = state.copyWith(pompaIsiAir: v);
  void setAerator(bool v) => state = state.copyWith(aerator: v);
}

final poolControlProvider =
    NotifierProvider<PoolControlNotifier, PoolControl>(PoolControlNotifier.new);
