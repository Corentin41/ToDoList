// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get name => 'Name';

  @override
  String get addTask => 'Add a task';

  @override
  String get addName => 'Please, add a name';

  @override
  String get desc => 'Description';

  @override
  String get dueDate => 'Due date';

  @override
  String get address => 'Address';

  @override
  String get setPriority => 'Set as priority task : ';

  @override
  String get warning => 'Warning';

  @override
  String get wrongAddress => 'You entered an incorrect or non-existent address';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get networkAlertTitle => 'Network error';

  @override
  String get networkAlertContent =>
      'Please connect to the internet to validate the address';

  @override
  String get ok => 'OK';

  @override
  String get add => 'Add';

  @override
  String get cancel => 'Cancel';

  @override
  String get weatherException => 'Failed to retrieve data';

  @override
  String get taskDesc => 'Description of the task';

  @override
  String get noDesc => 'No description for this task';

  @override
  String get noDate => 'No date for this task';

  @override
  String get noAddress => 'No address for this task';

  @override
  String get now => 'Currently';

  @override
  String get minMax => 'min / max';

  @override
  String get editTask => 'Edit task';

  @override
  String get changePriority => 'Change priority level : ';

  @override
  String get edit => 'Edit';

  @override
  String get priority => 'Priority';

  @override
  String get creationDate => 'Creation date';

  @override
  String get noTask => 'No task';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get confirmDeleteTask => 'Confirm task deletion ?';

  @override
  String get delete => 'OK';

  @override
  String get myTasks => 'My tasks';

  @override
  String get settings => 'Settings';

  @override
  String get whichDisplayOrder => 'What order should tasks be displayed?';

  @override
  String get displayCompletedTasks => 'Show completed tasks ?';

  @override
  String get taskDeleted => 'Task deleted successfully';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark mode';
}
