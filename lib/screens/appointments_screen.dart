import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huellitas_app_flutter/models/appointment.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/pages/event_editing_page.dart';
import 'package:huellitas_app_flutter/provider/event_provider.dart';
import 'package:huellitas_app_flutter/widgets/calendar_widget.dart';
import 'package:provider/provider.dart';


class AppointmentsScreen extends StatefulWidget {
    final Token token;
    AppointmentsScreen({required this.token});


    @override
    _AppointmentsScreenState createState() => _AppointmentsScreenState();
}



class _AppointmentsScreenState extends State<AppointmentsScreen> {
    

    @override
    void initState() {
      super.initState();
    }


    @override
    Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Citas"),
          centerTitle: true,
        ),
        body: CalendarWidget(token: widget.token),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Colors.white,),
          backgroundColor: Colors.red,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => EventEditingPage(
              token: widget.token,
            )),
          ),
        ),
        
      )
    );
    

}
