import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_config.dart';
import '../../../core/database_provider.dart';
import '../../../shared/error_card.dart';
import '../../../shared/offline_banner.dart';
import '../../../shared/screen_scroll.dart';
import '../../../shared/section_header.dart';
import '../../../shared/shimmer_box.dart';
import '../../dashboard/application/pool_status_provider.dart';
import '../application/control_provider.dart';
import '../domain/pool_control.dart';
import 'widgets/manual_control_tile.dart';
import 'widgets/mode_otomatis_card.dart';

typedef _ActuatorStyle = ({
  String title,
  IconData icon,
  Color color,
  Color background,
});

_ActuatorStyle _styleOf(Actuator a) => switch (a) {
      Actuator.pompaBuangAir => (
          title: 'Pompa Buang Air',
          icon: Icons.waves_rounded,
          color: AppColors.iconBlue,
          background: AppColors.iconBlueBg,
        ),
      Actuator.pompaIsiAir => (
          title: 'Pompa Isi Air',
          icon: Icons.opacity_rounded,
          color: AppColors.iconBlue,
          background: AppColors.iconBlueBg,
        ),
      Actuator.pompaProbiotik => (
          title: 'Pompa Probiotik',
          icon: Icons.biotech_outlined,
          color: AppColors.amanBannerTitle,
          background: AppColors.amanBannerBg,
        ),
      Actuator.aerator => (
          title: 'Aerator Oksigen',
          icon: Icons.air_rounded,
          color: AppColors.iconPurple,
          background: AppColors.iconPurpleBg,
        ),
    };

/// Teks status berasal dari status ASLI relay (`kolam_relay`), bukan dari
/// perintah. Di mode manual, bila perintah belum sama dengan kondisi relay,
/// ditandai "menunggu alat" supaya user tahu perintahnya belum dieksekusi.
String _statusText({
  required bool? actual,
  required bool command,
  required bool auto,
}) {
  if (actual == null) return 'Status belum dilaporkan alat';
  final base = actual ? 'Sedang nyala' : 'Sedang mati';
  if (!auto && command != actual) return '$base · menunggu alat…';
  return base;
}

Future<void> _send(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
  } on ControlFailure catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(e.message)));
  }
}

class KontrolScreen extends ConsumerWidget {
  const KontrolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceOffline =
        ref.watch(poolConnectionProvider) == PoolConnection.offline;
    final controlAsync = ref.watch(poolControlProvider);
    final relay = ref.watch(poolRelayProvider).valueOrNull;
    final appOnline = ref.watch(firebaseConnectedProvider).valueOrNull ?? true;
    final actions = ref.read(poolControlActionsProvider);

    final control = controlAsync.valueOrNull;
    if (control == null) {
      if (controlAsync.hasError) {
        return ScreenScroll(
          children: [
            ErrorCard(
              message:
                  'Kontrol kolam tidak bisa dimuat. Periksa koneksi atau izin akses.',
              onRetry: () => ref.invalidate(poolControlProvider),
            ),
          ],
        );
      }
      return const ScreenScroll(
        children: [
          ShimmerBox(height: 84),
          SizedBox(height: 12),
          ShimmerBox(height: 72),
          SizedBox(height: 12),
          ShimmerBox(height: 72),
        ],
      );
    }

    // Perintah hanya boleh dikirim bila app tersambung ke server DAN
    // (bila flag aktif) alatnya online. Kalau tidak, perintah tidak akan
    // sampai, atau tertahan dan baru dieksekusi belakangan.
    final canSend =
        appOnline && !(deviceOffline && kDisableControlsWhenOffline);
    final canManual = canSend && !control.modeOtomatis;

    return ScreenScroll(
      children: [
        if (!appOnline) ...[
          const OfflineBanner(
            message: 'Aplikasi tidak terhubung ke server. Perintah tidak dikirim.',
          ),
          const SizedBox(height: 20),
        ] else if (deviceOffline) ...[
          const OfflineBanner(),
          const SizedBox(height: 20),
        ],
        const SectionHeader(
          title: 'Kontrol Kolam',
          subtitle: 'Atur perangkat untuk menjaga kualitas air',
        ),
        const SizedBox(height: 12),
        ModeOtomatisCard(
          value: control.modeOtomatis,
          enabled: canSend,
          onChanged: (v) => _send(
            context,
            () => actions.setModeOtomatis(v, currentRelay: relay),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'Kendali Manual',
          subtitle: 'Nonaktifkan mode otomatis untuk kendali manual',
        ),
        const SizedBox(height: 12),
        for (final a in Actuator.values) ...[
          Builder(builder: (_) {
            final style = _styleOf(a);
            final actual = relay?.valueOf(a);
            final command = control.valueOf(a);
            return ManualControlTile(
              icon: style.icon,
              iconColor: style.color,
              iconBackground: style.background,
              title: style.title,
              // Mode otomatis: tampilkan kondisi asli relay (perintah lama
              // tidak relevan). Mode manual: ikuti perintah supaya responsif.
              isOn: control.modeOtomatis ? (actual ?? false) : command,
              statusText: _statusText(
                actual: actual,
                command: command,
                auto: control.modeOtomatis,
              ),
              enabled: canManual,
              onChanged: (v) => _send(context, () => actions.setActuator(a, v)),
            );
          }),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
