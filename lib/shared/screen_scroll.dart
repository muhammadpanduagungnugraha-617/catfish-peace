import 'package:flutter/material.dart';

import '../core/breakpoints.dart';

/// Pembungkus isi screen: scroll + padding responsif + lebar maksimum.
class ScreenScroll extends StatelessWidget {
  const ScreenScroll({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final wide = Breakpoints.isWide(context);
    final h = wide ? 32.0 : 16.0;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(h, wide ? 32 : 16, h, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}
