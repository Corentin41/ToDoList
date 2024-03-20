//import 'geopoint.dart';

class ToDo {
  String? id;
  bool isDone;
  String? todoTitle;
  //DateTime date;
  //#GeoPoint localisation;

  ToDo({
    required this.id,
    this.isDone = false,
    required this.todoTitle,
  });

}