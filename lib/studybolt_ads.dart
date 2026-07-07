import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// =============================================================================
// WEB ADS — AdMob (mobile) vs AdSense (web)
// =============================================================================
// Mobile: google_mobile_ads BannerAd / InterstitialAd (test IDs below).
// Web: AdMob does NOT run on Flutter web. Use Google AdSense instead:
//   1. Uncomment the AdSense block in web/index.html
//   2. Or replace the kIsWeb placeholder below with HtmlElementView + ad slot
//   3. See https://support.google.com/adsense/answer/9274019
// =============================================================================
const String kStudyBoltTestBannerAdUnitId =
    'ca-app-pub-3940256099942544/6300978111';
const String kStudyBoltTestInterstitialAdUnitId =
    'ca-app-pub-3940256099942544/1033173712';

// =============================================================================
// FREQUENCY CAPPING — badilisha thamani hizi kwa manual tuning
// =============================================================================
const int kInterstitialMinIntervalSeconds = 300; // dakika 5
const int kInterstitialPdfViewThreshold = 3; // PDF 3 tofauti

/// Inahesabu muda na idadi ya PDF ili kuzuia interstitial kila sekunde.
class StudyBoltInterstitialManager {
  static DateTime? _lastInterstitialAt;
  static int _pdfsOpenedSinceLastInterstitial = 0;

  static void onPdfOpened() {
    _pdfsOpenedSinceLastInterstitial++;
  }

  static void onInterstitialShown() {
    _lastInterstitialAt = DateTime.now();
    _pdfsOpenedSinceLastInterstitial = 0;
  }

  /// Tangazo la Back kutoka PDFViewerPage linaonyeshwa tu ikiwa:
  /// - zimepita >= 5 dakika tangu interstitial ya mwisho, AU
  /// - mtumiaji amefungua PDF 3 tofauti tangu interstitial ya mwisho.
  static bool shouldShowBackInterstitial() {
    if (_lastInterstitialAt != null) {
      final elapsed =
          DateTime.now().difference(_lastInterstitialAt!).inSeconds;
      if (elapsed >= kInterstitialMinIntervalSeconds) return true;
    }
    return _pdfsOpenedSinceLastInterstitial >= kInterstitialPdfViewThreshold;
  }
}

/// Huduma ya Interstitial Ads — preload + show + frequency cap.
class StudyBoltAdsService {
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;

  void preloadInterstitial() {
    if (kIsWeb || _isLoading || _interstitialAd != null) return;

    _isLoading = true;
    InterstitialAd.load(
      adUnitId: kStudyBoltTestInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial load failed: $error');
          _interstitialAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  Future<void> showInterstitial({
    required VoidCallback onDismissed,
    bool respectBackFrequencyCap = false,
  }) async {
    if (kIsWeb) {
      onDismissed();
      return;
    }

    if (respectBackFrequencyCap &&
        !StudyBoltInterstitialManager.shouldShowBackInterstitial()) {
      onDismissed();
      return;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      onDismissed();
      preloadInterstitial();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        StudyBoltInterstitialManager.onInterstitialShown();
        preloadInterstitial();
        onDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial show failed: $error');
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitial();
        onDismissed();
      },
    );

    _interstitialAd = null;
    await ad.show();
  }
}

/// Singleton — tumia hii kwenye WhatsApp na PDF back button.
final StudyBoltAdsService studyBoltAds = StudyBoltAdsService();

// =============================================================================
// BANNER WIDGET — placeholder + AdMob banner (reusable)
// Badilisha rangi/ukubwa wa placeholder hapa chini.
// =============================================================================
class StudyBoltBannerAdSlot extends StatefulWidget {
  const StudyBoltBannerAdSlot({super.key});

  @override
  State<StudyBoltBannerAdSlot> createState() => _StudyBoltBannerAdSlotState();
}

class _StudyBoltBannerAdSlotState extends State<StudyBoltBannerAdSlot> {
  BannerAd? _bannerAd;
  bool _adReady = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _bannerAd = BannerAd(
        adUnitId: kStudyBoltTestBannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) setState(() => _adReady = true);
          },
          onAdFailedToLoad: (ad, _) => ad.dispose(),
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      alignment: Alignment.center,
      color: const Color(0xFF000000),
      child: _adReady && _bannerAd != null
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : Container(
              // PLACEHOLDER — badilisha urefu/rangi/border hapa
              height: 50,
              width: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x66FFC107)),
              ),
              child: Center(
                child: Text(
                  kIsWeb ? 'AdSense Placeholder Banner' : 'AdMob Placeholder Banner',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ),
    );
  }
}
