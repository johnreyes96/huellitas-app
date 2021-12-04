import 'package:flutter/foundation.dart';
import 'package:huellitas_app_flutter/models/appointment.dart';

class EventProvider extends ChangeNotifier {

  final List<Appointment> _events = [];

  List<Appointment> get events => _events;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;

  List<Appointment> get eventsOfSelectedDate => _events;

  void addEvent(Appointment event){
    _events.add(event);
    notifyListeners();
  }

  void deleteEvent(Appointment event){
    _events.remove(event);
    notifyListeners();
  }

  void editEvent(Appointment newEvent, Appointment oldEvent){
    final index = _events.indexOf(oldEvent);
    _events[index] = newEvent;
    notifyListeners();
  }
}