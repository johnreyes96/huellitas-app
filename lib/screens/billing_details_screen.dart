import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:huellitas_app_flutter/components/loader_component.dart';
import 'package:huellitas_app_flutter/helpers/api_helper.dart';
import 'package:huellitas_app_flutter/models/billing.dart';
import 'package:huellitas_app_flutter/models/billing_detail.dart';
import 'package:huellitas_app_flutter/models/pet.dart';
import 'package:huellitas_app_flutter/models/response.dart';
import 'package:huellitas_app_flutter/models/service_detail.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/models/user.dart';
import 'package:huellitas_app_flutter/screens/billing_detail_screen.dart';
import 'package:huellitas_app_flutter/screens/pet_screen.dart';
import 'package:huellitas_app_flutter/screens/service_detail_screen.dart';

class BillingDetailsScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Pet pet;
  final Billing billing;
  final BillingDetail billingDetail;
  final bool isAdmin;
  
  // ignore: use_key_in_widget_constructors
  const BillingDetailsScreen({ required this.token, required this.user, required this.pet, required this.billing, required this.billingDetail, required this.isAdmin });

  @override
  _BillingDetailsScreenState createState() => _BillingDetailsScreenState();
}

class _BillingDetailsScreenState extends State<BillingDetailsScreen> {
  bool _showLoader = false;
  late BillingDetail _billingDetail;
  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _billingDetail = widget.billingDetail;
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
        onPressed: () => _goAddServiceDetail(ServiceDetail(
          id: 0,
          description: ''
        ))
      )
      : Container()
    );
  }

  Widget _getContent() {
    return Column(
      children: <Widget>[
        _showBillingDetailInfo(),
        Expanded(
          child: _billingDetail.serviceDetails.isEmpty ? _noContent() : _getListView()
        )
      ],
    );
  }

  Widget _showBillingDetailInfo() {
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
                          children: const <Widget>[
                            Text(
                              'Servicio',
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
                              _billingDetail.service.description,
                              style: const TextStyle(
                                fontSize: 14
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: const <Widget>[
                            Text(
                              'Valor unitario',
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
                              NumberFormat.currency(symbol: '\$').format(_billingDetail.unitValue),
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
                              'Cantidad: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004489)
                              )
                            ),
                            Text(
                              _billingDetail.quantity.toString(),
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
                              '# Detalles del servicio: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF004489)
                              )
                            ),
                            Text(
                              _billingDetail.serviceDetails.length.toString(),
                              style: const TextStyle(
                                fontSize: 14
                              )
                            ),
                          ],
                        ),
                      ]
                    ),
                  ),
                  widget.isAdmin
                  ? Positioned(
                      bottom: 0,
                      left: 80,
                      child: InkWell(
                        onTap: () => _goEditBillingDetail(),
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
                  : Container()
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
          isAdmin: widget.isAdmin,
        )
      )
    );
  }

  Widget _noContent() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: const Text(
          'El detalle de la factura no tiene detalles del servicio',
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
      onRefresh: _getBillingDetail,
      child: ListView(
        children: _billingDetail.serviceDetails.map((e) {
          return Card(
            child: InkWell(
              onTap: () => _goServiceDetail(e),
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        e.description,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold
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

  void _goServiceDetail(ServiceDetail serviceDetail) async {
    if (!widget.isAdmin) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(
        token: widget.token,
        billingDetail: widget.billingDetail,
        serviceDetail: serviceDetail,
      ))
    );
  }

  _goEditBillingDetail() async {
    await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => BillingDetailScreen(
          token: widget.token, 
          user: widget.user,
          pet: widget.pet,
          billing: widget.billing,
          billingDetail: widget.billingDetail
        )
      )
    );
  }

  Future<void> _getBillingDetail() async {
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

    Response response = await ApiHelper.getBillingDetail(widget.token, _billingDetail.id.toString());

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
      _billingDetail = response.result;
    });
  }

  void _goAddServiceDetail(ServiceDetail serviceDetail) async {
    if (!widget.isAdmin) {
      return;
    }

    String? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(
        token: widget.token,
        billingDetail: widget.billingDetail,
        serviceDetail: serviceDetail,
      ))
    );
    if (result == 'yes') {
    }
  }
}