import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'helpers/pdf_temp_file.dart';
import 'studybolt_ads.dart';
import 'widgets/mobile_pdf_view.dart';

/// Skrini ya kusoma PDF ndani ya app — Notes & Past Papers.
/// Banner iko chini; PDF haizibiwe na banner.
class PDFViewerPage extends StatefulWidget {
  const PDFViewerPage({
    super.key,
    required this.title,
    required this.fileUrl,
  });

  final String title;
  final String fileUrl;

  @override
  State<PDFViewerPage> createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? _localPdfPath;
  String? _error;
  bool _loading = true;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    StudyBoltInterstitialManager.onPdfOpened();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (kIsWeb) {
        setState(() {
          _loading = false;
          _localPdfPath = null;
        });
        return;
      }

      final path = await savePdfFromUrl(widget.fileUrl);
      if (!mounted) return;

      if (path == null) {
        setState(() {
          _loading = false;
          _error = 'Imeshindwa kupakua PDF.';
        });
        return;
      }

      setState(() {
        _localPdfPath = path;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handleBack() async {
    await studyBoltAds.showInterstitial(
      respectBackFrequencyCap: true,
      onDismissed: () {
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.fileUrl);
    if (uri == null) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          title: Text(
            widget.title,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: const Color(0xFF121212),
          foregroundColor: const Color(0xFFD4AF37),
          leading: BackButton(onPressed: _handleBack),
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildPdfArea(),
            ),
            // BANNER chini kabisa — PDF iko juu yake tu
            const SafeArea(
              top: false,
              child: StudyBoltBannerAdSlot(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfArea() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[300]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPdf,
                child: const Text('Jaribu tena'),
              ),
            ],
          ),
        ),
      );
    }

    if (kIsWeb || _localPdfPath == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'Kwenye web, fungua PDF kwenye browser.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openExternally,
                child: const Text('Fungua PDF'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_totalPages > 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'Ukurasa ${_currentPage + 1} / $_totalPages',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        Expanded(
          child: buildMobilePdfView(
            filePath: _localPdfPath!,
            onRender: (pages, _) {
              if (!mounted) return;
              setState(() => _totalPages = pages ?? 0);
            },
            onError: (error) {
              if (!mounted) return;
              setState(() => _error = error.toString());
            },
            onPageChanged: (page, _) {
              if (!mounted || page == null) return;
              setState(() => _currentPage = page);
            },
          ),
        ),
      ],
    );
  }
}
