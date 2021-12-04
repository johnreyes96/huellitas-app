

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huellitas_app_flutter/components/loader_component.dart';
import 'package:huellitas_app_flutter/helpers/api_helper.dart';
import 'package:huellitas_app_flutter/model/event.dart';
import 'package:huellitas_app_flutter/models/appointment.dart';
import 'package:huellitas_app_flutter/models/appointment_type.dart';
import 'package:huellitas_app_flutter/models/response.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/provider/event_provider.dart';
import 'package:huellitas_app_flutter/utils.dart';
import 'package:provider/provider.dart';

class EventEditingPage extends StatefulWidget {
  final Event? event;
  final Token token;

  const EventEditingPage({
    Key? key,
    this.event,
    required this.token,
  }):super(key: key);

  @override
  _EventEditingPageState createState() => _EventEditingPageState();

}


class _EventEditingPageState extends State<EventEditingPage> {
  late DateTime fromDate;
  final _formKey = GlobalKey<FormState>();
  bool _showLoader = false;
  List<AppointmentType> _appointmentTypes = [];
  int _appointmentTypeId = 0;
  String _appointmentTypesIdError = '';
  bool _appointmentTypeIdShowError = false;
  late AppointmentType _appointmentTy;

  @override
  void initState(){
    super.initState();
    _getComboAppointmentType();
    if(widget.event == null){
      fromDate = DateTime.now();
    }else{
        final event = widget.event!;
        _appointmentTy.description = event.description;
        fromDate = event.from;
    }
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        actions: buildEditingActions(),
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _showLoader ? LoaderComponent(text: 'Por favor espere...',) : Container(),
                  showTypesAppointments(),
                  SizedBox(height: 12,),
                  buildDateTimePickers(),
              ],
            ),
            
          ),
          
      ),
    );
  }

  List<Widget> buildEditingActions() => [
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        primary: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      onPressed: saveForm,
      icon: Icon(Icons.done), 
      label: Text('Guardar'))
  ];


  Widget showTypesAppointments(){
    return Container(
      padding: EdgeInsets.all(10),
      child: _appointmentTypes.length == 0 
        ? Text('Cargando tipos de consulta...')
        : DropdownButtonFormField(
            items: _getComboAppointmentTypes(),
            value: _appointmentTypeId,
            onChanged: (option) {
              setState(() {
                _appointmentTypeId = option as int;
                _appointmentTy = option as AppointmentType;
                print("Tipo cita: " + _appointmentTy.description);
              });
            },
            decoration: InputDecoration(
              hintText: 'Seleccione un tipo de consulta...',
              labelText: 'Tipo de Consulta',
              errorText: _appointmentTypeIdShowError ? _appointmentTypesIdError : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          )
    );
  }


  Widget buildDateTimePickers() => Column(
    children: [
        buildForm(),
    ],
  );


   Widget buildForm() => buildHeader(
    header: 'Fecha Cita',
    child: Row( 
      children: [
          Expanded(
            flex: 2,
            child: buildDropdownField(
              text: Utils.toDate(fromDate),
              onClicked: () => pickFromDateTime(pickDate: true),
            ),
          ),
          Expanded(
            child: buildDropdownField(
              text: Utils.toTime(fromDate),
              onClicked: () => pickFromDateTime(pickDate: false),
            ),
          )
      ],
    )
  );


 

   List<DropdownMenuItem<int>> _getComboAppointmentTypes() {
    List<DropdownMenuItem<int>> list = [];
    
    list.add(DropdownMenuItem(
      child: Text('Seleccione un tipo de consulta...'),
      value: 0,
    ));

    _appointmentTypes.forEach((appointmentType) { 
      list.add(DropdownMenuItem(
        child: Text(appointmentType.description),
        value: appointmentType.id,
      ));
    });

    return list;
  }


  Future<Null> _getComboAppointmentType() async {
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

    Response response = await ApiHelper.getAppointmentTypes(widget.token);

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
      _appointmentTypes = response.result;
    });
  }

  Widget buildDropdownField({required String text, required VoidCallback onClicked}) => 
    ListTile(
      title: Text(text),
      trailing: Icon(Icons.arrow_drop_down),
      onTap: onClicked,
    );

  
  
  Widget buildHeader({required String header, required Widget child}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: TextStyle(fontWeight: FontWeight.bold)),
          child,
        ],
      );

  Future saveForm() async {
    if (!_validateFields()) {
      return;
    }
    final event = Appointment(
      appointmentType: _appointmentTy,
      date: fromDate,
      id: 0
    );

    final provider = Provider.of<EventProvider>(context, listen: true);
    provider.addEvent(event);
    _saveRecord(event);
    
  }

void _saveRecord(Appointment event) async {
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

    Map<String, dynamic> request = {
      'userId': widget.token.user.id,
      'appointmentTypeId': _appointmentTy.id,
      'date': fromDate,
    };

    Response response = await ApiHelper.post(
      '/api/Appointments/', 
      request, 
      widget.token
    );

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

    Navigator.pop(context, 'yes');
  }

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(fromDate, pickDate: pickDate);
    if(date == null) return;
    setState(() => fromDate = date);
  }

  Future<DateTime?> pickDateTime(
    DateTime initialDate, {
    required bool pickDate,
    DateTime? firstDate,

    }) async {
        if(pickDate){
          final date = await showDatePicker(
            context: context, 
            initialDate: initialDate,
            firstDate: firstDate ?? DateTime(2015, 8),
            lastDate: DateTime(2101),);
        
          if(date == null) return null;  
          final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);
          return date.add(time);
        }else{
          final timeOfDay = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(initialDate),
          );

          if(timeOfDay == null) return null;

          final date = DateTime(initialDate.year, initialDate.month, initialDate.day);
          final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);
        }
  }


  bool _validateFields() {
      bool isValid = true;
      if (_appointmentTypeId == 0) {
      isValid = false;
      _appointmentTypeIdShowError = true;
      _appointmentTypesIdError = 'Debes seleccionar un tipo de cita.';
    } else {
      _appointmentTypeIdShowError = false;
    }

    setState(() { });
    return isValid;
  }
  
}