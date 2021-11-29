import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:huellitas_app_flutter/components/loader_component.dart';
import 'package:huellitas_app_flutter/helpers/api_helper.dart';
import 'package:huellitas_app_flutter/models/billing.dart';
import 'package:huellitas_app_flutter/models/billing_detail.dart';
import 'package:huellitas_app_flutter/models/pet.dart';
import 'package:huellitas_app_flutter/models/response.dart';
import 'package:huellitas_app_flutter/models/service.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/models/user.dart';
import 'package:huellitas_app_flutter/screens/billing_detail_screen.dart';
import 'package:huellitas_app_flutter/screens/billing_details_screen.dart';
import 'package:huellitas_app_flutter/screens/pet_screen.dart';
import 'package:intl/intl.dart';

class BillingInfoScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Pet pet;
  final Billing billing;
  final bool isAdmin;
  
  // ignore: use_key_in_widget_constructors
  const BillingInfoScreen({ required this.token, required this.user, required this.pet, required this.billing, required this.isAdmin });

  @override
  _BillingInfoScreenState createState() => _BillingInfoScreenState();
}

class _BillingInfoScreenState extends State<BillingInfoScreen> {
  bool _showLoader = false;
  late Billing _billing;
  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _billing = widget.billing;
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
      floatingActionButton: widget.isAdmin
      ? FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF004489),
        onPressed: () => _goBillingDetail(BillingDetail(
          id: 0,
          quantity: 0,
          unitValue: 0,
          valueSubtotal: 0,
          service: Service(id: 0, description: ''),
          serviceDetails: []
        ))
      )
      : Container()
    );
  }

  Widget _getContent() {
    return Column(
      children: <Widget>[
        _showPetInfo(),
        Expanded(
          child: _billing.billingDetails.isEmpty ? _noContent() : _getListView()
        )
      ],
    );
  }

  void _goBillingDetail(BillingDetail billingDetail) async {
    if (!widget.isAdmin) {
      return;
    }

    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillingDetailScreen(
        token: widget.token,
        user: widget.user,
        pet: widget.pet,
        billing: widget.billing,
        billingDetail: billingDetail
      ))
    );
    if (result == 'yes') {
      await _getBilling();
    }
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

  Widget _noContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: const Text(
          'La factura no tiene detalle',
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
      onRefresh: _getBilling,
      child: ListView(
        children: _billing.billingDetails.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goBillingDetails(e),
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  e.service.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF004489)
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Valor unitario: ${NumberFormat.currency(symbol: '\$').format(e.unitValue)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ]
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Cantidad: ${e.quantity}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ]
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'Total: ${NumberFormat.currency(symbol: '\$').format(e.valueSubtotal)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ]
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      '# Detalles del servicio: ${e.serviceDetails.length}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ]
                                ),
                              ]
                            )
                          ]
                        )
                      )
                    ),
                    widget.isAdmin
                    ? const Icon(
                        Icons.play_arrow,
                        size: 40,
                        color: Color(0xFF004489)
                      )
                    : Container()
                  ]
                )
              )
            )
          );
        }).toList(),
      ),
    );
  }

  Future<void> _getBilling() async {
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

    Response response = await ApiHelper.getBilling(widget.token, widget.billing.id.toString());

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
      _billing= response.result;
    });
  }

  void _goBillingDetails(BillingDetail billingDetail) async {
    if (!widget.isAdmin) {
      return;
    }

    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillingDetailsScreen(
        token: widget.token,
        user: widget.user,
        pet: widget.pet,
        billing: widget.billing,
        billingDetail: billingDetail,
        isAdmin: widget.isAdmin,
      ))
    );
    if (result == 'yes') {
      await _getBilling();
    }
  }
}