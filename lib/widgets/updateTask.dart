import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:todolist/model/task.dart';
import 'package:todolist/screens/home.dart';
import 'package:http/http.dart' as http;


import '../database/task_db.dart';

class UpdateTask extends StatefulWidget {
  final Task task;

  const UpdateTask({super.key, required this.task});

  @override
  State<UpdateTask> createState() => _UpdateTaskState();
}

class _UpdateTaskState extends State<UpdateTask> {


  // Liste des tâches et la BDD
  Future<List<Task>>? futureTasks;
  final taskDB = TaskDB();

  // Pour le BottomSheet
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Initialiser les valeur contenues dans une tâche
  String _taskName = '';
  String _taskDesc = '';
  int _taskPriority = 2;
  String _lat = '';
  String _lng = '';

  // Initialiser les String pour les températures
  String _tempMin = '';
  String _tempActuelle = '';
  String _tempMax = '';

  // Initialiser le chemin de l'icone
  String _icon = '';

  // Contiennent les valeurs dans le form
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();


  @override
  initState() {
    super.initState();
    loadTasks();
    // Initialiser le niveau de priorité de la tâche à modifier
    _taskPriority = widget.task.priority;
    _lat = widget.task.lat!;
    _lng = widget.task.lng!;
    // Récupérer l'adresse
    setWeatherDetails(_lat, _lng);
    _addressController.text = widget.task.address!;
  }


  loadTasks() async {
    String sortPref = 'priority';
    futureTasks = taskDB.fetchAll(sortPref);
  }


  // Fonction pour vérifier si l'utilisateur a entré une date ou non
  bool checkDate(Task task) {
    if (task.date != null && task.date!.isNotEmpty) {
      return true;
    }
    return false;
  }


