# ToDoList
Ce projet a été réalisé par :
- Corentin RIO
- Baptiste LE GOUHINEC

## API utilisées

### API
- OpenStreetMap : pour récupérer et afficher les données météo à partir de l'adresse saisie

### Packages Flutter
- shared_preferences : pour sauvegarder les choix de l'utilisateur (langue, thème, tri de la liste, afficher ou non les tâches terminées)
- sqflite : pour la persistance des données à l'aide d'une BDD locale
- flutter_map : pour afficher l'adresse saisie sur une carte (OpenStreetMap)
- latlong2 : pour centrer la map et afficher un marqueur sur l'adresse saisie
- geocoding : pour récupérer les coordonnées GPS (lat, lng) à partir d'une adresse sous forme de String
- quickalert : pour afficher une custom Alert Dialog lors la supression d'une tâche ou si l'utilisateur a saisi une adresse incorrecte
- provider : observateur pour changer le thème de l'application (sombre ou clair)
- flutter_localizations : pour modifier la langue de l'application
- intl : pour faciliter l'internationalisation
- flutter_launcher_icons : pour ajouter un logo à l'application (Android et iOS)

## Spécificités du projet
Pour ce projet, nous avons respecté toutes les contraintes imposées par le sujet. Nous avons aussi ajouté quelques fonctionnalités supplémentaires :
- changement du thème de l'application (thème clair / thème sombre)
- traduction de l'application (Français, Anglais, Espagnol)

Toutes ces fonctionnalités sont accessibles via le bouton des paramètres qui se trouve dans la navBar (sur la page d'affichage des tâches)

## Limitations
Avant de lancer le projet pour la première fois et après chaque modification des fichiers de langues (app_en.arb,...), il faut utiliser la commande ```flutter gen-l10n``` dans le
terminal afin de générer les fichiers d'internationalisation pour la traduction de l'application.

Nous n'avons pas réussi à exporter dans un fichier autre que home.dart le formulaire des paramètres. Nous avons essayé mais étant donné qu'une fois le nouveau mode de tri sélectionné
il fallait rafraichir la page, nous n'avons pas pu.
