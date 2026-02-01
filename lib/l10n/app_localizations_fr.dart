// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get name => 'Nom';

  @override
  String get addTask => 'Ajouter une tâche';

  @override
  String get addName => 'Veuillez saisir un nom';

  @override
  String get desc => 'Description';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get address => 'Adresse';

  @override
  String get setPriority => 'Définir en tant que tâche prioritaire : ';

  @override
  String get warning => 'Attention';

  @override
  String get wrongAddress =>
      'Vous avez saisi une adresse incorrecte ou inexistante';

  @override
  String get noInternet => 'Pas de connexion Internet';

  @override
  String get networkAlertTitle => 'Erreur réseau';

  @override
  String get networkAlertContent =>
      'Veuillez vous connecter à Internet pour valider l\'adresse';

  @override
  String get ok => 'OK';

  @override
  String get add => 'Ajouter';

  @override
  String get cancel => 'Annuler';

  @override
  String get weatherException => 'Echec lors de la récupération des données';

  @override
  String get taskDesc => 'Description de la tâche';

  @override
  String get noDesc => 'Aucune description pour cette tâche';

  @override
  String get noDate => 'Aucune date pour cette tâche';

  @override
  String get noAddress => 'Aucune adresse pour cette tâche';

  @override
  String get now => 'Actuellement';

  @override
  String get minMax => 'min / max';

  @override
  String get editTask => 'Modifier la tâche';

  @override
  String get changePriority => 'Changer le niveau de priorité : ';

  @override
  String get edit => 'Modifier';

  @override
  String get priority => 'Priorité';

  @override
  String get creationDate => 'Date de création';

  @override
  String get noTask => 'Aucune tâche';

  @override
  String get deleteTask => 'Supprimer la tâche';

  @override
  String get confirmDeleteTask => 'Confirmer la suppression de la tâche ?';

  @override
  String get delete => 'OK';

  @override
  String get myTasks => 'Mes tâches';

  @override
  String get settings => 'Paramètres';

  @override
  String get whichDisplayOrder => 'Quel ordre pour l\'affichage des tâches ?';

  @override
  String get displayCompletedTasks => 'Afficher les tâches terminées ?';

  @override
  String get taskDeleted => 'Tâche supprimée avec succès';

  @override
  String get language => 'Langue';

  @override
  String get darkMode => 'Mode sombre';
}
