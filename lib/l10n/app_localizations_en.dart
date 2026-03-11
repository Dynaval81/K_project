// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get splashTagline => 'Connect your school world';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginSubtitle => 'Sign in to your account';

  @override
  String get loginMethodEmail => 'Email';

  @override
  String get loginHintEmail => 'Enter email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Enter password';

  @override
  String get loginEnterPassword => 'Enter password';

  @override
  String get loginButtonLogin => 'Sign In';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginDividerOr => 'or';

  @override
  String get loginGoogle => 'Sign in with Google';

  @override
  String get loginApple => 'Sign in with Apple';

  @override
  String get loginGoogleSoon => 'Google Sign-In — coming soon';

  @override
  String get loginAppleSoon => 'Apple Sign-In — coming soon';

  @override
  String get loginNoAccount => 'No account? ';

  @override
  String get loginRegister => 'Register';

  @override
  String get loginErrorEmpty => 'Enter email or username';

  @override
  String get loginErrorEmptyPassword => 'Please enter password';

  @override
  String get loginErrorNetwork => 'Network error. Please try again.';

  @override
  String get loginErrorEmailVerification =>
      'Please verify your email before signing in';

  @override
  String get loginErrorGeneric => 'Sign in error. Please try again.';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerSubtitle => 'Create account';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailHint => 'Enter email';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordHint => 'At least 6 characters';

  @override
  String get registerNicknameLabel => 'Nickname (optional)';

  @override
  String get registerNicknameHint => 'Enter nickname';

  @override
  String get registerButton => 'Create account';

  @override
  String get registerHaveAccount => 'Already have an account? ';

  @override
  String get registerLogin => 'Sign In';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardSettings => 'Settings';

  @override
  String get dashboardLogout => 'Sign Out';

  @override
  String get dashboardReport => 'Report a bug';

  @override
  String get dashboardReportHint =>
      'Describe what\'s not working — we\'ll take care of it.';

  @override
  String get dashboardAppInfo => 'App Info';

  @override
  String get dashboardVersionDetails => 'Version details';

  @override
  String get tabChats => 'Chats';

  @override
  String get tabAi => 'AI Assistant';

  @override
  String get tabSchedule => 'Schedule';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsLogout => 'Sign Out';

  @override
  String get settingsVersion => 'Version';

  @override
  String get scheduleTitle => 'Schedule';

  @override
  String get scheduleComingSoon => 'Your schedule will be available soon.';

  @override
  String get pendingTitle => 'Account under review';

  @override
  String get pendingMessage =>
      'Your request is being reviewed by the school administrator.';

  @override
  String get pendingAvailable => 'You can already chat with friends!';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonAi => 'AI Assistant is in development';

  @override
  String get comingSoonChats => 'Chats coming soon';

  @override
  String get errorNetwork => 'Network error';

  @override
  String get errorUnknown => 'Unknown error';

  @override
  String get buttonOk => 'OK';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonClose => 'Close';

  @override
  String get sandboxLimitChats => 'Available after school verification';

  @override
  String get sandboxLimitSchedule => 'Available after school verification';

  @override
  String get sandboxLimitPasswordVault => 'Available after parent linking';

  @override
  String get sandboxDailyLimitReached =>
      'Daily limit reached. See you tomorrow!';

  @override
  String get curfewTitle => 'Good night!';

  @override
  String get curfewMessage => 'The app is locked until tomorrow morning.';

  @override
  String get schoolTitle => 'School';

  @override
  String get schoolNotVerifiedTitle => 'School not confirmed yet';

  @override
  String get schoolNotVerifiedSubtitle =>
      'Enter your school code or wait for confirmation from your school.';

  @override
  String get schoolCodeHint => 'SCH-XXXX';

  @override
  String get schoolCodeRedeem => 'Redeem Code';

  @override
  String get schoolCodeInvalid => 'Invalid code. Please check and try again.';

  @override
  String get schoolCodeEmpty => 'Please enter school code';

  @override
  String get schoolWaitingConfirmation => 'Waiting for school confirmation';

  @override
  String schoolWaitingFrom(String school) {
    return 'Waiting for confirmation from\n$school';
  }

  @override
  String get schoolServicesTitle => 'Services';

  @override
  String get schoolTimetable => 'Timetable';

  @override
  String get schoolAnnouncements => 'Announcements';

  @override
  String get schoolDocuments => 'Documents';

  @override
  String get schoolHomework => 'Homework';

  @override
  String get schoolGrades => 'Grades';

  @override
  String get schoolEvents => 'Events';

  @override
  String get schoolUpcomingTitle => 'Upcoming Events';

  @override
  String get schoolStatClass => 'Class';

  @override
  String get schoolStatStatus => 'Status';

  @override
  String get schoolStatNew => 'New';

  @override
  String get schoolStatActive => 'Active';

  @override
  String get schoolVerifiedBadge => 'Verified';

  @override
  String schoolComingSoon(String name) {
    return '$name — coming soon';
  }

  @override
  String get settingsTabsTitle => 'Visible Tabs';

  @override
  String get settingsTabChats => 'Chats';

  @override
  String get settingsTabAi => 'AI Assistant';

  @override
  String get settingsTabSchool => 'School';

  @override
  String get settingsTabKind => 'Child';

  @override
  String get lockedDefaultTitle => 'Locked';

  @override
  String get lockedDefaultSubtitle => 'Waiting for administrator approval.';

  @override
  String get lockedSchoolChatsTitle => 'School Chats Locked';

  @override
  String get lockedSchoolChatsSubtitle =>
      'Waiting for approval from your school administrator.';

  @override
  String get lockedNoChildTitle => 'No child linked';

  @override
  String get lockedNoChildSubtitle =>
      'Link your account with your child\'s KN code in settings.';

  @override
  String get lockedTeacherTitle => 'Access Restricted';

  @override
  String get lockedTeacherSubtitle =>
      'Waiting for verification by your school administrator.';

  @override
  String get verwaltungTitle => 'Administration';

  @override
  String get verwaltungActivateUsers => 'Activate Users';

  @override
  String get verwaltungActivateUsersSubtitle =>
      'Approve students, teachers and parents';

  @override
  String get verwaltungGenerateCodes => 'Generate School Codes';

  @override
  String get verwaltungGenerateCodesSubtitle =>
      'SCH-XXXX codes for registration';

  @override
  String get verwaltungUserList => 'User List';

  @override
  String get verwaltungUserListSubtitle => 'Manage all school members';

  @override
  String get verwaltungSuperAdminHint =>
      'Full administration available via the web panel.';

  @override
  String get parentTitle => 'Child';

  @override
  String get teacherClassesTitle => 'My Classes';

  @override
  String get teacherClassesComingSoon => 'Class area — coming soon';

  @override
  String get loginPrimaryButton => 'Continue';

  @override
  String get splashHai3Label => 'Educational Messenger';

  @override
  String get settingsTabClasses => 'My Classes';

  @override
  String get settingsTabVerwaltung => 'Administration';

  @override
  String get chatTypeClass => 'Class group';

  @override
  String get chatTypeSchool => 'School group';

  @override
  String get chatOnline => 'Online';

  @override
  String get chatLastSeen => 'Last seen';

  @override
  String get chatUnknown => 'Unknown';

  @override
  String get chatNoMessages => 'No messages yet';

  @override
  String get chatFirstMessage => 'Write the first message!';

  @override
  String get chatNewMessages => 'New messages';

  @override
  String get chatDateToday => 'Today';

  @override
  String get chatDateYesterday => 'Yesterday';
}
