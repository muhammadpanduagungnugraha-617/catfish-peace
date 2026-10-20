import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Kartu error sederhana (belum ada desain) memakai token warna Bahaya.
class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bahayaIconBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bahaya.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.bahaya),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gagal memuat data',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.bahayaBannerTitle,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
