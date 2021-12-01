import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:huellitas_app_flutter/model/event.dart';
import 'package:huellitas_app_flutter/pages/day_view_page.dart';
import 'package:huellitas_app_flutter/pages/month_view_page.dart';
import 'package:huellitas_app_flutter/pages/week_view_page.dart';
import '../../extension.dart';


class AppointmentsScreen extends StatefulWidget {
    
    AppointmentsScreen();


    @override
    _AppointmentsScreenState createState() => _AppointmentsScreenState();
}



class _AppointmentsScreenState extends State<AppointmentsScreen> {
    

    @override
    void initState() {
      super.initState();
      _getAppointments();
    }


    @override
    Widget build(BuildContext context){
      
    return Scaffold(
      appBar: AppBar(
        title: Text("Citas"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => context.pushRoute(MonthViewPageDemo()),
              child: Text("Ver Citas Mensual"),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => context.pushRoute(DayViewPageDemo()),
              child: Text("Ver Citas por Dia"),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () => context.pushRoute(WeekViewDemo()),
              child: Text("Ver Citas por Semana"),
            ),
          ],
        ),
      ),
    );
    }

   Widget  _getAppointments(){
      return CalendarControllerProvider<Event>(
      controller: EventController<Event>()..addAll(_events),
      child: MaterialApp(
        title: 'Flutter Calendar Page Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(),
        home: ResponsiveWidget(
          mobileWidget: MobileHomePage(),
          webWidget: WebHomePage(),
        ),
      ),
    );
    }


}

DateTime get _now => DateTime.now();
List<CalendarEventData<Event>> _events = [
      CalendarEventData(
        date: _now,
        event: Event(title: "Joe's Birthday"),
        title: "Project meeting",
        description: "Today is project meeting.",
        startTime: DateTime(_now.year, _now.month, _now.day, 18, 30),
        endTime: DateTime(_now.year, _now.month, _now.day, 22),
    ),
];