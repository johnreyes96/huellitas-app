
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:huellitas_app_flutter/components/loader_component.dart';
import 'package:huellitas_app_flutter/helpers/api_helper.dart';
import 'package:huellitas_app_flutter/models/appointment_type.dart';
import 'package:huellitas_app_flutter/models/response.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/screens/appointment_type_screen.dart';

class AppointmentTypesScreen extends StatefulWidget {
    final Token token;

    AppointmentTypesScreen({required this.token});


    @override
    _AppointmentTypesScreenState createState() => _AppointmentTypesScreenState();
}


class _AppointmentTypesScreenState extends State<AppointmentTypesScreen> {
    List<AppointmentType> _appointmentTypes = [];
    bool _showLoader = false;
    bool _isFiltered = false;
    String _search = '';



    @override
    void initState() {
      super.initState();
      _getAppointmentTypes();
    }

    @override
    Widget build(BuildContext context) {
            return Scaffold(
          appBar: AppBar(
            title: Text(
              'Tipos de citas',
              style: GoogleFonts.lato(),
            ),
            backgroundColor: const Color(0xFF004489),
            actions: <Widget>[
              _isFiltered
              ? IconButton(
                  onPressed: _removeFilter, 
                  icon: Icon(Icons.filter_none)
                )
              : IconButton(
                  onPressed: _showFilter, 
                  icon: Icon(Icons.filter_alt)
                )
            ],
          ),
          body: Center(
            child: _showLoader ? LoaderComponent(text: 'Cargando...') : _getContent(),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => _goAdd(),
          ),
        );
    }



    Future<Null> _getAppointmentTypes() async {
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




    Widget _getContent() {
    return _appointmentTypes.length == 0 
      ? _noContent()
      : _getListView();
    } 


      Widget _noContent() {
        return Center(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Text(
              _isFiltered
              ? 'No hay tipos de citas con ese criterio de búsqueda.'
              : 'No hay tipos de citas registradas.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        );
      }



      Widget _getListView() {
        return RefreshIndicator(
          onRefresh: _getAppointmentTypes,
          child: ListView(
            children: _appointmentTypes.map((e) {
              return Card(
                child: InkWell(
                  onTap: () => _goEdit(e),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.description, 
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      );
    }

      void _showFilter() {
        showDialog(
          context: context, 
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text('Filtrar Tipos de Citas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text('Escriba las primeras letras del tipo de cita'),
                  SizedBox(height: 10,),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Criterio de búsqueda...',
                      labelText: 'Buscar',
                      suffixIcon: Icon(Icons.search)
                    ),
                    onChanged: (value) {
                      _search = value;
                    },
                  )
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), 
                  child: Text('Cancelar')
                ),
                TextButton(
                  onPressed: () => _filter(), 
                  child: Text('Filtrar')
                ),
              ],
            );
          });
      }

      void _removeFilter() {
        setState(() {
          _isFiltered = false;
        });
        _getAppointmentTypes();
      }

      void _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<AppointmentType> filteredList = [];
    for (var appointmentType in _appointmentTypes) {
      if (appointmentType.description.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(appointmentType);
      }
    }

    setState(() {
      _appointmentTypes = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }


  void _goAdd() async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => AppointmentTypeScreen(
          token: widget.token, 
          appointmentType: AppointmentType(description: '', id: 0),
        )
      )
    );
    if (result == 'yes') {
      _getAppointmentTypes();
    }
  }


  void _goEdit(AppointmentType appointmentType) async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => AppointmentTypeScreen(
          token: widget.token, 
          appointmentType: appointmentType,
        )
      )
    );
    if (result == 'yes') {
      _getAppointmentTypes();
    }
  }

}