import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:todolist/model/task.dart';
import 'package:todolist/widgets/updateTask.dart';
import 'package:http/http.dart' as http;


class DisplayTask extends StatelessWidget {
  final Task task;

  const DisplayTask({super.key, required this.task});


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }


  static Future<void> showTask(context, Task task) async {
    // Récupérer la taille de l'écran
    Size size = MediaQuery.of(context).size;


    // Pour les données météo
    String _tempMin = '';
    String _tempActuelle = '';
    String _tempMax = '';
    String _icon = '';


    // Si on a une adresse pour la tâche alors on peut récupérer la météo
    if (task.lat.toString().isNotEmpty && task.lng.toString().isNotEmpty) {
      double latitude = double.parse(task.lat.toString());
      double longitude = double.parse(task.lng.toString());

      // Récupérer la météo à partir d'une ville
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      String city = placemarks.first.locality!;


      // Appel à l'API Météo
      const apiKey = '2caa69c974fa32ae3887bf4ad6de26a2'; // La clé API à demander sur OpenWeatherMap
      final apiUrl = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=fr';

      final reponse = await http.get(Uri.parse(apiUrl));

      if (reponse.statusCode == 200) {
        Map<String, dynamic> meteoData = json.decode(reponse.body);
        // Récupérer les températures
        _tempMin = '${meteoData['main']['temp_min']}°C';
        _tempActuelle = '${meteoData['main']['temp_min']}°C';
        _tempMax = '${meteoData['main']['temp']}°C';

        // Récupérer le type d'icone
        _icon = '${meteoData['weather'][0]['icon']}';
      } else {
        throw Exception('Echec lors de la récupération des données');
      }
    }


    // Affichage des données de la tâche dans un BottomSheet
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.background,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: double.maxFinite),
      context: context,
      builder: (BuildContext bc) {

        // Détails du BottomSheet
        return Container(
          // Hauteur du BottomSheet
          height: size.height * 0.7,
          decoration: const BoxDecoration(
            // Arrondir les bords supérieurs du BottomSheet
            borderRadius: BorderRadius.only(topRight: Radius.circular(40.0), topLeft: Radius.circular(40.0)),
          ),
          child: Column(
            children: [



              // En-tête du BottomSheet
              Column(
                children: [
                  // Affichage d'une petite barre
                  Padding(
                    padding: const EdgeInsets.only(left: 150, top: 20, right: 150, bottom: 20),
                    child: Container(
                      height: 8,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),


                  // Titre de l'en-tête + Bouton Modifier
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Espace pour centrer le titre
                      const SizedBox(width: 32),
                      // Titre de l'en-tête
                      const Text(
                        'Description de la tâche',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      // Bouton pour modifier la tâche
                      IconButton(
                        icon: const Icon(Icons.edit, size: 32),
                        onPressed: () {
                          // Aller sur la page pour modifier la tâche
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateTask(task: task)));
                        },
                      )
                    ],
                  ),


                  // Affichage d'une petite barre pour séparer l'en-tête du contenu
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      height: 1,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary,
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),



              // Contenu du BottomSheet
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [


                        // Pour les infos primaires
                        Container(
                          width: double.maxFinite,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // Titre de la tâche (Flexible pour le overflow)
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: SizedBox(
                                    child: Text(task.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                // Description de la tâche (SizedBox pour gérer le texte qui déborde)
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: SizedBox(
                                    // S'il n'y a pas de description alors on précise
                                    child: task.description.isEmpty
                                        ? const Text('Aucune description pour cette tâche', style: TextStyle(fontStyle: FontStyle.italic))
                                        : Text(task.description),
                                  ),
                                ),
                              ],
                            )
                          ),
                        ),



                        // Date de la tâche
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(Icons.event_note),
                                ),
                                // S'il n'y a pas de description alors on précise
                                task.date.toString().isEmpty
                                    ? const Text('Aucune date pour cette tâche', style: TextStyle(fontStyle: FontStyle.italic))
                                    : Text(task.date.toString())
                              ],
                            ),
                          ),
                        ),



                        // Informations concernant l'adresse (adresse, map et météo)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Adresse de la tâche
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Icon(IconData(0xe3ab, fontFamily: 'MaterialIcons')),
                                    ),
                                    // S'il n'y a pas de d'adresse alors on précise
                                    task.address.toString().isEmpty
                                        ? const Text('Aucune adresse pour cette tâche', style: TextStyle(fontStyle: FontStyle.italic))
                                        : Flexible(child: Text(task.address.toString()))
                                  ],
                                ),



                                // Adresse sur une map (seulement s'il y a une adresse stockée en BDD)
                                Container(
                                  child: task.address.toString().isNotEmpty ?
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    height: 240,
                                    child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: LatLng(task.getDoubleLat(),
                                            task.getDoubleLng()),
                                        initialZoom: 11,

                                      ),
                                      children: [
                                        // Pour afficher la map centrée sur l'adresse entrée précédemment
                                        TileLayer(
                                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                                        ),
                                        MarkerLayer(
                                            markers: [
                                              Marker(
                                                width: 80.0,
                                                height: 80.0,
                                                point: LatLng(task.getDoubleLat(), task.getDoubleLng()),
                                                child: const Icon(
                                                  Icons.location_pin,
                                                  color: Colors.red,
                                                  size: 50.0,
                                                ),
                                              )
                                            ]
                                        ),
                                      ],
                                    ),
                                  )
                                  // Sinon ne rien afficher
                                  : null
                                ),



                                // Données météo relatives à l'adresse
                                Container(
                                  // Afficher la météo seulement s'il y a une adresse stockée en BDD
                                  child: task.address.toString().isNotEmpty ?
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child:
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          // Temp Actuelle
                                          children: [
                                            const Text("Actuellement"),
                                            Text(_tempActuelle),
                                          ],
                                        ),
                                        // Icon météo
                                        Container(
                                            child: _icon.isNotEmpty
                                            // Si on trouve un icone lié à la météo alors l'afficher
                                                ? Image.network('http://openweathermap.org/img/w/$_icon.png', fit: BoxFit.cover)
                                            // Par défaut on n'affiche rien
                                                : null
                                        ),
                                        // Temp Min Max
                                        Column(
                                          children: [
                                            const Text("min / max"),
                                            Text("$_tempMin / $_tempMax"),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                  // Sinon ne rien afficher
                                  : null
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        );
      },
    );
  }
}