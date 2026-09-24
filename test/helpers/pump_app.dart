import 'package:flutter/material.dart';

import 'package:saasify/core/theme/app_theme.dart';

Widget wrapWithApp(Widget child, {Size surfaceSize = const Size(390, 844)}) {
  return MaterialApp(
    theme: AppTheme.light(),
    home: MediaQuery(
      data: MediaQueryData(size: surfaceSize),
      child: child,
    ),
  );
}
