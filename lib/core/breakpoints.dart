import 'package:flutter/widgets.dart';

/// Layar >= [wide] memakai layout web (kartu 4 kolom, header tanpa subjudul).
class Breakpoints {
  Breakpoints._();

  static const double wide = 720;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wide;
}
