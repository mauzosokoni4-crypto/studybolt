import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_config.dart';

/// Manual payment instructions — replaces automated gateway checkout.
class PaymentInfoPage extends StatelessWidget {
  const PaymentInfoPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const PaymentInfoPage()),
    );
  }

  Future<void> _contactWhatsApp() async {
    final uri = Uri.parse('https://wa.me/${AppConfig.supportWhatsApp}');
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Malipo / Payment'),
        backgroundColor: const Color(0xFF121212),
        foregroundColor: const Color(0xFFD4AF37),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.payment_rounded, size: 56, color: Color(0xFFD4AF37)),
            const SizedBox(height: 12),
            Text(
              'Lipia TZS ${AppConfig.subscriptionAmountTzs}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Fanya malipo kupitia M-Pesa au benki, kisha tuma picha ya uthibitisho (screenshot) kwenye WhatsApp yetu ili kufunguliwa akaunti yako.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, height: 1.45),
            ),
            const SizedBox(height: 28),
            _PaymentCard(
              title: 'M-Pesa',
              icon: Icons.phone_android_rounded,
              rows: [
                _DetailRow('Jina', AppConfig.mpesaBusinessName),
                _DetailRow('Nambari', AppConfig.mpesaNumber),
                _DetailRow('Aina', AppConfig.mpesaAccountType),
              ],
            ),
            const SizedBox(height: 16),
            _PaymentCard(
              title: 'Benki / Bank',
              icon: Icons.account_balance_rounded,
              rows: [
                _DetailRow('Benki', AppConfig.bankName),
                _DetailRow('Jina la akaunti', AppConfig.bankAccountName),
                _DetailRow('Nambari ya akaunti', AppConfig.bankAccountNumber),
                _DetailRow('Tawi', AppConfig.bankBranch),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x66FFC107)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hatua za kufuata:',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text('1. Lipa kiasi kilichoonyeshwa hapo juu.', style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 6),
                  Text(
                    '2. Piga screenshot ya uthibitisho wa malipo.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '3. Bonyeza kitufe cha WhatsApp hapa chini na tuma screenshot pamoja na jina lako na chuo chako.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _contactWhatsApp,
              icon: const Icon(Icons.chat_rounded),
              label: const Text('Wasiliana kupitia WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppConfig.supportPhoneDisplay,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFFD4AF37)),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.white54)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
