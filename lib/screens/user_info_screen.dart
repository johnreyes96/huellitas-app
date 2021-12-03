import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'package:huellitas_app_flutter/components/loader_component.dart';
import 'package:huellitas_app_flutter/helpers/api_helper.dart';
import 'package:huellitas_app_flutter/helpers/regex_helper.dart';
import 'package:huellitas_app_flutter/models/response.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/models/user.dart';
import 'package:huellitas_app_flutter/screens/pets_screen.dart';
import 'package:huellitas_app_flutter/screens/user_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class UserInfoScreen extends StatefulWidget {
  final Token token;
  final User user;
  final bool isAdmin;

  // ignore: use_key_in_widget_constructors
  const UserInfoScreen({required this.token, required this.user, required this.isAdmin});

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
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
          ? LoaderComponent(text: 'Por favor espere...')
          : _getContent()
      ),
    );
  }

  Future<Null> _getUser() async {
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
          AlertDialogAction(key: null, label: 'Aceptar')
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
        _showButtons()
      ],
    );
  }

  Widget _showButtons() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: const Text('Citas'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return const Color(0xFF004489);
                  }
                ),
              ),
              onPressed: () => {}
            ),
          ),
          const SizedBox(width: 20,),
          Expanded(
            child: ElevatedButton(
              child: const Text('Mascotas'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return const Color(0xFF004489);
                  }
                ),
              ),
              onPressed: () => _goPets()
            ),
          ),
        ],
      ),
    );
  }

  void _goPets() async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetsScreen(
        token: widget.token,
        user: _user,
        isAdmin: widget.isAdmin,
      ))
    );
    if (result == 'yes') {
      _getUser();
    }
  }

  Widget _showUserInfo() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(5),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: _user.imageFullPath,
                      errorWidget: (context, url, err) => Icon(Icons.error),
                      fit: BoxFit.cover,
                      height: 200,
                      width: 200,
                      placeholder: (context, url) => Image(
                        image: AssetImage('assets/huellitas_logo.png'),
                        fit: BoxFit.cover,
                        height: 200,
                        width: 200,
                      )
                    )
                  ),
                  Positioned(
                    bottom: 0,
                    left: 140,
                    child: InkWell(
                      onTap: () => _goEdit(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          color: Colors.green[50],
                          height: 60,
                          width: 60,
                          child: Icon(
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
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Text(
                                  'Email: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004489)
                                  )
                                ),
                                Text(
                                  _user.email, 
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                Text(
                                  'Tipo documento',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004489)
                                  )
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  _user.documentType.description, 
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                Text(
                                  'Documento: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004489)
                                  )
                                ),
                                Text(
                                  _user.document, 
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                Text(
                                  'Dirección: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004489)
                                  )
                                ),
                                Text(
                                  _user.address, 
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                Text(
                                  'Teléfono: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004489)
                                  )
                                ),
                                Text(
                                  '+${_user.countryCode} ${_user.phoneNumber}',
                                  style: TextStyle(
                                    fontSize: 14
                                  )
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                Text(
                                  '# Citas: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004489)
                                  )
                                ),
                                Text(
                                  _user.appointments.length.toString(),
                                  style: TextStyle(
                                    fontSize: 14
                                  )
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                Text(
                                  '# Mascotas: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004489)
                                  )
                                ),
                                Text(
                                  _user.petsCount.toString(),
                                  style: TextStyle(
                                    fontSize: 14
                                  )
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            widget.isAdmin ? _showCallButtons() : Container()
                          ]
                        ),
                      )
                    ]
                  )
                )
              ),
            ],
          ),
        ]
      )
    );
  }

  _goEdit() async {
    String? result = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => UserScreen(
          token: widget.token, 
          user: _user,
          myProfile: widget.isAdmin,
        )
      )
    );
    if (result == 'yes') {
      //TODO: Pending refresh user info
    }
  }

  Widget _showCallButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 40,
              width: 40,
              color: Colors.blue,
              child: IconButton(
                icon: Icon(Icons.call, color: Colors.white,),
                onPressed: () => launch('tel://+${widget.user.countryCode}${RegexHelper.removeBlankSpaces(widget.user.phoneNumber)}'), 
              ),
            ),
          ),       
          SizedBox(width: 10,),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 40,
              width: 40,
              color: Colors.green,
              child: IconButton(
                icon: Icon(Icons.insert_comment, color: Colors.white,),
                onPressed: () => _sendMessage(), 
              ),
            ),
          ),       
          SizedBox(width: 10,),
      ],
    );
  }

  void _sendMessage() async {
    final link = WhatsAppUnilink(
      phoneNumber: '+${widget.user.countryCode}${RegexHelper.removeBlankSpaces(widget.user.phoneNumber)}',
      text: 'Hola te escribo de la clínica veterinaria.',
    );
    await launch('$link');  
  }
}