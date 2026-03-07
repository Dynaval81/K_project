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

  /// No description provided for @login_title.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get login_title;

  /// No description provided for @login_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в свой аккаунт'**
  String get login_subtitle;

  /// No description provided for @login_method_email.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get login_method_email;

  /// No description provided for @login_method_vtalk_id.
  ///
  /// In ru, this message translates to:
  /// **'V-Talk ID'**
  String get login_method_vtalk_id;

  /// No description provided for @login_method_nickname.
  ///
  /// In ru, this message translates to:
  /// **'Никнейм'**
  String get login_method_nickname;

  /// No description provided for @login_label.
  ///
  /// In ru, this message translates to:
  /// **'Логин'**
  String get login_label;

  /// No description provided for @login_hint_email.
  ///
  /// In ru, this message translates to:
  /// **'Введите email'**
  String get login_hint_email;

  /// No description provided for @login_hint_vtalk_id.
  ///
  /// In ru, this message translates to:
  /// **'Введите V-Talk ID'**
  String get login_hint_vtalk_id;

  /// No description provided for @login_hint_nickname.
  ///
  /// In ru, this message translates to:
  /// **'Введите никнейм'**
  String get login_hint_nickname;

  /// No description provided for @login_primary_button.
  ///
  /// In ru, this message translates to:
  /// **'Поехали'**
  String get login_primary_button;

  /// No description provided for @login_divider_or.
  ///
  /// In ru, this message translates to:
  /// **'или'**
  String get login_divider_or;

  /// No description provided for @login_google.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Google'**
  String get login_google;

  /// No description provided for @login_apple.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Apple'**
  String get login_apple;

  /// No description provided for @login_no_account.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? '**
  String get login_no_account;

  /// No description provided for @login_register.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get login_register;

  /// No description provided for @login_password_label.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get login_password_label;

  /// No description provided for @login_password_hint.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get login_password_hint;

  /// No description provided for @login_button_submit.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get login_button_submit;

  /// No description provided for @login_forgot_password.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get login_forgot_password;

  /// No description provided for @login_change_identifier.
  ///
  /// In ru, this message translates to:
  /// **'изменить'**
  String get login_change_identifier;

  /// No description provided for @login_error_empty.
  ///
  /// In ru, this message translates to:
  /// **'Введите email, VT-ID или никнейм'**
  String get login_error_empty;

  /// No description provided for @login_error_empty_password.
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get login_error_empty_password;

  /// No description provided for @login_error_network.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сети'**
  String get login_error_network;

  /// No description provided for @register_title.
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get register_title;

  /// No description provided for @register_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создайте аккаунт'**
  String get register_subtitle;

  /// No description provided for @register_email_label.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get register_email_label;

  /// No description provided for @register_email_hint.
  ///
  /// In ru, this message translates to:
  /// **'Введите email'**
  String get register_email_hint;

  /// No description provided for @register_password_label.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get register_password_label;

  /// No description provided for @register_password_hint.
  ///
  /// In ru, this message translates to:
  /// **'Минимум 6 символов'**
  String get register_password_hint;

  /// No description provided for @register_nickname_label.
  ///
  /// In ru, this message translates to:
  /// **'Никнейм (необязательно)'**
  String get register_nickname_label;

  /// No description provided for @register_nickname_hint.
  ///
  /// In ru, this message translates to:
  /// **'Введите никнейм'**
  String get register_nickname_hint;

  /// No description provided for @register_button.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get register_button;

  /// No description provided for @register_have_account.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? '**
  String get register_have_account;

  /// No description provided for @register_login.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get register_login;

  /// No description provided for @dashboard_title.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get dashboard_title;

  /// No description provided for @dashboard_elements_store.
  ///
  /// In ru, this message translates to:
  /// **'Элементы'**
  String get dashboard_elements_store;

  /// No description provided for @dashboard_tab_chats.
  ///
  /// In ru, this message translates to:
  /// **'Чаты'**
  String get dashboard_tab_chats;

  /// No description provided for @dashboard_tab_ai.
  ///
  /// In ru, this message translates to:
  /// **'Ассистент'**
  String get dashboard_tab_ai;

  /// No description provided for @dashboard_tab_vpn.
  ///
  /// In ru, this message translates to:
  /// **'VPN'**
  String get dashboard_tab_vpn;

  /// No description provided for @dashboard_app_info.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get dashboard_app_info;

  /// No description provided for @dashboard_version_details.
  ///
  /// In ru, this message translates to:
  /// **'Детали версии'**
  String get dashboard_version_details;

  /// No description provided for @dashboard_donations.
  ///
  /// In ru, this message translates to:
  /// **'Поддержка'**
  String get dashboard_donations;

  /// No description provided for @dashboard_report.
  ///
  /// In ru, this message translates to:
  /// **'Сообщить об ошибке'**
  String get dashboard_report;

  /// No description provided for @dashboard_report_hint.
  ///
  /// In ru, this message translates to:
  /// **'Опиши что пошло не так — мы разберёмся.'**
  String get dashboard_report_hint;

  /// No description provided for @dashboard_report_placeholder.
  ///
  /// In ru, this message translates to:
  /// **'Например: при нажатии на кнопку VPN приложение зависает...'**
  String get dashboard_report_placeholder;

  /// No description provided for @dashboard_report_send.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get dashboard_report_send;

  /// No description provided for @dashboard_report_sent.
  ///
  /// In ru, this message translates to:
  /// **'Отправлено! Спасибо.'**
  String get dashboard_report_sent;

  /// No description provided for @dashboard_settings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get dashboard_settings;

  /// No description provided for @dashboard_logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get dashboard_logout;

  /// No description provided for @vpn_title.
  ///
  /// In ru, this message translates to:
  /// **'VPN'**
  String get vpn_title;

  /// No description provided for @vpn_connected.
  ///
  /// In ru, this message translates to:
  /// **'Подключено'**
  String get vpn_connected;

  /// No description provided for @vpn_disconnected.
  ///
  /// In ru, this message translates to:
  /// **'Отключено'**
  String get vpn_disconnected;

  /// No description provided for @vpn_connecting.
  ///
  /// In ru, this message translates to:
  /// **'Подключение...'**
  String get vpn_connecting;

  /// No description provided for @vpn_select_server.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать сервер'**
  String get vpn_select_server;

  /// No description provided for @vpn_split_tunneling.
  ///
  /// In ru, this message translates to:
  /// **'Раздельное туннелирование'**
  String get vpn_split_tunneling;

  /// No description provided for @vpn_split_apps.
  ///
  /// In ru, this message translates to:
  /// **'Приложения'**
  String get vpn_split_apps;

  /// No description provided for @vpn_split_sites.
  ///
  /// In ru, this message translates to:
  /// **'Сайты'**
  String get vpn_split_sites;

  /// No description provided for @vpn_traffic_in.
  ///
  /// In ru, this message translates to:
  /// **'Входящий'**
  String get vpn_traffic_in;

  /// No description provided for @vpn_traffic_out.
  ///
  /// In ru, this message translates to:
  /// **'Исходящий'**
  String get vpn_traffic_out;

  /// No description provided for @vpn_access_title.
  ///
  /// In ru, this message translates to:
  /// **'Требуется доступ'**
  String get vpn_access_title;

  /// No description provided for @vpn_access_subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите код активации VPN'**
  String get vpn_access_subtitle;

  /// No description provided for @vpn_access_hint.
  ///
  /// In ru, this message translates to:
  /// **'Код активации'**
  String get vpn_access_hint;

  /// No description provided for @vpn_access_button.
  ///
  /// In ru, this message translates to:
  /// **'Активировать'**
  String get vpn_access_button;

  /// No description provided for @settings_title.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings_title;

  /// No description provided for @settings_theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get settings_theme;

  /// No description provided for @settings_theme_light.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get settings_theme_dark;

  /// No description provided for @settings_language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settings_language;

  /// No description provided for @settings_account.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get settings_account;

  /// No description provided for @settings_premium.
  ///
  /// In ru, this message translates to:
  /// **'Подписка'**
  String get settings_premium;

  /// No description provided for @settings_activate_code.
  ///
  /// In ru, this message translates to:
  /// **'Введите код активации'**
  String get settings_activate_code;

  /// No description provided for @settings_activate_button.
  ///
  /// In ru, this message translates to:
  /// **'Активировать'**
  String get settings_activate_button;

  /// No description provided for @coming_soon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро'**
  String get coming_soon;

  /// No description provided for @coming_soon_ai.
  ///
  /// In ru, this message translates to:
  /// **'ИИ-ассистент в разработке'**
  String get coming_soon_ai;

  /// No description provided for @coming_soon_chats.
  ///
  /// In ru, this message translates to:
  /// **'Чаты скоро будут доступны'**
  String get coming_soon_chats;

  /// No description provided for @error_network.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сети'**
  String get error_network;

  /// No description provided for @error_unknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестная ошибка'**
  String get error_unknown;

  /// No description provided for @button_ok.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get button_ok;

  /// No description provided for @button_cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get button_cancel;

  /// No description provided for @button_save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get button_save;

  /// No description provided for @button_close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get button_close;

  /// No description provided for @dashboard_donations_text.
  ///
  /// In ru, this message translates to:
  /// **'Поддержи проект — донаты помогают V-Talk оставаться бесплатным.'**
  String get dashboard_donations_text;

  /// No description provided for @tab_chats.
  ///
  /// In ru, this message translates to:
  /// **'Чаты'**
  String get tab_chats;

  /// No description provided for @tab_ai.
  ///
  /// In ru, this message translates to:
  /// **'Ассистент'**
  String get tab_ai;

  /// No description provided for @tab_vpn.
  ///
  /// In ru, this message translates to:
  /// **'VPN'**
  String get tab_vpn;

  /// No description provided for @tab_dashboard.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get tab_dashboard;

  /// No description provided for @settings_notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get settings_notifications;

  /// No description provided for @settings_logout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get settings_logout;

  /// No description provided for @settings_version.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get settings_version;
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
