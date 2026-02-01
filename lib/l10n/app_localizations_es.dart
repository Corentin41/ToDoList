// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get name => 'Nombre';

  @override
  String get addTask => 'Agregar una tarea';

  @override
  String get addName => 'Por favor, agregar un nombre';

  @override
  String get desc => 'Descripción';

  @override
  String get dueDate => 'Fecha de vencimiento';

  @override
  String get address => 'Dirección';

  @override
  String get setPriority => 'Establecer como una tarea prioritaria : ';

  @override
  String get warning => 'Cuidado';

  @override
  String get wrongAddress =>
      'Ingresaste una dirección incorrecta o inexistente';

  @override
  String get noInternet => 'Sin conexión a Internet';

  @override
  String get networkAlertTitle => 'Error de red';

  @override
  String get networkAlertContent =>
      'Por favor conéctese a Internet para validar la dirección';

  @override
  String get ok => 'OK';

  @override
  String get add => 'Agregar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get weatherException => 'No se pudieron recuperar los datos';

  @override
  String get taskDesc => 'Descripción de la tarea';

  @override
  String get noDesc => 'No descripción para esta tarea';

  @override
  String get noDate => 'No fecha para esta tarea';

  @override
  String get noAddress => 'No dirección para esta tarea';

  @override
  String get now => 'Actualmente';

  @override
  String get minMax => 'min / max';

  @override
  String get editTask => 'Modificar la tarea';

  @override
  String get changePriority => 'Cambiar nivel de prioridad : ';

  @override
  String get edit => 'Modificar';

  @override
  String get priority => 'Prioridad';

  @override
  String get creationDate => 'Fecha de creación';

  @override
  String get noTask => 'Ninguno tarea';

  @override
  String get deleteTask => 'Eliminar la tarea';

  @override
  String get confirmDeleteTask => '¿Confirmar la supresión de la tarea?';

  @override
  String get delete => 'OK';

  @override
  String get myTasks => 'Mis tareas';

  @override
  String get settings => 'Parámetros';

  @override
  String get whichDisplayOrder => '¿Qué orden deben mostrar las tareas?';

  @override
  String get displayCompletedTasks => '¿Mostrar tareas completadas?';

  @override
  String get taskDeleted => 'Tarea eliminada exitosamente';

  @override
  String get language => 'Idioma';

  @override
  String get darkMode => 'Modo oscuro';
}
