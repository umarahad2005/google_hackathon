// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'ذمہ AI';

  @override
  String get requestScreenTitle => 'آپ کو کیا سروس چاہیے؟';

  @override
  String get requestHint => 'اپنی ضرورت بیان کریں...';

  @override
  String get requestExampleUrdu => 'مجھے کل صبح G-13 میں AC ٹیکنیشن چاہیے';

  @override
  String get requestExampleRomanUrdu =>
      'Mujhe kal subah G-13 mein AC technician chahiye';

  @override
  String get requestExampleEnglish =>
      'I need a plumber in F-8 tomorrow morning';

  @override
  String get send => 'بھیجیں';

  @override
  String get traceTitle => 'AI سوچ رہا ہے...';

  @override
  String get traceComplete => 'تجزیہ مکمل';

  @override
  String get recommendationTitle => 'آپ کے لیے تجویز';

  @override
  String get whyThisOne => 'یہ کیوں؟';

  @override
  String get bookNow => 'ابھی بک کریں';

  @override
  String get bookingConfirmed => 'بکنگ کنفرم!';

  @override
  String get viewReceipt => 'رسید دیکھیں';

  @override
  String get followUpTitle => 'سروس کی صورتحال';

  @override
  String get statusReminder => 'یاد دہانی';

  @override
  String get statusEnRoute => 'فراہم کنندہ آ رہے ہیں';

  @override
  String get statusInProgress => 'کام جاری ہے';

  @override
  String get statusCompleted => 'سروس مکمل';

  @override
  String get rateService => 'سروس کی درجہ بندی کریں';
}
