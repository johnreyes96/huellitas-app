import 'package:adaptive_dialog/adaptive_dialog.dart';
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

class BillingDetailScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Pet pet;
  final Billing billing;
  final BillingDetail billingDetail;
  
  // ignore: use_key_in_widget_constructors
  const BillingDetailScreen({ required this.token, required this.user, required this.pet, required this.billing, required this.billingDetail });

  @override
  _BillingDetailScreenState createState() => _BillingDetailScreenState();
}

class _BillingDetailScreenState extends State<BillingDetailScreen> {
  bool _showLoader = false;

  int _serviceId = 0;
  String _serviceIdError = '';
  bool _serviceIdShowError = false;
  List<Service> _services = [];

  String _unitValue = '';
  String _unitValueError = '';
  bool _unitValueShowError = false;
  TextEditingController _unitValueController = TextEditingController();

  String _quantity = '';
  String _quantityError = '';
  bool _quantityShowError = false;
  TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getServices();
    _loadFieldValues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.billingDetail.id == 0
            ? 'Nuevo detalle servicio' 
            : widget.billingDetail.service.description
        ),
        backgroundColor: const Color(0xFF004489),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                _showService(),
                _showUnitValue(),
                _showQuantity(),
                _showButtons(),
              ],
            ),
          ),
          _showLoader ? const LoaderComponent(text: 'Por favor espere...',) : Container(),
        ],
      ),
    );
  }

  Future<void> _getServices() async {
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

    Response response = await ApiHelper.getServices(widget.token);

    setState(() {
      _showLoader = false;
    });

    if (!response.isSuccess) {
      await showAlertDialog(
        context: context,
        title: 'Error', 
        message: response.message,
        actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );    
      return;
    }

    setState(() {
      _services = response.result;
    });
  }

  void _loadFieldValues() {
    _serviceId = widget.billingDetail.service.id;

    _unitValue = widget.billingDetail.unitValue.toString();
    _unitValueController.text = _unitValue;

    _quantity = widget.billingDetail.quantity.toString();
    _quantityController.text = _quantity;
  }

  Widget _showService() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: _services.isEmpty 
        ? const Text('Cargando servicios...')
        : DropdownButtonFormField(
            items: _getComboServices(),
            value: _serviceId,
            onChanged: (option) {
              setState(() {
                _serviceId = option as int;
              });
            },
            decoration: InputDecoration(
              hintText: 'Seleccione un servicio...',
              labelText: 'Servicio',
              errorText: _serviceIdShowError ? _serviceIdError : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          )
    );
  }

  Widget _showUnitValue() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
        controller: _unitValueController,
        decoration: InputDecoration(
          hintText: 'Ingresa valor unitario...',
          labelText: 'Valor unitario',
          errorText: _unitValueShowError ? _unitValueError : null,
          suffixIcon: const Icon(Icons.pets),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          )
        ),
        onChanged: (value) {
          _unitValue = value;
        },
      ),
    );
  }

  Widget _showQuantity() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
        controller: _quantityController,
        decoration: InputDecoration(
          hintText: 'Ingresa cantidad...',
          labelText: 'Cantidad',
          errorText: _quantityShowError ? _quantityError : null,
          suffixIcon: const Icon(Icons.pets),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          )
        ),
        onChanged: (value) {
          _quantity = value;
        },
      ),
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
              child: const Text('Guardar'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return const Color(0xFF120E43);
                  }
                )
              ),
              onPressed: () => _save()
            ),
          ),
          widget.billingDetail.id == 0
            ? Container()
            : const SizedBox(width: 20,),
          widget.billingDetail.id == 0
            ? Container()
            : Expanded(
              child: ElevatedButton(
                child: const Text('Borrar'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return const Color(0xFFB4161B);
                    }
                  )
                ),
                onPressed: () => _confirmDelete()
              )
            )
        ],
      ),
    );
  }

  List<DropdownMenuItem<int>> _getComboServices() {
    List<DropdownMenuItem<int>> list = [];

    list.add(const DropdownMenuItem(
      child: Text('Seleccione un servicio...'),
      value: 0,
    ));

    for (Service service in _services) { 
      list.add(DropdownMenuItem(
        child: Text(service.description),
        value: service.id,
      ));
    }

    return list;
  }

  _save() {
    if (!_validateFields()) {
      return;
    }

    widget.billingDetail.id == 0 ? _addRecord() : _saveRecord();
  }

  void _confirmDelete() async {
    var response = await showAlertDialog(
      context: context,
      title: 'Confirmación',
      message: '¿Estás seguro de querer borar el registro?',
      actions: <AlertDialogAction>[
        const AlertDialogAction(key: 'no', label: 'No'),
        const AlertDialogAction(key: 'yes', label: 'Si')
      ]
    );

    if (response == 'yes') {
      _deleteRecord();
    }
  }

  void _deleteRecord() async {
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

    Response response = await ApiHelper.delete(
      '/api/BillingDetails/',
      widget.billingDetail.id.toString(),
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

    Navigator.pop(context, 'yes');
  }

  bool _validateFields() {
    bool isValid = true;
    
    if (_serviceId == 0) {
      isValid = false;
      _serviceIdShowError = true;
      _serviceIdError = 'Debes seleccionar un servicio.';
    } else {
      _serviceIdShowError = false;
    }
    
    if (_unitValue.isEmpty) {
      isValid = true;
      _unitValueShowError = true;
      _unitValueError = 'Debes ingresar un valor unitario.';
    } else {
      _unitValueShowError = false;
      double unitValue = double.parse(_unitValue);
      if (unitValue < 0) {
        isValid = true;
        _unitValueShowError = true;
        _unitValueError = 'Debes ingresar un valor unitario positivo.';
      } else {
        _unitValueShowError = false;
      }
    }
    
    if (_quantity.isEmpty) {
      isValid = true;
      _quantityShowError = true;
      _quantityError = 'Debes ingresar una cantidad.';
    } else {
      _quantityShowError = false;
      double quantity = double.parse(_quantity);
      if (quantity < 0) {
        isValid = true;
        _quantityShowError = true;
        _quantityError = 'Debes ingresar una cantidad positivo.';
      } else {
        _quantityShowError = false;
      }
    }
    
    setState(() { });
    return isValid;
  }

  void _addRecord() async {
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
      'billingId': widget.billing.id,
      'serviceId': _serviceId,
      'unitValue': int.parse(_unitValue),
      'quantity': int.parse(_quantity)
    };

    Response response = await ApiHelper.post(
      '/api/BillingDetails/',
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

    Navigator.pop(context, 'yes');
  }

  void _saveRecord() async {
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
      'id': widget.billingDetail.id,
      'billingId': widget.billing.id,
      'serviceId': _serviceId,
      'unitValue': int.parse(_unitValue),
      'quantity': int.parse(_quantity)
    };

    Response response = await ApiHelper.put(
      '/api/BillingDetails/',
      widget.billingDetail.id.toString(),
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

    Navigator.pop(context, 'yes');
  }
}