import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huellitas_app_flutter/components/loader_component.dart';
import 'package:huellitas_app_flutter/helpers/api_helper.dart';
import 'package:huellitas_app_flutter/model/event_data_source.dart';
import 'package:huellitas_app_flutter/models/response.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/provider/event_provider.dart';
import 'package:huellitas_app_flutter/widgets/tasks_widget.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarWidget extends StatefulWidget {
    final Token token;
    
    
    CalendarWidget({required this.token});


    @override
    _CalendarWidgetsState createState() => _CalendarWidgetsState();
}



class _CalendarWidgetsState extends State<CalendarWidget> {
    List<Appointment> appointment = [];
    bool _showLoader = false;
    @override
    void initState() {
      super.initState();
      _getAppointments(widget.token);
    }

  @override
  Widget build(BuildContext context){
    final events = Provider.of<EventProvider>(context).events;
    return SfCalendar(
      view: CalendarView.month,
      //dataSource: EventDataSource(events),
      initialSelectedDate: DateTime.now(),
      cellBorderColor: Colors.transparent,
      onLongPress: (details){
        body: Center(
          child: _showLoader  ?  LoaderComponent(text: 'Por favor espere...') : Container(),
        );
        final provider = Provider.of<EventProvider>(context, listen: true);
        provider.setDate(details.date!);
        showModalBottomSheet(
          context: context, 
          builder: (context) => TasksWidget(),
        );
      },
    );
  }

  Future<Null> _getAppointments(Token token) async {
    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: 'Verifica que estes conectado a internet.',
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    Response response = await ApiHelper.getAppointments(widget.token);
    print('Token: ' + widget.token.token);
    print('id: ' + widget.token.user.id);
    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: response.message,
        actions: <AlertDialogAction>[
            AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    setState(() {
      appointment = response.result;
    });
  }


}

