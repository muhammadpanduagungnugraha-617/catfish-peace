import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_config.dart';
import '../../../shared/offline_banner.dart';
import '../../../shared/screen_scroll.dart';
import '../../../shared/section_header.dart';
import '../../dashboard/application/pool_status_provider.dart';
import '../application/control_provider.dart';
import 'widgets/manual_control_tile.dart';
import 'widgets/mode_otomatis_card.dart';

class KontrolScreen extends ConsumerWidget {
  const KontrolScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(poolStatusProvider).valueOrNull;
    final offline = status != null && !status.isOnline;
    final control = ref.watch(poolControlProvider);
    final notifier = ref.read(poolControlProvider.notifier);

    final canManual =
        !control.modeOtomatis && !(offline && kDisableControlsWhenOffline);

    return ScreenScroll(
      children: [
        if (offline) ...[
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
          onChanged: notifier.setModeOtomatis,
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          title: 'Kendali Manual',
          subtitle: 'Nonaktifkan mode otomatis untuk kendali manual',
        ),
        const SizedBox(height: 12),
        ManualControlTile(
          icon: Icons.waves_rounded,
          iconColor: AppColors.iconBlue,
          iconBackground: AppColors.iconBlueBg,
          title: 'Pompa Buang Air',
          isOn: control.pompaBuangAir,
          enabled: canManual,
          onChanged: notifier.setPompaBuangAir,
        ),
        const SizedBox(height: 12),
        ManualControlTile(
          icon: Icons.opacity_rounded,
          iconColor: AppColors.iconBlue,
          iconBackground: AppColors.iconBlueBg,
          title: 'Pompa Isi Air',
          isOn: control.pompaIsiAir,
          enabled: canManual,
          onChanged: notifier.setPompaIsiAir,
        ),
        const SizedBox(height: 12),
        ManualControlTile(
          icon: Icons.air_rounded,
          iconColor: AppColors.iconPurple,
          iconBackground: AppColors.iconPurpleBg,
          title: 'Aerator Oksigen',
          isOn: control.aerator,
          enabled: canManual,
          onChanged: notifier.setAerator,
        ),
      ],
    );
  }
}
