# ToDoList
Ce projet a été réalisé par :
- Corentin RIO
- Baptiste LE GOUHINEC

## API utilisées

### API
- OpenWeatherMap : pour récupérer et afficher les données météo à partir de l'adresse saisie

### Packages Flutter
- shared_preferences : pour sauvegarder les choix de l'utilisateur (langue, thème, tri de la liste, tâches terminées)
- sqflite : pour la persistance des données à l'aide d'une BDD locale
- internet_connection_checker : pour vérifier qu'on a accès à un réseau Internet pour l'API et la map
- flutter_map : pour afficher l'adresse saisie sur une carte (OpenStreetMap)
- latlong2 : pour centrer la map et afficher un marqueur sur l'adresse saisie
- geocoding : pour récupérer les coordonnées GPS (lat, lng) à partir d'une adresse sous forme de String
- quickalert : pour afficher une custom Alert Dialog lors la supression d'une tâche ou si l'utilisateur a saisi une adresse incorrecte
- back_button_interceptor : pour empêcher l'utilisateur de faire retour lorsqu'il est sur la page d'accueil
- provider : observateur pour changer le thème de l'application (sombre ou clair)
- flutter_localizations : pour modifier la langue de l'application
- intl : pour faciliter l'internationalisation
- flutter_launcher_icons : pour ajouter un logo à l'application (Android et iOS)
- flutter_dotenv : pour charger les données sensibles depuis un fichier .env

## Spécificités du projet
Pour ce projet, nous avons respecté toutes les contraintes imposées par le sujet. Nous avons aussi ajouté quelques fonctionnalités supplémentaires :
- changement du thème de l'application (thème clair / thème sombre)
- traduction de l'application (Français, Anglais, Espagnol)

Toutes ces fonctionnalités sont accessibles via le bouton des paramètres qui se trouve dans la navBar (sur la page d'affichage des tâches)

## Limitations
Pour récupérer la météo, il faut créer le fichier ```.env``` à la racine du projet et y mettre sa clé API OpenWeatherMap. Le contenu du fichier ```.env``` doit ressembler à ça :

```API_KEY=VOTRE_CLE_API```

Avant de lancer le projet pour la première fois et après chaque modification des fichiers de langues (app_en.arb,...), il arrive que le code ne trouve pas les fichiers d'internationalisation pour la traduction de l'application. 
Ceux-ci ne sont pas générés automatiquement et celà crée l'erreur dans les import pour récupérer les Strings de l'application :

```Target of URI doesn't exist: 'package:flutter_gen/gen_l10n/app_localizations.dart'.```

Le problème devrait être résolu grâce à l'ajout du fichier ```l10n.yaml```.
Cependant, si l'erreur persiste, vous pouvez utiliser la commande ```flutter gen-l10n``` dans le terminal afin de générer les fichiers.

Nous n'avons pas réussi à exporter dans un fichier autre que home.dart le formulaire des paramètres. Nous avons essayé mais étant donné qu'une fois le nouveau mode de tri sélectionné
il fallait rafraichir la page, nous n'avons pas pu.

Lors du changement de thème, le Bottom Sheet ne prend pas en compte le changement de thème (passage en mode sombre ou clair). Pour résoudre ce problème, nous avons choisi de fermer le Bottom Sheet après modification du thème.
Ce qui donne une transition visuellement étrange avec par exemple un Bottom Sheet en theme clair qui se ferme alors que l'application est en mode sombre. Toutefois, ce soucis visuel est très furtif et n'impacte en rien le fonctionnement de l'application.
