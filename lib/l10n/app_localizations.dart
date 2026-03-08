import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @splashTagline.
  ///
  /// In de, this message translates to:
  /// **'Verbinde deine Schulwelt'**
  String get splashTagline;

  /// No description provided for @loginTitle.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Melde dich bei deinem Konto an'**
  String get loginSubtitle;

  /// No description provided for @loginMethodEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get loginMethodEmail;

  /// No description provided for @loginHintEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail eingeben'**
  String get loginHintEmail;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In de, this message translates to:
  /// **'Passwort eingeben'**
  String get loginPasswordHint;

  /// No description provided for @loginEnterPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort eingeben'**
  String get loginEnterPassword;

  /// No description provided for @loginButtonLogin.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get loginButtonLogin;

  /// No description provided for @loginForgotPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get loginForgotPassword;

  /// No description provided for @loginDividerOr.
  ///
  /// In de, this message translates to:
  /// **'oder'**
  String get loginDividerOr;

  /// No description provided for @loginGoogle.
  ///
  /// In de, this message translates to:
  /// **'Mit Google anmelden'**
  String get loginGoogle;

  /// No description provided for @loginApple.
  ///
  /// In de, this message translates to:
  /// **'Mit Apple anmelden'**
  String get loginApple;

  /// No description provided for @loginGoogleSoon.
  ///
  /// In de, this message translates to:
  /// **'Google Sign-In — demnächst verfügbar'**
  String get loginGoogleSoon;

  /// No description provided for @loginAppleSoon.
  ///
  /// In de, this message translates to:
  /// **'Apple Sign-In — demnächst verfügbar'**
  String get loginAppleSoon;

  /// No description provided for @loginNoAccount.
  ///
  /// In de, this message translates to:
  /// **'Kein Konto? '**
  String get loginNoAccount;

  /// No description provided for @loginRegister.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get loginRegister;

  /// No description provided for @loginErrorEmpty.
  ///
  /// In de, this message translates to:
  /// **'E-Mail oder Nutzername eingeben'**
  String get loginErrorEmpty;

  /// No description provided for @loginErrorEmptyPassword.
  ///
  /// In de, this message translates to:
  /// **'Bitte Passwort eingeben'**
  String get loginErrorEmptyPassword;

  /// No description provided for @loginErrorNetwork.
  ///
  /// In de, this message translates to:
  /// **'Netzwerkfehler. Bitte erneut versuchen.'**
  String get loginErrorNetwork;

  /// No description provided for @loginErrorEmailVerification.
  ///
  /// In de, this message translates to:
  /// **'Bitte bestätige deine E-Mail vor dem Login'**
  String get loginErrorEmailVerification;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In de, this message translates to:
  /// **'Anmeldefehler. Bitte erneut versuchen.'**
  String get loginErrorGeneric;

  /// No description provided for @registerTitle.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get registerSubtitle;

  /// No description provided for @registerEmailLabel.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get registerEmailLabel;

  /// No description provided for @registerEmailHint.
  ///
  /// In de, this message translates to:
  /// **'E-Mail eingeben'**
  String get registerEmailHint;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordHint.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 6 Zeichen'**
  String get registerPasswordHint;

  /// No description provided for @registerNicknameLabel.
  ///
  /// In de, this message translates to:
  /// **'Spitzname (optional)'**
  String get registerNicknameLabel;

  /// No description provided for @registerNicknameHint.
  ///
  /// In de, this message translates to:
  /// **'Spitznamen eingeben'**
  String get registerNicknameHint;

  /// No description provided for @registerButton.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In de, this message translates to:
  /// **'Bereits ein Konto? '**
  String get registerHaveAccount;

  /// No description provided for @registerLogin.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get registerLogin;

  /// No description provided for @dashboardTitle.
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get dashboardSettings;

  /// No description provided for @dashboardLogout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get dashboardLogout;

  /// No description provided for @dashboardReport.
  ///
  /// In de, this message translates to:
  /// **'Fehler melden'**
  String get dashboardReport;

  /// No description provided for @dashboardReportHint.
  ///
  /// In de, this message translates to:
  /// **'Beschreibe was nicht funktioniert — wir kümmern uns darum.'**
  String get dashboardReportHint;

  /// No description provided for @dashboardAppInfo.
  ///
  /// In de, this message translates to:
  /// **'App-Info'**
  String get dashboardAppInfo;

  /// No description provided for @dashboardVersionDetails.
  ///
  /// In de, this message translates to:
  /// **'Versionsdetails'**
  String get dashboardVersionDetails;

  /// No description provided for @tabChats.
  ///
  /// In de, this message translates to:
  /// **'Chats'**
  String get tabChats;

  /// No description provided for @tabAi.
  ///
  /// In de, this message translates to:
  /// **'KI-Assistent'**
  String get tabAi;

  /// No description provided for @tabSchedule.
  ///
  /// In de, this message translates to:
  /// **'Stundenplan'**
  String get tabSchedule;

  /// No description provided for @tabDashboard.
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In de, this message translates to:
  /// **'Design'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get settingsLanguage;

  /// No description provided for @settingsAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto'**
  String get settingsAccount;

  /// No description provided for @settingsNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get settingsNotifications;

  /// No description provided for @settingsLogout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get settingsLogout;

  /// No description provided for @settingsVersion.
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @scheduleTitle.
  ///
  /// In de, this message translates to:
  /// **'Stundenplan'**
  String get scheduleTitle;

  /// No description provided for @scheduleComingSoon.
  ///
  /// In de, this message translates to:
  /// **'Dein Stundenplan wird bald verfügbar sein.'**
  String get scheduleComingSoon;

  /// No description provided for @pendingTitle.
  ///
  /// In de, this message translates to:
  /// **'Konto wird geprüft'**
  String get pendingTitle;

  /// No description provided for @pendingMessage.
  ///
  /// In de, this message translates to:
  /// **'Deine Anfrage wird vom Schuladministrator geprüft.'**
  String get pendingMessage;

  /// No description provided for @pendingAvailable.
  ///
  /// In de, this message translates to:
  /// **'Du kannst bereits mit Freunden chatten!'**
  String get pendingAvailable;

  /// No description provided for @comingSoon.
  ///
  /// In de, this message translates to:
  /// **'Demnächst verfügbar'**
  String get comingSoon;

  /// No description provided for @comingSoonAi.
  ///
  /// In de, this message translates to:
  /// **'KI-Assistent wird entwickelt'**
  String get comingSoonAi;

  /// No description provided for @comingSoonChats.
  ///
  /// In de, this message translates to:
  /// **'Chats kommen bald'**
  String get comingSoonChats;

  /// No description provided for @errorNetwork.
  ///
  /// In de, this message translates to:
  /// **'Netzwerkfehler'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In de, this message translates to:
  /// **'Unbekannter Fehler'**
  String get errorUnknown;

  /// No description provided for @buttonOk.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// No description provided for @buttonCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get buttonCancel;

  /// No description provided for @buttonSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get buttonSave;

  /// No description provided for @buttonClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get buttonClose;

  /// No description provided for @sandboxLimitChats.
  ///
  /// In de, this message translates to:
  /// **'Nach Schulverifizierung verfügbar'**
  String get sandboxLimitChats;

  /// No description provided for @sandboxLimitSchedule.
  ///
  /// In de, this message translates to:
  /// **'Nach Schulverifizierung verfügbar'**
  String get sandboxLimitSchedule;

  /// No description provided for @sandboxLimitPasswordVault.
  ///
  /// In de, this message translates to:
  /// **'Nach Elternverknüpfung verfügbar'**
  String get sandboxLimitPasswordVault;

  /// No description provided for @sandboxDailyLimitReached.
  ///
  /// In de, this message translates to:
  /// **'Tageslimit erreicht. Bis morgen!'**
  String get sandboxDailyLimitReached;

  /// No description provided for @curfewTitle.
  ///
  /// In de, this message translates to:
  /// **'Gute Nacht!'**
  String get curfewTitle;

  /// No description provided for @curfewMessage.
  ///
  /// In de, this message translates to:
  /// **'Die App ist bis morgen früh gesperrt.'**
  String get curfewMessage;

  /// No description provided for @loginPrimaryButton.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get loginPrimaryButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
