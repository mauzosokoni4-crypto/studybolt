/// Global app configuration — edit values here for trial mode and payment details.
class AppConfig {
  AppConfig._();

  /// When `true`, all users access the dashboard and premium content without
  /// payment checks (free trial week). Set to `false` when trial ends.
  static const bool isTrialMode = true;

  static const String supportWhatsApp = '255747840249';
  static const String supportPhoneDisplay = '+255 747 840 249';

  static const String mpesaBusinessName = 'STUDYBOLT';
  static const String mpesaNumber = '0747840249';
  static const String mpesaAccountType = 'M-Pesa Lipa Namba / Send Money';

  static const String bankName = 'CRDB Bank';
  static const String bankAccountName = 'StudyBolt';
  static const String bankAccountNumber = '0150000000000';
  static const String bankBranch = 'Dar es Salaam';

  static const String subscriptionAmountTzs = '5,000';
}