  // Pour afficher la map centrée sur l'adresse entrée précédemment
  TileLayer get openStreetMapTilelayer =>
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la tâche'),
      ),
      body: Padding(
        // Espace entre l'AppBar et le Form
        padding: const EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [

                    // Champ pour modifier le titre de la tâche
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Nom"
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir un nom';
                          }
                          else {
                            return null;
                          }
                        },
                        // Afficher le titre précédemment entré par l'utilisateur
                        initialValue: widget.task.name,
                        onSaved: (nameValue) {
                          _taskName = nameValue!;
                        },
                      ),
                    ),

                    // Champ pour modifier la description
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        minLines: 5,
                        //controller: _descController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Description"
                        ),
                        // Afficher la description précédemment entrée par l'utilisateur
                        initialValue: widget.task.description,
                        onSaved: (descValue) {
                          _taskDesc = descValue!;
                        },
                      ),
                    ),

                    // Champ pour modifier la date
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: TextField(
                        controller: _dateController,
                        // Afficher la date dans le champ s'il y avait déjà une date, sinon afficher un label
                        decoration: checkDate(widget.task) == true
                            ? InputDecoration(
                            border: OutlineInputBorder(), hintText: widget.task
                            .date.toString())
                            : const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Date d\'échéance'),
                        // Pour modifier la date, on doit cliquer sur le champ qui va ouvir une dialog
                        readOnly: true,
                        onTap: () async {
                          final DateTime? dateTime = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          // S'il y a une date sélectionnée alors on pourra l'enregistrer en BDD
                          if (dateTime != null) {
                            setState(() {
                              _dateController.text =
                              dateTime.toString().split(" ")[0];
                            });
                          }
                        },
                      ),
                    ),

                    // Champ pour modifier l'adresse
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        controller: _addressController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Adresse"
                        ),
                      ),
                    ),

                    // Affichage de l'adresse sur une map
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: widget.task.address!.isNotEmpty
                          ? // Afficher la map s'il y a des coords stockées en BDD
                      Container(
                        padding: const EdgeInsets.all(10),
                        height: 240,
                        child: FlutterMap(
                          options: MapOptions(
                              initialCenter: LatLng(widget.task.getDoubleLat(),
                                  widget.task.getDoubleLng()),
                              initialZoom: 11,
                            
                          ),
                          children: [
                            openStreetMapTilelayer,
                            MarkerLayer(
                                markers: [
                                  Marker(
                                      width: 80.0,
                                      height: 80.0,
                                      point: LatLng(widget.task.getDoubleLat(), widget.task.getDoubleLng()),
                                      child: const Icon(
                                        Icons.location_pin,
                                        color: Colors.red,
                                        size: 50.0,
                                      ),)
                                ]),
                          ],
                        ),
                      ) : // Sinon afficher un message
                      Container(
                          padding: const EdgeInsets.all(10),
                          child: const Text(
                              "Aucune adresse renseignée", style: TextStyle(
                              fontWeight: FontWeight.bold))
                      ),
                    ),

                    //Affichage des données météo
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(children: [
                            Text("Actuellement"),
                            Text(_tempActuelle),
                          ],
                          ),

                          Container(
                              child: _icon.isNotEmpty
                              // Si on trouve un icone lié à la météo alors l'afficher
                                  ? Image.network(
                                  'http://openweathermap.org/img/w/$_icon.png',
                                  fit: BoxFit.cover)
                              // Par défaut on n'affiche rien
                                  : null
                          ),
                          Column(children: [
                            Text("min / max"),
                            Text("$_tempMin / $_tempMax"),
                          ],)
                        ],
                      ),
                    ),

                    // Modifier le niveau de priorité de la tâche
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20),
                      child: Row(
                        children: [
                          const Text(
                              "Changer le niveau de priorité : ",
                              style: TextStyle(fontWeight: FontWeight.bold)),

                          IconButton(
                            // Si la tâche est prioritaire (priority à 1) alors afficher une étoile pleine
                            icon: Icon(_taskPriority == 1 ? Icons.star : Icons
                                .star_border,
                                color: Colors.blueAccent
                            ),
                            // Au click, changer le niveau de priorité (1 pour prioritaire et 2 pour secondaire)
                            onPressed: () {
                              setState(() {
                                if (_taskPriority == 2) {
                                  _taskPriority = 1;
                                } else {
                                  _taskPriority = 2;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // Boutons pour confirmer ou annuler la modification
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // Bouton pour confirmer la modification
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              onPressed: () async {
                                // Vérifier que l'utilisateur a saisi au moins un titre pour la tâche
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();

                                  // Si la date n'a pas été modifiée alors prendre la date déjà enregistrée en BDD
                                  if (_dateController.text.isEmpty) {
                                    _dateController.text =
                                        widget.task.date.toString();
                                  }

                                  if (_addressController.text.toString() != widget.task.address){
                                    if(_addressController.text.toString().isNotEmpty){
                                      List<Location> locations = await locationFromAddress(_addressController.text);
                                      _lat = locations.last.latitude.toString();
                                      _lng = locations.last.longitude.toString();
                                    }else{
                                      _lat = '';
                                      _lng = '';
                                    }
                                  }

                                  // Appel à la méthode create de la BDD pour enregistrer la tâche
                                  taskDB.update(
                                    id: widget.task.id,
                                    name: _taskName,
                                    description: _taskDesc,
                                    priority: _taskPriority,
                                    date: _dateController.text.toString(),
                                    lat: _lat,
                                    lng: _lng,
                                    address: _addressController.text.toString(),
                                  );
                                  // Retourner sur la page d'affichage des tâches
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => const HomePage()));
                                }
                              },
                              child: const Text('modifier',
                                style: TextStyle(color: Colors.white),)),
                        ),

                        // Bouton pour annuler la modification de tâche
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              // Retourner sur la page d'affichage des tâches
                              Navigator.pop(context);
                            },
                            child: const Text('annuler',
                              style: TextStyle(color: Colors.white),),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  // Fonction pour récupérer l'adresse en fonction des coordonnées stockées en BDD
  void setWeatherDetails(String lat, String lng) async {
    double latitude = double.parse(lat);
    double longitude = double.parse(lng);

    List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude, longitude);
    String city = placemarks.last.locality!;
    _getWeather(city);
  }

  //Fonction pour récupérer les données météo de la ville passée en paramètre
  Future<void> _getWeather(String city) async {
    const apiKey = '2caa69c974fa32ae3887bf4ad6de26a2'; // La clé API à demander sur OpenWeatherMap
    final apiUrl = 'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric&lang=fr';

    final reponse = await http.get(Uri.parse(apiUrl));

    if (reponse.statusCode == 200) {
      Map<String, dynamic> meteoData = json.decode(reponse.body);
      setState(() {
        // Récupérer les températures
        _tempMin = '${meteoData['main']['temp_min']}°C';
        _tempActuelle = '${meteoData['main']['temp_min']}°C';
        _tempMax = '${meteoData['main']['temp']}°C';

        // Récupérer le type d'icone
        _icon = '${meteoData['weather'][0]['icon']}';
      });
    } else {
      throw Exception('Echec lors de la récupération des données');
    }
  }

}