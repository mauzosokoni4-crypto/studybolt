import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'analytics/analytics_service.dart';
import 'app_config.dart';
import 'payment_info_page.dart';
import 'pdf_viewer_page.dart';
import 'studybolt_ads.dart';

SupabaseClient get _supabase => Supabase.instance.client;

bool _tutorIsVisible(Map<String, dynamic> data) {
  if (data['is_active'] == false) return false;
  if (AppConfig.isTrialMode) return true;
  return data['is_paid'] == true;
}

class UniversityOption {
  const UniversityOption({required this.id, required this.name});

  final int id;
  final String name;
}

int? _parseRowId(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

bool _sameRowId(dynamic value, int? expectedId) {
  if (expectedId == null) return false;
  return _parseRowId(value) == expectedId;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      await MobileAds.instance.initialize();
      studyBoltAds.preloadInterstitial();
    } catch (e) {
      debugPrint('Mobile Ads init error: $e');
    }
  }

  try {
    await Supabase.initialize(
      url: 'https://ctolbrpdmbegartlijps.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN0b2xicnBkbWJlZ2FydGxpanBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5MzU4NTAsImV4cCI6MjA5NTUxMTg1MH0.s_V0yLMqMmPsephW0J3xrx_xeQ4o7ZVWU2ecAd5QnhE',
    );
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  runApp(const StudyBoltApp());
}

class StudyBoltApp extends StatelessWidget {
  const StudyBoltApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFFD4AF37),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          onPrimary: Color(0xFF000000),
          secondary: Color(0xFF1E1E1E),
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
          onSecondary: Colors.white70,
        ),
        cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
        dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E1E1E)),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E1E),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3A3A3A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD4AF37)),
          ),
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white54),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFD4AF37),
          selectionColor: Color(0x66D4AF37),
          selectionHandleColor: Color(0xFFD4AF37),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF000000),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFD4AF37)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD4AF37),
            side: const BorderSide(color: Color(0xFFD4AF37)),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF121212),
          selectedItemColor: Color(0xFFD4AF37),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        dividerColor: const Color(0xFF3A3A3A),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white70),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white60),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white70),
          labelSmall: TextStyle(color: Colors.white54),
        ),
      ),
      home: const UniversityListScreen(),
    );
  }
}
Future<void> checkForUpdate(BuildContext context) async {
  try {
    final config = await _supabase
        .from('app_config')
        .select('min_version, download_url')
        .single();

   const currentVersion = '1.0.0';
    final minVersion = config['min_version'] as String;
    final downloadUrl = config['download_url'] as String;

    if (currentVersion != minVersion && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Update Inapatikana!',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Toleo jipya la StudyBolt lipo. Bonyeza "Download" kupata update.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => launchUrl(Uri.parse(downloadUrl)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text('Download', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    // Hakuna connection - endelea kawaida
  }
}

class SplashRouterScreen extends StatefulWidget {
  const SplashRouterScreen({super.key});

  @override
  State<SplashRouterScreen> createState() => _SplashRouterScreenState();
}

class _SplashRouterScreenState extends State<SplashRouterScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(_openUniversitySelector());
    @override
void initState() {
  super.initState();
  unawaited(_openUniversitySelector());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    checkForUpdate(context);
  });
}
  }

  Future<void> _openUniversitySelector() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const UniversitySelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Icon(Icons.bolt_rounded, size: 120, color: Colors.amber),
      ),
    );
  }
}

class UniversitySelectionScreen extends StatefulWidget {
  const UniversitySelectionScreen({super.key});

  @override
  State<UniversitySelectionScreen> createState() =>
      _UniversitySelectionScreenState();
}

class UniversityListScreen extends UniversitySelectionScreen {
  const UniversityListScreen({super.key});
}

class _UniversitySelectionScreenState extends State<UniversitySelectionScreen> {
  String _query = '';
  late Future<List<UniversityOption>> _universitiesFuture;

  @override
  void initState() {
    super.initState();
    _universitiesFuture = _fetchUniversities();
  }

