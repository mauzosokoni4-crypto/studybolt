import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String?> savePdfFromUrl(String url) async {
  try {
    // Badilisha Google Drive view URL → direct download URL
    final directUrl = _toDirectDownloadUrl(url);
    
    final response = await http.get(
      Uri.parse(directUrl),
      headers: {'User-Agent': 'Mozilla/5.0'},
    );
    
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }
    
    // Hakikisha ni PDF, si HTML ya Google
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('text/html')) return null;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/studybolt_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  } catch (e) {
    return null;
  }
}

String _toDirectDownloadUrl(String url) {
  // https://drive.google.com/file/d/FILE_ID/view → direct download
  final viewMatch = RegExp(
    r'drive\.google\.com/file/d/([^/]+)',
  ).firstMatch(url);
  
  if (viewMatch != null) {
    final fileId = viewMatch.group(1)!;
    return 'https://drive.google.com/uc?export=download&id=$fileId';
  }
  
  return url; // URL nyingine (Supabase, etc.) zirudi kama zilivyo
}