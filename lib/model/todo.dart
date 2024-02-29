//import 'geopoint.dart';

class ToDo {
  String? id;
  bool isDone;
  String? todoTitle;
  //DateTime date;
  //#GeoPoint localisation;

  ToDo({
    required this.id,
    required this.todoTitle,
    this.isDone = false,
  });

  static List<ToDo> todoList() {
    return [
      ToDo(id: '01', todoTitle: 'Ménage'),
      ToDo(id: '02', todoTitle: 'RDV Medecin'),
      ToDo(id: '03', todoTitle: 'Bar'),
      ToDo(id: '04', todoTitle: 'Sport'),
      ToDo(id: '05', todoTitle: 'Soirée'),
    ];
  }

}