  Future<List<UniversityOption>> _fetchUniversities() async {
    final rows = await _supabase
        .from('university')
        .select('id, name')
        .order('name', ascending: true);

    final seen = <int>{};
    final universities = <UniversityOption>[];

    for (final row in rows as List) {
      final id = _parseRowId(row['id']);
      final name = (row['name'] ?? '').toString().trim();
      if (id == null || name.isEmpty || seen.contains(id)) continue;
      seen.add(id);
      universities.add(UniversityOption(id: id, name: name));
    }

    universities.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return universities;
  }

  void _reloadUniversities() {
    setState(() {
      _universitiesFuture = _fetchUniversities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select University'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search university...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                filled: true,
                fillColor: const Color(0xFF121212),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<UniversityOption>>(
                future: _universitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Failed to load universities.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red[300]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _reloadUniversities,
                              child: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final universities = snapshot.data ?? [];

                  final results = universities
                      .where((u) => u.name
                          .toLowerCase()
                          .contains(_query.toLowerCase()))
                      .toList();

                  if (results.isEmpty) {
                    return const Center(
                      child: Text(
                        'No universities found.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) =>
                        Divider(color: Colors.grey[850], height: 1),
                    itemBuilder: (context, index) {
                      final university = results[index];
                      return ListTile(
                        title: Text(
                          university.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.amber,
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WelcomeScreen(
                                universityId: university.id,
                                universityName: university.name,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StudyBoltDrawer extends StatelessWidget {
  const StudyBoltDrawer({super.key});

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/255747840249');
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callSupport() async {
    final uri = Uri.parse('tel:+255747840249');
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0F0F0F),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 185, 141, 10).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.bolt, color: Colors.amber, size: 26),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'StudyBolt',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[850]),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: Color.fromARGB(255, 240, 185, 21)),
              title: const Text('About Us', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Premium Primal Hub', style: TextStyle(color: Color.fromARGB(255, 150, 133, 5))),
              onTap: () {
                Navigator.pop(context);
                showDialog<void>(
                  context: context,
                  builder: (c) => AlertDialog(
                    backgroundColor: const Color(0xFF121212),
                    title: const Text('About Us', style: TextStyle(color: Colors.white)),
                    content: Text(
                      'StudyBolt dhumuni lake kuu ni kuhakikisha unampata mwalimu mara tu unapohitaji... Tunatamani kila mwenye uwezo ikawe fursa na kila mwanafunzi apate urahisi zaidi.',
                      style: TextStyle(color: Colors.grey[300], height: 1.35),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_rounded, color: Colors.green),
              title:
                  const Text('WhatsApp Us', style: TextStyle(color: Colors.white)),
              subtitle:
                  Text('+255747840249', style: TextStyle(color: Colors.grey[500])),
              onTap: () async {
                Navigator.pop(context);
                await _openWhatsApp();
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_rounded, color: Color.fromARGB(255, 168, 127, 5)),
              title: const Text('Call Us', style: TextStyle(color: Colors.white)),
              subtitle:
                  Text('+255747840249', style: TextStyle(color: Colors.grey[500])),
              onTap: () async {
                Navigator.pop(context);
                await _callSupport();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- WELCOME SCREEN ---
class WelcomeScreen extends StatelessWidget {
  final int universityId;
  final String universityName;

  const WelcomeScreen({
    super.key,
    required this.universityId,
    required this.universityName,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 36),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 120, color: Color.fromARGB(255, 246, 134, 5)),
                      const SizedBox(height: 8),
                      const Text(
                        "StudyBolt",
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 77, 58, 1),
                        ),
                      ),
                      const Text(
                        "PREMIUM PRIMAL HUB",
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 4,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'SOMA KISHUA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(175, 255, 193, 7),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        universityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          letterSpacing: 1.3,
                        ),
                      ),
                      const SizedBox(height: 54),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF121212), // Inafanya AppBar iwe nyeusi kama ya Notes
                       foregroundColor: const Color(0xFFD4AF37), // Inafanya maandishi ya "Find Tutors • TIA" yawe ya Gold kama ya Notes  
                          
                          minimumSize: const Size(280, 55),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentMainNavigation(
                              universityId: universityId,
                              universityName: universityName,
                            ),
                          ),
                        ),
                        child: const Text(
                          "MIMI NI MWANAFUNZI",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                      style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      foregroundColor: const Color(0xFFD4AF37),
                      minimumSize: const Size(288, 55),
                      shape: const StadiumBorder(),
                        ),
                      onPressed: () => Navigator.push(
                     context,
                          MaterialPageRoute(builder: (_) => const TutorRegistrationScreen()),
                        ),
                        child: const Text(
                          "MIMI NI MWALIMU",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Column(
                children: [
                  const Text(
                    "Mpate mwalimu wako sasa hivi kwa uharaka na wepesi zaidi popote ulipo.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x66FFC107)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.security_rounded, color: Colors.amber, size: 18),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "Pay via M-Pesa or Bank — send proof on WhatsApp",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- STUDENT NAVIGATION ---
class StudentMainNavigation extends StatefulWidget {
  final int universityId;
  final String universityName;

  const StudentMainNavigation({
    super.key,
    required this.universityId,
    required this.universityName,
  });
  @override
  State<StudentMainNavigation> createState() => _StudentMainNavigationState();
}

class _StudentMainNavigationState extends State<StudentMainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logScreenView(screenName: 'student_dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      TutorSearchPage(
        universityId: widget.universityId,
        universityName: widget.universityName,
      ),
      LibraryPage(
        title: "Notes",
        collection: "notes",
        university: widget.universityName,
        universityId: widget.universityId,
      ),
      LibraryPage(
        title: "Past Papers",
        collection: "pastpapers",
        university: widget.universityName,
        universityId: widget.universityId,
      ),
      LibraryPage(
        title: "Research & Projects",
        collection: "projects",
        university: widget.universityName,
        universityId: widget.universityId,
      ),
    ];
    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => PaymentInfoPage.open(context),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: const Color(0xFF000000),
        icon: const Icon(Icons.payment_rounded),
        label: const Text('Malipo'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF000000),
        selectedItemColor: const Color(0xFFD4AF37),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person_search), label: "Mwalimu"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Notes"),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: "Papers"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Research"),
        ],
      ),
    );
  }
}

// --- TUTOR SEARCH ---
class TutorSearchPage extends StatefulWidget {
  final int universityId;
  final String universityName;

  const TutorSearchPage({
    super.key,
    required this.universityId,
    required this.universityName,
  });

  @override
  State<TutorSearchPage> createState() => _TutorSearchPageState();
}

class _TutorSearchPageState extends State<TutorSearchPage> {
  String key = "";
  final Map<int, String> _collegeNames = {};
  BannerAd? _bannerAd;
  bool _adReady = false;

  @override
  void initState() {
    super.initState();
    _loadCollegeNames();
    if (!kIsWeb) {
      _bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/6300978111',
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) setState(() => _adReady = true);
          },
          onAdFailedToLoad: (ad, _) {
            ad.dispose();
          },
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadCollegeNames() async {
    try {
      final rows = await _supabase.from('university').select('id, name');
      if (!mounted) return;
      setState(() {
        for (final row in rows as List) {
          final id = _parseRowId(row['id']);
          final name = (row['name'] ?? '').toString().trim();
          if (id != null && name.isNotEmpty) {
            _collegeNames[id] = name;
          }
        }
      });
    } catch (e) {
      debugPrint('Load college names error: $e');
    }
  }

  String _collegeLabel(dynamic collegeId) {
    final id = _parseRowId(collegeId);
    if (id == null) return 'Unknown';
    return _collegeNames[id] ?? 'Unknown';
  }

  Future<void> _openWhatsApp(String phoneRaw, {int index = 0}) async {
    final normalized = _normalizedPhoneAt(phoneRaw, index);
    if (normalized == null) return;

    // INTERSTITIAL kabla ya WhatsApp — onyeshwa kwanza, kisha fungua chat.
    await studyBoltAds.showInterstitial(
      respectBackFrequencyCap: false,
      onDismissed: () => _launchWhatsApp(normalized),
    );
  }

  Future<void> _callPhone(String phoneRaw, {int index = 1}) async {
    final normalized = _normalizedPhoneAt(phoneRaw, index);
    if (normalized == null) return;
    await _launchPhoneCall(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const StudyBoltDrawer(),
      appBar: AppBar(
        title: Text("Find Tutors • ${widget.universityName}"),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFD4AF37),
        
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            alignment: Alignment.center,
            child: _adReady && _bannerAd != null
                ? SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  )
                : Container(
                    height: 50,
                    width: 320,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x66FFC107)),
                    ),
                    child: const Center(
                      child: Text(
                        'AdMob Placeholder Banner',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              onChanged: (v) => setState(() => key = v.toLowerCase()),
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(fillColor: Colors.white, filled: true, hintText: "Search Subject or College...", prefixIcon: Icon(Icons.search)),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase.from('tutors').stream(primaryKey: ['id']),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    !snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  );
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load tutors.\n${snap.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[300]),
                    ),
                  );
                }

                final docs = (snap.data ?? []).where((data) {
                  if (!_sameRowId(data['college_id'], widget.universityId)) {
                    return false;
                  }
                  if (!_tutorIsVisible(data)) return false;
                  final subject =
                      (data['subject'] ?? '').toString().toLowerCase();
                  final collegeName =
                      _collegeLabel(data['college_id']).toLowerCase();
                  if (key.isEmpty) return true;
                  return subject.contains(key) || collegeName.contains(key);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tutors found for this university yet.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i];
                    final phone = (data['phone'] ?? '').toString();
                    final collegeName = _collegeLabel(data['college_id']);
                    final phoneParts = _splitPhoneParts(phone);
                    final whatsAppLabel =
                        phoneParts.isNotEmpty ? phoneParts[0] : phone;
                    final callLabel = phoneParts.length > 1
                        ? phoneParts[1]
                        : (phoneParts.isNotEmpty ? phoneParts[0] : phone);

                    return ListTile(
                      title: Text(data['name'] ?? '', style: const TextStyle(color: Color.fromARGB(255, 143, 108, 4), fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 2,),
                      subtitle: Text("${data['subject']} - $collegeName"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
  IconButton(
    onPressed: () => _openWhatsApp(phone, index: 0),
    icon: const Icon(
      Icons.chat_rounded,
      color: Colors.green,
      size: 26,
    ),
  ),
  IconButton(
    onPressed: () => _callPhone(phone, index: 1),
    icon: const Icon(
      Icons.call_rounded,
      color: Colors.amber,
      size: 26,
    ),
  ),
],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Phone helpers ---
List<String> _splitPhoneParts(String raw) {
  return raw
      .split('/')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
}

bool _isValidPhonePart(String part) {
  final digits = part.replaceAll(RegExp(r'\D'), '');
  return digits.length >= 9;
}

String _normalizePhoneKey(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';
  if (digits.startsWith('0') && digits.length >= 9) {
    return '255${digits.substring(1)}';
  }
  if (!digits.startsWith('255') && digits.length == 9) {
    return '255$digits';
  }
  return digits;
}

String _formatPhoneForStorage(String raw) {
  return _splitPhoneParts(raw)
      .map(_normalizePhoneKey)
      .where((number) => number.isNotEmpty)
      .join('/');
}

String? _normalizedPhoneAt(String raw, int index) {
  final parts = _splitPhoneParts(raw);
  if (parts.isEmpty) return null;
  final part = index < parts.length ? parts[index] : parts.first;
  final normalized = _normalizePhoneKey(part);
  return normalized.isEmpty ? null : normalized;
}

Future<void> _launchWhatsApp(String normalizedPhone) async {
  final uri = Uri.parse('whatsapp://send?phone=$normalizedPhone');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }

  final webUri = Uri.parse('https://wa.me/$normalizedPhone');
  if (!await canLaunchUrl(webUri)) return;
  await launchUrl(webUri, mode: LaunchMode.externalApplication);
}

Future<void> _launchPhoneCall(String normalizedPhone) async {
  final uri = Uri.parse('tel:$normalizedPhone');
  if (!await canLaunchUrl(uri)) return;
  await launchUrl(uri);
}

// --- LIBRARY PAGES ---
class LibraryPage extends StatefulWidget {
  final String title;
  final String collection;
  final String university;
  final int universityId;
  const LibraryPage({
    super.key,
    required this.title,
    required this.collection,
    required this.university,
    required this.universityId,
  });
  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  String searchKey = "";
  String _yearFilter = 'All';
  final Map<String, int> _ratings = <String, int>{};
  BannerAd? _bannerAd;
  bool _adReady = false;
  late Future<List<Map<String, dynamic>>> _libraryFuture;

  // Thamani za mwaka zinazolingana na column ya 'year' (text) kwenye Supabase.
  static const _yearOptions = <String>['All', '1', '2', '3', '4'];
  static const _yearLabels = <String, String>{
    'All': 'All',
    '1': 'Year 1',
    '2': 'Year 2',
    '3': 'Year 3',
    '4': 'Year 4',
  };

  bool get _showAds =>
      widget.title == 'Notes' ||
      widget.title == 'Past Papers' ||
      widget.title == 'Research & Projects';
  bool get _isPastPapers => widget.title == 'Past Papers';
  bool get _isResearch => widget.title == 'Research & Projects';

  @override
  void initState() {
    super.initState();
    _libraryFuture = _fetchLibraryItems();
    if (_showAds && !kIsWeb) {
      _bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/6300978111',
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) setState(() => _adReady = true);
          },
          onAdFailedToLoad: (ad, _) {
            ad.dispose();
          },
        ),
      )..load();
    }
  }
@override
  void didUpdateWidget(covariant LibraryPage oldWidget) {
    super.didUpdateWidget(oldWidget); // Bano la function hii limefungwa vizuri
    
    if (oldWidget.collection != widget.collection || oldWidget.university != widget.university) {
      _reloadLibrary(); 
    } // Bano la if limefungwa
  } // Bano la kufunga function ya didUpdateWidget
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  bool get _usesInAppPdf =>
      widget.title == 'Notes' || widget.title == 'Past Papers';

  void _reloadLibrary() {
    setState(() {
      _libraryFuture = _fetchLibraryItems();
    });
  }

  /// Inavuta notes/papers kutoka Supabase kwa chuo na mwaka waliyochaguliwa.
  Future<List<Map<String, dynamic>>> _fetchLibraryItems() async {
    final selectedYear = _yearFilter;
    print(
      'Fetching ${widget.collection} for: '
      'Chuo=${widget.university}, '
      'ChuoId=${widget.universityId}, '
      'Mwaka=$selectedYear',
    );

    Future<List<Map<String, dynamic>>> queryByColumn(
      String column,
      dynamic value,
    ) async {
      var query = _supabase.from(widget.collection).select().eq(column, value);

      // Mwaka — 'year' ni text; puuza filter ikiwa "All".
      if (selectedYear != 'All') {
        query = query.eq('year', selectedYear.toString());
      }

      final rows = await query.order('name', ascending: true);
      return List<Map<String, dynamic>>.from(rows as List);
    }

    
      // 1) college (text) — jina la chuo lililochaguliwa na mtumiaji
      // Mstari wa 1200 (anza hapa)
// Mstari wa 1201 kwenye faili lako
final list = await queryByColumn('university_name', widget.university.toString());
    return list;
  }

  Future<void> _openDocumentUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final uri = Uri.tryParse(urlString);
    if (uri == null) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String? _fileUrlFromRow(Map<String, dynamic> data) {
    final raw = data['file_url'] ?? data['url'];
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _openLibraryDocument(
    Map<String, dynamic> data,
    String? url, {
    required String fallbackTitle,
  }) async {
    final fileUrl = url ?? _fileUrlFromRow(data);
    if (fileUrl == null) return;

    if (_usesInAppPdf) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PDFViewerPage(
            title: (data['name'] ?? data['title'] ?? fallbackTitle).toString(),
            fileUrl: fileUrl,
          ),
        ),
      );
      return;
    }

