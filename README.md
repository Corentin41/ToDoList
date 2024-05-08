# ToDoList

## API utilisées

### API
- OpenStreetMap : pour récupérer et afficher les données météo à partir de l'adresse saisie

### Packages Flutter
- intl :
- shared_preferences : pour garder en mémoire certains choix de l'utilisateur (langue de l'application, thème sombre ou clair, tri de la liste des tâches)
- sqflite : pour la persistance des données à l'aide d'une BDD locale
- flutter_map : pour afficher l'adresse saisie sur une carte (OpenStreetMap)
- latlong2 : pour centrer la map et afficher un marqueur sur l'adresse saisie
- geocoding : pour récupérer les coordonnées GPS (lat, lng) à partir d'une adresse sous forme de String
- quickalert : pour afficher une custom Alert Dialog lors la supression d'une tâche ou si l'utilisateur a saisi une adresse incorrecte lors de la création ou modification de tâche
- provider : observateur pour changer le thème de l'application (sombre ou clair)
- flutter_localizations : pour modifier la langue de l'application
- flutter_launcher_icons : pour ajouter un logo à l'application (Android et iOS)

## Spécificités du projet
Pour ce projet, nous avons respecté toutes les contraintes imposées par le sujet. Nous avons ajouté quelques fonctionnalités supplémentaires comme le changement de thème directement via les paramètres de l'application (en cliquant sur l'icône des settings dans la barre de navigation sur la page d'accueil) et une traduction dans 3 langues :
- Français
- Anglais
- Espagnol

!!! flutter gen-l10n !! pour la trad

## Aucune limitation
