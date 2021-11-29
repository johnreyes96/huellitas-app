import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:huellitas_app_flutter/components/loader_component.dart';
import 'package:huellitas_app_flutter/helpers/api_helper.dart';
import 'package:huellitas_app_flutter/models/billing.dart';
import 'package:huellitas_app_flutter/models/pet.dart';
import 'package:huellitas_app_flutter/models/response.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/models/user.dart';
import 'package:huellitas_app_flutter/screens/billing_info_screen.dart';
import 'package:huellitas_app_flutter/screens/pet_screen.dart';

class PetInfoScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Pet pet;
  final bool isAdmin;
  
  // ignore: use_key_in_widget_constructors
  const PetInfoScreen({required this.token, required this.user, required this.pet, required this.isAdmin });

  @override
  _PetInfoScreenState createState() => _PetInfoScreenState();
}

class _PetInfoScreenState extends State<PetInfoScreen> {
  bool _showLoader = false;
  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_pet.name} ${_pet.race}'),
        backgroundColor: const Color(0xFF004489),
      ),
      body: Center(
        child: _showLoader
          ? const LoaderComponent(text: 'Por favor espere...')
          : _getContent()
      ),
      floatingActionButton: widget.isAdmin ? 
        FloatingActionButton(
          child: const Icon(Icons.add),
          backgroundColor: const Color(0xFF004489),
          onPressed: () => _addBilling()
        )
      : Container()
    );
  }

  Widget _getContent() {
    return Column(
      children: <Widget>[
        _showPetInfo(),
        Expanded(
          child: _pet.billings.isEmpty ? _noContent() : _getListView()
        )
      ],
    );
  }
  
  Widget _showPetInfo() {
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
                  imageUrl: _pet.imageFullPath,
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
                          children: <Widget>[
                            const Text(
                              'Nombre: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004489)
                              )
                            ),
                            Text(
                              _pet.name,
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
                              'Raza: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004489)
                              )
                            ),
                            Text(
                              _pet.race,
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
                              'Color: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004489)
                              )
                            ),
                            Text(
                              _pet.color,
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
                              '# Fotos: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004489)
                              )
                            ),
                            Text(
                              _pet.petPhotosCount.toString(),
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
                              '# Facturas: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004489)
                              )
                            ),
                            Text(
                              _pet.billingsCount.toString(),
                              style: const TextStyle(
                                fontSize: 14
                              )
                            ),
                          ],
                        )
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
          'La mascota no tiene facturas asociadas',
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
      onRefresh: _getPet,
      child: ListView(
        children: _pet.billings.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goBilling(e),
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  DateFormat('yyyy-MM-dd').format(DateTime.parse(e.dateLocal)),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004489)
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Total: ${NumberFormat.currency(symbol: '\$').format(e.totalValue)}',
                                      style: const TextStyle(
                                        fontSize: 14
                                      ),
                                    ),
                                  ]
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      '# Servicios: ${e.billingDetailsCount}',
                                      style: const TextStyle(
                                        fontSize: 14
                                      ),
                                    ),
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
    await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => PetScreen(
          token: widget.token, 
          user: widget.user,
          pet: _pet,
        )
      )
    );
  }

  Future<void> _getPet() async {
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

    Response response = await ApiHelper.getPet(widget.token, _pet.id.toString());

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
      _pet = response.result;
    });
  }

  void _addBilling() async {
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

    Map<String, dynamic> request = {
      'petId': widget.pet.id,
    };

    Response response = await ApiHelper.post(
      '/api/Billings/',
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
          const AlertDialogAction(key: null, label: 'Aceptar')
        ]
      );
      return;
    }

    await _getPet();
  }

  void _goBilling(Billing billing) async {
    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillingInfoScreen(
        token: widget.token,
        user: widget.user,
        pet: _pet,
        billing: billing,
        isAdmin: widget.isAdmin,
      ))
    );
    if (result == 'yes') {
      await _getPet ();
    }
  }
}