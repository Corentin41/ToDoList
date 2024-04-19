import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:todolist/model/task.dart';
import 'package:todolist/widgets/updateTask.dart';
import 'package:http/http.dart' as http;


class DisplayTask extends StatelessWidget {
  final Task task;

  const DisplayTask({super.key, required this.task});



  static void showTask(context, Task task) {
    // Récupérer la taille de l'écran
    Size size = MediaQuery.of(context).size;

    // Récupérer les données météo
    //List<String> weatherResponse = _getWeather() as List<String>;

    /*if (task.lat.toString().isNotEmpty && task.lng.toString().isNotEmpty) {
      setWeatherDetails(task.lat, task.lng);
    }*/


    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      context: context,
      builder: (BuildContext bc) {
        // Détails du ModalBottomSheet
        return Container(
          height: size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topRight: Radius.circular(40.0), topLeft: Radius.circular(40.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              // Faire redescendre le ModalBottomSheet vers le bas pour le fermer
              //physics: const ClampingScrollPhysics(),
              children: [


                // Bouton pour modifier la tâche
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(top: 10, left: 300),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: IconButton(
                    color: Colors.white,
                    iconSize: 16,
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // Aller sur la page pour modifier la tâche
                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateTask(task: task)));
                    },
                  ),
                ),



                // Titre de la tâche
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('Titre : ${task.name}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),



                // Description de la tâche
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    // S'il n'y a pas de description alors on précise
                    task.description.isEmpty
                        ? 'Description : Aucune description pour cette tâche'
                        : 'Description :${task.description}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),



                // Date de la tâche
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('Date : ${task.date.toString()}',
                      style: const TextStyle(fontSize: 15),
                    ),
                ),



                // Adresse de la tâche
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    // S'il n'y a pas d'adresse alors on précise
                    task.address.toString().isEmpty
                        ? 'Adresse : Aucune adresse pour cette tâche'
                        : 'Adresse : ${task.address}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),



                // Afficher l'adresse sur une map (seulement s'il y a une adresse)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: task.address.toString().isNotEmpty
                    ? Container(
                    padding: const EdgeInsets.all(10),
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
                  ) : null,
                ),



                // Affichage des données météo
                /*Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: task.address.toString().isNotEmpty
                        ? // Afficher la météo s'il y a une adresse stockée en BDD
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
                    ) : null
                ),*/







              ],
            ),
          ),
        );
      },
    );
  }



  // Fonction pour récupérer l'adresse en fonction des coordonnées stockées en BDD
  void setWeatherDetails(String lat, String lng) async {
    double latitude = double.parse(lat);
    double longitude = double.parse(lng);

    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    String city = placemarks.first.locality!;
    _getWeather(city);
  }



  //Fonction pour récupérer les données météo de la ville passée en paramètre
  Future<List<String>> _getWeather(String city) async {
    const apiKey = '2caa69c974fa32ae3887bf4ad6de26a2'; // La clé API à demander sur OpenWeatherMap
    final apiUrl = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=fr';

    List<String> weatherResponse = [];

    final reponse = await http.get(Uri.parse(apiUrl));

    if (reponse.statusCode == 200) {
      Map<String, dynamic> meteoData = json.decode(reponse.body);
      // Récupérer les températures
      weatherResponse.add('${meteoData['main']['temp_min']}°C');
      weatherResponse.add('${meteoData['main']['temp_min']}°C');
      weatherResponse.add('${meteoData['main']['temp']}°C');
      weatherResponse.add('${meteoData['weather'][0]['icon']}');
      return weatherResponse;
    } else {
      throw Exception('Echec lors de la récupération des données');
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}