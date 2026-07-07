import 'package:flutter/material.dart';

/// Web/desktop stub — PDFView haipatikani hapa.
Widget buildMobilePdfView({
  required String filePath,
  required void Function(int?, int?) onRender,
  required void Function(dynamic) onError,
  void Function(int?, int?)? onPageChanged,
}) {
  return const Center(
    child: Text(
      'PDF preview is available on Android/iOS.',
      style: TextStyle(color: Colors.white54),
    ),
  );
}
