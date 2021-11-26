import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:huellitas_app_flutter/components/loader_component.dart';
import 'package:huellitas_app_flutter/helpers/api_helper.dart';
import 'package:huellitas_app_flutter/models/pet.dart';
import 'package:huellitas_app_flutter/models/pet_type.dart';
import 'package:huellitas_app_flutter/models/response.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/models/user.dart';
import 'package:huellitas_app_flutter/screens/pet_info_screen.dart';
import 'package:huellitas_app_flutter/screens/pet_screen.dart';
import 'package:huellitas_app_flutter/screens/user_screen.dart';

class PetsScreen extends StatefulWidget {
  final Token token;
  final User user;
  final bool isAdmin;

  // ignore: use_key_in_widget_constructors
  const PetsScreen({required this.token, required this.user, required this.isAdmin});

  @override
  _PetsScreenState createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  bool _showLoader = false;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _getUser();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user.fullName),
        backgroundColor: const Color(0xFF004489),
      ),
      body: Center(
        child: _showLoader
          ? const LoaderComponent(text: 'Por favor espere...')
          : _getContent()
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF004489),
        onPressed: () => _goAddPet(Pet(
          id: 0,
          petType: PetType(id: 0, description: ''),
          name: '',
          race: '',
          color: '',
          observations: '',
          petPhotosCount: 0,
          petPhotos: [],
          imageFullPath: '',
          billings: [],
          billingsCount: 0))
      ),
    );
  }

  Future<void> _getUser() async {
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
          const AlertDialogAction(key: null, label: 'Aceptar')
        ]
      );
      return;
    }

    Response response = await ApiHelper.getUser(widget.token, _user.id);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
        context: context,
        title: 'Error',
        message: response.message,
        actions: <AlertDialogAction>[
          const AlertDialogAction(key: null, label: 'Aceptar')
        ]
      );
      return;
    }

    setState(() {
      _user = response.result;
    });
  }

  Widget _getContent() {
    return Column(
      children: <Widget>[
        _showUserInfo(),
        Expanded(
          child: _user.pets.isEmpty ? _noContent() : _getListView()
        )
      ],
    );
  }

  _goAddPet(Pet pet) async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetScreen(
        token: widget.token,
        user: _user,
        pet: pet
      ))
    );
    if (result == 'yes') {
      _getUser();
    }
  }

  Widget _showUserInfo() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl: _user.imageFullPath,
                  errorWidget: (context, url, err) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  height: 100,
                  width: 100,
                  placeholder: (context, url) => const Image(
                    image: AssetImage('assets/huellitas_logo.png'),
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                  )
                )
              ),
              Positioned(
                bottom: 0,
                left: 60,
                child: InkWell(
                  onTap: () => _goEdit(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      color: Colors.green[50],
                      height: 40,
                      width: 40,
                      child: const Icon(
                        Icons.edit,
                        size: 30,
                        color: Color(0xFF004489)
                      )
                    )
                  ),
                )
              )
            ]
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: const <Widget>[
                            Text(
                              'Tipo documento',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004489)
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            Text(
                              _user.documentType.description, 
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            const Text(
                              'Documento: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004489)
                              )
                            ),
                            Text(
                              _user.document, 
                              style: const TextStyle(
                                fontSize: 14
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            const Text(
                              'Teléfono: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004489)
                              )
                            ),
                            Text(
                              '+${_user.phoneNumber}', 
                              style: const TextStyle(
                                fontSize: 14
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: <Widget>[
                            const Text(
                              '# Vehículos: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004489)
                              )
                            ),
                            Text(
                              _user.petsCount.toString(),
                              style: const TextStyle(
                                fontSize: 14
                              )
                            ),
                          ],
                        ),
                      ]
                    ),
                  )
                ]
              )
            )
          )
        ]
      )
    );
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: const Text(
          'El usuario no tiene mascotas registradas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004489)
          ),
        ),
      ),
    );
  }

  Widget _getListView() {
    return RefreshIndicator(
      onRefresh: _getUser,
      child: ListView(
        children: _user.pets.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goPet(e),
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(160),
                      child: CachedNetworkImage(
                        imageUrl: e.imageFullPath,
                        errorWidget: (context, url, err) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                        height: 80,
                        width: 80,
                        placeholder: (context, url) => const Image(
                          image: AssetImage('assets/huellitas_logo.png'),
                          fit: BoxFit.cover,
                          height: 80,
                          width: 80,
                        )
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  e.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004489)
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      e.race,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      e.color,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    )
                                  ]
                                )
                              ]
                            )
                          ]
                        )
                      )
                    ),
                    const Icon(
                      Icons.play_arrow,
                      size: 40,
                      color: Color(0xFF004489)
                    )
                  ]
                )
              )
            )
          );
        }).toList(),
      )
    );
  }

  void _goEdit() async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => UserScreen(
          token: widget.token, 
          user: _user,
          myProfile: false,
        )
      )
    );
    if (result == 'yes') {
      _getUser();
    }
  }

  void _goPet(Pet pet) async{
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetInfoScreen(
        token: widget.token,
        user: _user,
        pet: pet,
        isAdmin: widget.isAdmin
      ))
    );
    if (result == 'yes') {
      _getUser();
    }
  }
}