    await _openDocumentUrl(fileUrl);
  }

  Future<void> _handleNoteTap(Map<String, dynamic> data, String? url) async {
    final int price = (data['price'] is num) ? (data['price'] as num).toInt() : int.tryParse((data['price'] ?? '').toString()) ?? 0;
    final bool isVip = data['isFree'] == false || price > 0;

    if (AppConfig.isTrialMode) {
      await _openLibraryDocument(
        data,
        url,
        fallbackTitle: widget.title == 'Past Papers' ? 'Past Paper' : 'Note',
      );
      return;
    }

    if (_isPastPapers && isVip) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PastPaperPreviewScreen(
            title: (data['name'] ?? 'Past Paper').toString(),
            previewText:
                'Financial Management 2019-2025 bundle and other premium papers preview.',
            onPayAndDownload: () => PaymentInfoPage.open(context),
          ),
        ),
      );
      return;
    }

    if (_isResearch && isVip) {
      await PaymentInfoPage.open(context);
      return;
    }

    if (!isVip || price == 0) {
      await _openLibraryDocument(
        data,
        url,
        fallbackTitle: widget.title == 'Past Papers' ? 'Past Paper' : 'Note',
      );
      return;
    }

    if (!mounted) return;
    await PaymentInfoPage.open(context);
  }

  String _formatTzs(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return 'TZS ${buf.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const StudyBoltDrawer(),
      appBar: AppBar(
        title: Text('${widget.title} • ${widget.university}'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFD4AF37),
        
      ),
      body: Column(
        children: [
          if (_showAds)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              alignment: Alignment.center,
              child: _adReady && _bannerAd != null
                  ? SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    )
                  : Container(
                      height: 50,
                      width: 320,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0x66FFC107)),
                      ),
                      child: const Center(
                        child: Text(
                          'AdMob Placeholder Banner',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Year',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[800]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _yearFilter,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(14),
                      dropdownColor: const Color(0xFF1E1E1E),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.amber),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                      items: _yearOptions
                          .map(
                            (y) => DropdownMenuItem<String>(
                              value: y,
                              child: Text(_yearLabels[y] ?? y),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _yearFilter = v;
                          _reloadLibrary();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (v) => setState(() => searchKey = v.toLowerCase()),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  cursorColor: Colors.amber,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[900],
                    hintText: "Filter ${widget.title} by name...",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.amber, size: 22),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[800]!)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[800]!)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.amber, width: 1.5)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              key: ValueKey<String>(
                '${widget.collection}_${widget.university}_${widget.universityId}_$_yearFilter',
              ),
              future: _libraryFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Could not load items.\n${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[300]),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _reloadLibrary,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.amber));
                }
                final docs = (snapshot.data ?? []).where((row) {
                  final name = (row['name'] ?? '').toString().toLowerCase();
                  return name.contains(searchKey);
                }).toList();
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "No items match your search.",
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chuo: ${widget.university} • Mwaka: $_yearFilter',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i];
                    final docId = (data['id'] ?? 'row_$i').toString();
                    final name = (data['name'] ?? data['title'] ?? '').toString().isEmpty ? 'No Title' : (data['name'] ?? data['title'] ?? '').toString();
                    final year = (data['year'] ?? '').toString();
                    final url = _fileUrlFromRow(data);
                    final int price = (data['price'] is num) ? (data['price'] as num).toInt() : int.tryParse((data['price'] ?? '').toString()) ?? 0;
                    final isVip = data['isFree'] == false || price > 0;
                    final attempts = (data['attemptedCount'] is num)
                        ? (data['attemptedCount'] as num).toInt()
                        : int.tryParse((data['attemptedCount'] ?? '').toString()) ?? 0;
                    return ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(name, style: const TextStyle(color: Color.fromARGB(255, 167, 126, 5), fontWeight: FontWeight.bold)),
                          ),
                          if (isVip)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                price > 0 ? _formatTzs(price) : 'VIP',
                                style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (year.isNotEmpty)
                            Text(
                              year,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          if (_isResearch)
                            Text(
                              'Attempted by $attempts students • Standard TZS 5,000 • Classic TZS 10,000',
                              style: const TextStyle(color: Colors.white70),
                            )
                          else if (widget.title == 'Notes')
                            Row(
                              children: List.generate(5, (starIndex) {
                                final selected = (_ratings[docId] ?? 0) > starIndex;
                                return IconButton(
                                  onPressed: () {
                                    setState(() => _ratings[docId] = starIndex + 1);
                                  },
                                  icon: Icon(
                                    selected
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  tooltip: 'Rate ${starIndex + 1} stars',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                );
                              }),
                            ),
                        ],
                      ),
                      trailing: Icon(isVip ? Icons.lock_outline_rounded : Icons.open_in_new, color: Colors.white54),
                      onTap: () => _handleNoteTap(data, url),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PastPaperPreviewScreen extends StatelessWidget {
  final String title;
  final String previewText;
  final Future<void> Function() onPayAndDownload;
  const PastPaperPreviewScreen({
    super.key,
    required this.title,
    required this.previewText,
    required this.onPayAndDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Paper Preview'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              previewText,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPayAndDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Lipia & Tuma Uthibitisho WhatsApp',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TUTOR REGISTRATION ---
class TutorRegistrationScreen extends StatefulWidget {
  const TutorRegistrationScreen({super.key});
  @override
  State<TutorRegistrationScreen> createState() => _TutorRegistrationScreenState();
}

class _TutorRegistrationScreenState extends State<TutorRegistrationScreen> {
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<UniversityOption> _colleges = [];
  int? _selectedCollegeId;
  bool _loadingColleges = true;
  bool _submitting = false;
  String? _collegesError;

  @override
  void initState() {
    super.initState();
    _loadColleges();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadColleges() async {
    setState(() {
      _loadingColleges = true;
      _collegesError = null;
    });

    try {
      final rows = await _supabase
          .from('university')
          .select('id, name')
          .order('name', ascending: true);

      final seen = <int>{};
      final colleges = <UniversityOption>[];

      for (final row in rows as List) {
        final id = _parseRowId(row['id']);
        final name = (row['name'] ?? '').toString().trim();
        if (id == null || name.isEmpty || seen.contains(id)) continue;
        seen.add(id);
        colleges.add(UniversityOption(id: id, name: name));
      }

      if (!mounted) return;
      setState(() {
        _colleges = colleges;
        _loadingColleges = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingColleges = false;
        _collegesError = e.toString();
      });
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';

    final parts = _splitPhoneParts(value);
    if (parts.isEmpty) return 'Required';

    for (final part in parts) {
      if (!_isValidPhonePart(part)) {
        return 'Ingiza nambari sahihi kwa kila sehemu (/ inaruhusiwa)';
      }
    }
    return null;
  }

  String? _collegeValidator(int? value) {
    if (value == null) return 'Chagua chuo';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCollegeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chagua chuo kwanza.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await _supabase.from('tutors').insert({
        'name': _nameController.text.trim(),
        'subject': _subjectController.text.trim(),
        'phone': _formatPhoneForStorage(_phoneController.text.trim()),
        'college_id': _selectedCollegeId,
        'is_paid': false,
        'is_active': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usajili umefanikiwa!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usajili umeshindwa: $e'),
          backgroundColor: Colors.red[800],
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor Registration'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  validator: _required,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _subjectController,
                  validator: _required,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _phoneValidator,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp / Phone',
                    hintText: '0747840249/0747840249',
                  ),
                ),
                const SizedBox(height: 12),
                if (_loadingColleges)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    ),
                  )
                else if (_collegesError != null)
                  Column(
                    children: [
                      Text(
                        'Imeshindwa kupakia vyuo.',
                        style: TextStyle(color: Colors.red[300]),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _loadColleges,
                        child: const Text('Jaribu tena'),
                      ),
                    ],
                  )
                else
                  DropdownButtonFormField<int>(
                    initialValue: _selectedCollegeId,
                    decoration: const InputDecoration(labelText: 'Chuo'),
                    items: _colleges
                        .map(
                          (college) => DropdownMenuItem<int>(
                            value: college.id,
                            child: Text(college.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCollegeId = value);
                    },
                    validator: (_) => _collegeValidator(_selectedCollegeId),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_loadingColleges || _submitting) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'SUBMIT',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
