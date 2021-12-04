import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huellitas_app_flutter/model/event_data_source.dart';
import 'package:huellitas_app_flutter/provider/event_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class TasksWidget extends StatefulWidget {
  @override
  _TasksWidgetState createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget>{

    @override
    Widget build(BuildContext context){
      final provider = Provider.of<EventProvider>(context);
      final selectedEvents = provider.eventsOfSelectedDate;
      if(selectedEvents.isEmpty){
          return Center(
            child: Text(
              'Citas no encontradas',
              style: TextStyle(color: Colors.black, fontSize: 24),
            ),
          );
      }
      return SfCalendarTheme(
        data: SfCalendarThemeData(
          timeTextStyle: TextStyle(fontSize: 16, color: Colors.black)
        ),
        child: SfCalendar(
          view: CalendarView.timelineDay,
          //dataSource: EventDataSource(provider.events),
          initialDisplayDate: provider.selectedDate,
          appointmentBuilder: appointmentBuilder,
          headerHeight: 0,
          todayHighlightColor: Colors.black,
          selectionDecoration: BoxDecoration(
            color: Colors.transparent.withOpacity(0.3),
          ),
        ),
      );
    }

  Widget appointmentBuilder(BuildContext context, CalendarAppointmentDetails details) {
    final event = details.appointments.first;
    return Container(
      width: details.bounds.width,
      height: details.bounds.height,
      decoration: BoxDecoration(
        color: event.backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
      child: Text(
        event.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),

      ),
    ),
    );
  }
}

