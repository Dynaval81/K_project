// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get login_title => 'Вход';

  @override
  String get login_subtitle => 'Войдите в свой аккаунт';

  @override
  String get login_method_email => 'Email';

  @override
  String get login_method_vtalk_id => 'V-Talk ID';

  @override
  String get login_method_nickname => 'Никнейм';

  @override
  String get login_label => 'Логин';

  @override
  String get login_hint_email => 'Введите email';

  @override
  String get login_hint_vtalk_id => 'Введите V-Talk ID';

  @override
  String get login_hint_nickname => 'Введите никнейм';

  @override
  String get login_primary_button => 'Поехали';

  @override
  String get login_divider_or => 'или';

  @override
  String get login_google => 'Войти через Google';

  @override
  String get login_apple => 'Войти через Apple';

  @override
  String get login_no_account => 'Нет аккаунта? ';

  @override
  String get login_register => 'Зарегистрироваться';

  @override
  String get login_password_label => 'Пароль';

  @override
  String get login_password_hint => 'Введите пароль';

  @override
  String get login_button_submit => 'Войти';

  @override
  String get login_forgot_password => 'Забыли пароль?';

  @override
  String get login_change_identifier => 'изменить';

  @override
  String get login_error_empty => 'Введите email, VT-ID или никнейм';

  @override
  String get login_error_empty_password => 'Введите пароль';

  @override
  String get login_error_network => 'Ошибка сети';

  @override
  String get register_title => 'Регистрация';

  @override
  String get register_subtitle => 'Создайте аккаунт';

  @override
  String get register_email_label => 'Email';

  @override
  String get register_email_hint => 'Введите email';

  @override
  String get register_password_label => 'Пароль';

  @override
  String get register_password_hint => 'Минимум 6 символов';

  @override
  String get register_nickname_label => 'Никнейм (необязательно)';

  @override
  String get register_nickname_hint => 'Введите никнейм';

  @override
  String get register_button => 'Создать аккаунт';

  @override
  String get register_have_account => 'Уже есть аккаунт? ';

  @override
  String get register_login => 'Войти';

  @override
  String get dashboard_title => 'Настройки';

  @override
  String get dashboard_elements_store => 'Элементы';

  @override
  String get dashboard_tab_chats => 'Чаты';

  @override
  String get dashboard_tab_ai => 'Ассистент';

  @override
  String get dashboard_tab_vpn => 'VPN';

  @override
  String get dashboard_app_info => 'О приложении';

  @override
  String get dashboard_version_details => 'Детали версии';

  @override
  String get dashboard_donations => 'Поддержка';

  @override
  String get dashboard_report => 'Сообщить об ошибке';

  @override
  String get dashboard_report_hint => 'Опиши что пошло не так — мы разберёмся.';

  @override
  String get dashboard_report_placeholder =>
      'Например: при нажатии на кнопку VPN приложение зависает...';

  @override
  String get dashboard_report_send => 'Отправить';

  @override
  String get dashboard_report_sent => 'Отправлено! Спасибо.';

  @override
  String get dashboard_settings => 'Настройки';

  @override
  String get dashboard_logout => 'Выйти';

  @override
  String get vpn_title => 'VPN';

  @override
  String get vpn_connected => 'Подключено';

  @override
  String get vpn_disconnected => 'Отключено';

  @override
  String get vpn_connecting => 'Подключение...';

  @override
  String get vpn_select_server => 'Выбрать сервер';

  @override
  String get vpn_split_tunneling => 'Раздельное туннелирование';

  @override
  String get vpn_split_apps => 'Приложения';

  @override
  String get vpn_split_sites => 'Сайты';

  @override
  String get vpn_traffic_in => 'Входящий';

  @override
  String get vpn_traffic_out => 'Исходящий';

  @override
  String get vpn_access_title => 'Требуется доступ';

  @override
  String get vpn_access_subtitle => 'Введите код активации VPN';

  @override
  String get vpn_access_hint => 'Код активации';

  @override
  String get vpn_access_button => 'Активировать';

  @override
  String get settings_title => 'Настройки';

  @override
  String get settings_theme => 'Тема';

  @override
  String get settings_theme_light => 'Светлая';

  @override
  String get settings_theme_dark => 'Тёмная';

  @override
  String get settings_language => 'Язык';

  @override
  String get settings_account => 'Аккаунт';

  @override
  String get settings_premium => 'Подписка';

  @override
  String get settings_activate_code => 'Введите код активации';

  @override
  String get settings_activate_button => 'Активировать';

  @override
  String get coming_soon => 'Скоро';

  @override
  String get coming_soon_ai => 'ИИ-ассистент в разработке';

  @override
  String get coming_soon_chats => 'Чаты скоро будут доступны';

  @override
  String get error_network => 'Ошибка сети';

  @override
  String get error_unknown => 'Неизвестная ошибка';

  @override
  String get button_ok => 'Понятно';

  @override
  String get button_cancel => 'Отмена';

  @override
  String get button_save => 'Сохранить';

  @override
  String get button_close => 'Закрыть';

  @override
  String get dashboard_donations_text =>
      'Поддержи проект — донаты помогают V-Talk оставаться бесплатным.';

  @override
  String get tab_chats => 'Чаты';

  @override
  String get tab_ai => 'Ассистент';

  @override
  String get tab_vpn => 'VPN';

  @override
  String get tab_dashboard => 'Настройки';

  @override
  String get settings_notifications => 'Уведомления';

  @override
  String get settings_logout => 'Выйти';

  @override
  String get settings_version => 'Версия';
}
