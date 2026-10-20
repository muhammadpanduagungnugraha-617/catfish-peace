import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Blok skeleton untuk state loading.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.width, this.height, this.radius = 16});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE3EAF0),
      highlightColor: const Color(0xFFF6F9FB),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
