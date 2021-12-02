import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:huellitas_app_flutter/components/loader_component.dart';
import 'package:huellitas_app_flutter/helpers/api_helper.dart';
import 'package:huellitas_app_flutter/models/document_type.dart';
import 'package:huellitas_app_flutter/models/response.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/models/user.dart';
import 'package:huellitas_app_flutter/screens/user_info_screen.dart';
import 'package:huellitas_app_flutter/screens/user_screen.dart';

class UsersScreen extends StatefulWidget {
  final Token token;

  UsersScreen({required this.token});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<User> _users = [];
  bool _showLoader = false;
  bool _isFiltered = false;
  String _search = '';
  
  @override
  void initState() {
    super.initState();
    _getUsers();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
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
        child: _showLoader ? LoaderComponent(text: 'Por favor espere...') : _getContent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: const Color(0xFF004489),
        onPressed: () => _goAdd(),
      ),
    );
  }

  Future<Null> _getUsers() async {
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
        message: 'Verifica que estés conectado a internet.',
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar')
        ]
      );
      return;
    }

    Response response = await ApiHelper.getUsers(widget.token);

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
      _users = response.result;
    });
  }

  void _removeFilter() {
    setState(() {
      _isFiltered = false;
    });
    _getUsers();
  }

  void _showFilter() {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text('Filtrar Usuarios'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Escriba las primeras letras del nombre o apellidos del usuario'),
              SizedBox(height: 10,),
              TextField(
                autofocus: true,
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

  Widget _getContent() {
    return _users.length == 0 
      ? _noContent()
      : _getListView();
  }

  _goAdd() async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => UserScreen(
          token: widget.token, 
          myProfile: false,
          user: User(
            firstName: '', 
            lastName: '', 
            documentType: DocumentType(id: 0, description: ''), 
            document: '', 
            address: '', 
            imageId: '', 
            imageFullPath: '', 
            userType: 0, 
            fullName: '',
            pets: [],
            petsCount: 0,
            appointments: [],
            id: '', 
            userName: '', 
            email: '', 
            phoneNumber: ''
          ),
        )
      )
    );
    if (result == 'yes') {
      _getUsers();
    }
  }

  _filter() {
    if (_search.isEmpty) {
      return;
    }

    List<User> filteredList = [];
    for (var user in _users) {
      if (user.fullName.toLowerCase().contains(_search.toLowerCase())) {
        filteredList.add(user);
      }
    }

    setState(() {
      _users = filteredList;
      _isFiltered = true;
    });

    Navigator.of(context).pop();
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        child: Text(
          _isFiltered
          ? 'No hay usuarios con ese criterio de búsqueda.'
          : 'No hay usuarios registradas.',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004489),
          ),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getUsers,
      child: ListView(
        children: _users.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goInfoUser(e),
              child: Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: CachedNetworkImage(
                        imageUrl: e.imageFullPath,
                        errorWidget: (context, url, err) => Icon(Icons.error),
                        fit: BoxFit.cover,
                        height: 70,
                        width: 70,
                        placeholder: (context, url) => Image(
                          image: AssetImage('assets/huellitas_logo.png'),
                          fit: BoxFit.cover,
                          height: 70,
                          width: 70,
                        )
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  e.fullName, 
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004489),
                                  ),
                                ),
                                SizedBox(height: 5,),
                                Text(
                                  e.email, 
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '+ ${e.phoneNumber}',
                                  style: TextStyle(
                                    fontSize: 14
                                  )
                                )
                              ]
                            )
                          ]
                        )
                      )
                    ),
                    Icon(
                      Icons.play_arrow,
                      color: Color(0xFF004489),
                    )
                  ]
                )
              )
            )
          );
        }).toList()
      )
    );
  }

  _goInfoUser(User user) async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(
          token: widget.token, 
          user: user,
          isAdmin: true,
        )
      )
    );
    if (result == 'yes') {
      _getUsers();
    }
  }
}