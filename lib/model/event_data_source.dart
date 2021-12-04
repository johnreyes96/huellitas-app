import 'package:huellitas_app_flutter/model/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
  
  EventDataSource(List<Event> appointments){
    this.appointments = appointments;
  }

  Event getEvent(int index) => appointments![index] as Event;

  @override
  DateTime getStartTime(int index) => getEvent(index).from;

  @override
  String getSubject(int index) => getEvent(index).description;

}