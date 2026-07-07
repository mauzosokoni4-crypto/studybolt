import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

/// Mobile PDF renderer — badilisha rangi/scroll hapa ukihitaji.
Widget buildMobilePdfView({
  required String filePath,
  required void Function(int?, int?) onRender,
  required void Function(dynamic) onError,
  void Function(int?, int?)? onPageChanged,
}) {
  return PDFView(
    filePath: filePath,
    enableSwipe: true,
    swipeHorizontal: false,
    autoSpacing: true,
    pageFling: true,
    onRender: (pages) => onRender(pages, null),
    onError: onError,
    onPageChanged: onPageChanged,
  );
}
