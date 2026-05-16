// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Zimma AI';

  @override
  String get requestScreenTitle => 'What service do you need?';

  @override
  String get requestHint => 'Describe what you need...';

  @override
  String get requestExampleUrdu => 'مجھے کل صبح G-13 میں AC ٹیکنیشن چاہیے';

  @override
  String get requestExampleRomanUrdu =>
      'Mujhe kal subah G-13 mein AC technician chahiye';

  @override
  String get requestExampleEnglish =>
      'I need a plumber in F-8 tomorrow morning';

  @override
  String get send => 'Send';

  @override
  String get traceTitle => 'AI is thinking...';

  @override
  String get traceComplete => 'Analysis Complete';

  @override
  String get recommendationTitle => 'Recommended for you';

  @override
  String get whyThisOne => 'Why this provider?';

  @override
  String get bookNow => 'Book Now';

  @override
  String get bookingConfirmed => 'Booking Confirmed!';

  @override
  String get viewReceipt => 'View Receipt';

  @override
  String get followUpTitle => 'Service Status';

  @override
  String get statusReminder => 'Reminder';

  @override
  String get statusEnRoute => 'Provider on the way';

  @override
  String get statusInProgress => 'Work in progress';

  @override
  String get statusCompleted => 'Service completed';

  @override
  String get rateService => 'Rate this service';
}
