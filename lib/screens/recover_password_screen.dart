import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:huellitas_app_flutter/components/loader_component.dart';
import 'package:huellitas_app_flutter/helpers/api_helper.dart';
import 'package:huellitas_app_flutter/models/response.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({ Key? key }) : super(key: key);

  @override
  _RecoverPasswordScreenState createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  bool _showLoader = false;

  String _email = '';
  String _emailError = '';
  bool _emailShowError = false;
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar contraseña'),
        backgroundColor: const Color(0xFF004489),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              SizedBox(height: 20),
              _showEmail(),
              _showButtons()
            ]
          ),
          _showLoader ? LoaderComponent(text: 'Por favor espere...') : Container()
        ],
      )
    );
  }

  Widget _showEmail() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Ingresa tu email...',
          labelText: 'Email',
          errorText: _emailShowError ? _emailError : null,
          prefixIcon: Icon(Icons.alternate_email),
          suffixIcon: Icon(Icons.email),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          )
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showButtons() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _showRecoverButton(),
        ],
      ),
    );
  }

  Widget _showRecoverButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text('Recuperar contraseña'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return Color(0xFF004489);
            }
          )
        ),
        onPressed: () => _recoverPassword()
      ),
    );
  }

  void _recoverPassword() {
    if (!_validateFields()) {
      return;
    }

    _sendRecoverPassword();
  }

  bool _validateFields() {
    bool isValid = true;
    
    if (_email.isEmpty) {
      isValid = true;
      _emailShowError = true;
      _emailError = 'Debes ingresar tu email.';
    } else if (!EmailValidator.validate(_email)) {
      isValid = true;
      _emailShowError = true;
      _emailError = 'Debes ingresar un email válido.';
    } else {
      _emailShowError = false;
    }

    setState(() { });
    return isValid;
  }

  void _sendRecoverPassword() async {
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

    Map<String, dynamic> request = {
      'email': _email
    };

    Response response = await ApiHelper.postNoToken(
      '/api/Account/RecoverPassword',
      request
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
          AlertDialogAction(key: null, label: 'Aceptar')
        ]
      );
      return;
    }

    await showAlertDialog(
        context: context,
        title: 'Confirmación',
        message: 'Se le ha enviado un correo con las instrucciones para recuperar su contraseña.',
        actions: <AlertDialogAction>[
          AlertDialogAction(key: null, label: 'Aceptar')
        ]
      );

    Navigator.pop(context);
  }
}