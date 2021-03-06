import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/screens/appointment_types_screen.dart';
import 'package:huellitas_app_flutter/screens/appointments_screen.dart';
import 'package:huellitas_app_flutter/screens/document_types_screen.dart';
import 'package:huellitas_app_flutter/screens/login_screen.dart';
import 'package:huellitas_app_flutter/screens/pet_types_screen.dart';
import 'package:huellitas_app_flutter/screens/services_screen.dart';
import 'package:huellitas_app_flutter/screens/user_info_screen.dart';
import 'package:huellitas_app_flutter/screens/user_screen.dart';
import 'package:huellitas_app_flutter/screens/users_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  // ignore: use_key_in_widget_constructors
  const HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Huellitas',
          style: GoogleFonts.lato(),
        ),
        backgroundColor: const Color(0xFF004489)
      ),
      body: _getBody(),
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: const Color(0xFF004489)
        ),
        child: widget.token.user.userType == 0
          ? _getVeterianMenu() 
          : _getCustomerMenu()
      ),
    );
  }

  Widget _getBody() {
    return Container(
      margin: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(150),
            child: CachedNetworkImage(
              imageUrl: widget.token.user.imageFullPath,
              errorWidget: (context, url, err) => const Icon(Icons.error),
              fit: BoxFit.cover,
              height: 300,
              width: 300,
              placeholder: (context, url) => const Image(
                image: AssetImage('assets/huellitas_logo.png'),
                fit: BoxFit.cover,
                height: 300,
                width: 300
              )
            )
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              'Bienvenid@ ${widget.token.user.fullName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004489)
              )
            )
          ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Llamar a la cl??nica veterinaria'),
                SizedBox(width: 10,),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 40,
                    width: 40,
                    color: Colors.blue,
                    child: IconButton(
                      icon: Icon(Icons.call, color: Colors.white,),
                      onPressed: () => launch("tel://+573223114620"), 
                    ),
                  ),
                )
              ],
            ),       
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Enviar mensaje a la cl??nica'),
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
                )
              ],
            ),  
        ]
      )
    );
  }

  Widget _getVeterianMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Image(
              image: AssetImage('assets/huellitas_logo.png')
            )
          ),
          const Divider(
            color: Colors.black, 
            height: 2
          ),
          ListTile(
            leading: const Icon(
              Icons.medical_services,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Servicios',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => ServicesScreen(token: widget.token,)
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.assignment_ind,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Tipos de Documento',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => DocumentTypesScreen(token: widget.token,)
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.content_copy,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Tipos de Cita',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => AppointmentTypesScreen(token: widget.token,)
                )
              );
            },
          ),
          
          ListTile(
            leading: const Icon(
              Icons.pets,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Tipos de Mascota',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => PetTypesScreen(token: widget.token,)
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.language,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Huellitas en WEB',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () => launch("https://apihuellitas.azurewebsites.net/"),
          ),
          ListTile(
            leading: const Icon(
              Icons.people,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Usuarios',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => UsersScreen(token: widget.token,)
                )
              );
            },
          ),
          const Divider(
            color: Colors.black, 
            height: 2
          ),
          ListTile(
            leading: const Icon(
              Icons.account_circle,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Editar Perfil',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => UserScreen(
                    token: widget.token,
                    user: widget.token.user,
                    myProfile: false
                  )
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Cerrar Sesi??n',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () => _logOut()
          )
        ]
      )
    );
  }

  Widget _getCustomerMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            child: Image(
              image: AssetImage('assets/huellitas_logo.png')
            )
          ),
          const Divider(
            color: Colors.black, 
            height: 2
          ),
          ListTile(
            leading: const Icon(
              Icons.pets,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Mis mascotas',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => UserInfoScreen(
                    token: widget.token,
                    user: widget.token.user,
                    isAdmin: false
                  )
                )
              );
            }
          ),
          ListTile(
            leading: const Icon(
              Icons.event,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Citas',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => AppointmentsScreen(token: widget.token,)
                )
              );
            },
          ),
          const Divider(
            color: Colors.black, 
            height: 2
          ),
          ListTile(
            leading: const Icon(
              Icons.account_circle,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Editar Perfil',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (context) => UserScreen(
                    token: widget.token,
                    user: widget.token.user,
                    myProfile: false
                  )
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.white
            ),
            tileColor: const Color(0xFF004489),
            title: const Text(
              'Cerrar Sesi??n',
              style: TextStyle(
                color: Colors.white
              )
            ),
            onTap: () => _logOut()
          )
        ]
      )
    );
  }

  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', false);
    await prefs.setString('userBody', '');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen()
      )
    );
  }

  void _sendMessage() async {
    final link = WhatsAppUnilink(
      phoneNumber: '+573223114620',
      text: 'Hola soy ${widget.token.user.fullName} cliente de la cl??nica veterinaria'
    );
    await launch('$link');
  }
} 