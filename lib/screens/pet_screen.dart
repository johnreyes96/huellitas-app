import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:huellitas_app_flutter/helpers/api_helper.dart';
import 'package:huellitas_app_flutter/models/pet_type.dart';
import 'package:image_picker/image_picker.dart';

import 'package:huellitas_app_flutter/components/loader_component.dart';
import 'package:huellitas_app_flutter/models/pet.dart';
import 'package:huellitas_app_flutter/models/response.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/models/user.dart';
import 'package:huellitas_app_flutter/screens/take_picture_screen.dart';

class PetScreen extends StatefulWidget {
  final Token token;
  final User user;
  final Pet pet;

  // ignore: use_key_in_widget_constructors
  const PetScreen({required this.token, required this.user, required this.pet});

  @override
  _PetScreenState createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  bool _showLoader = false;
  bool _photoChanged = false;
  late XFile _image;
  int _current = 0;
  CarouselController _carouselController = CarouselController();

  int _petTypeId = 0;
  String _petTypeIdError = '';
  bool _petTypeIdShowError = false;
  List<PetType> _petTypes = [];

  String _name = '';
  String _nameError = '';
  bool _nameShowError = false;
  TextEditingController _nameController = TextEditingController();

  String _race = '';
  String _raceError = '';
  bool _raceShowError = false;
  TextEditingController _raceController = TextEditingController();

  String _color = '';
  String _colorError = '';
  bool _colorShowError = false;
  TextEditingController _colorController = TextEditingController();

  String _observations = '';
  String _observationsError = '';
  bool _observationsShowError = false;
  TextEditingController _observationsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF004489),
        title: Text(
          widget.pet.id == 0
            ? 'Nueva mascota' 
            : '${widget.pet.name} ${widget.pet.race}'
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _showPhoto(),
                _showPetType(),
                _showName(),
                _showRace(),
                _showColor(),
                _showObservations(),
                _showButtons(),
              ],
            ),
          ),
          _showLoader ? const LoaderComponent(text: 'Por favor espere...',) : Container(),
        ],
      ),
    );
  }

  void _loadData() async {
    await _getPetTypes();
    _loadFieldValues();
  }

  Widget _showPhoto() {
    return widget.pet.id == 0
    ? _showUniquePhoto()
    : _showPhotosCarousel();
  }

  Widget _showPetType() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: _petTypes.isEmpty 
        ? const Text('Cargando tipos de mascota...')
        : DropdownButtonFormField(
            items: _getComboPetTypes(),
            value: _petTypeId,
            onChanged: (option) {
              setState(() {
                _petTypeId = option as int;
              });
            },
            decoration: InputDecoration(
              hintText: 'Seleccione un tipo de mascota...',
              labelText: 'Tipo mascota',
              errorText: _petTypeIdShowError ? _petTypeIdError : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          )
    );
  }

  Widget _showName() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          hintText: 'Ingresa nombre...',
          labelText: 'Nombre',
          errorText: _nameShowError ? _nameError : null,
          suffixIcon: const Icon(Icons.pets),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _name = value;
        },
      ),
    );
  }

  _showRace() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _raceController,
        decoration: InputDecoration(
          hintText: 'Ingresa raza...',
          labelText: 'Raza',
          errorText: _raceShowError ? _raceError : null,
          suffixIcon: const Icon(Icons.pets),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _race = value;
        },
      ),
    );
  }

  Widget _showColor() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _colorController,
        decoration: InputDecoration(
          hintText: 'Ingresa Color...',
          labelText: 'Color',
          errorText: _colorShowError ? _colorError : null,
          suffixIcon: const Icon(Icons.palette),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _color = value;
        },
      ),
    );
  }

  Widget _showObservations() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _observationsController,
        decoration: InputDecoration(
          hintText: 'Ingresa observaciones...',
          labelText: 'Observaciones',
          errorText: _observationsShowError ? _observationsError : null,
          suffixIcon: const Icon(Icons.notes),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
        ),
        onChanged: (value) {
          _observations = value;
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
          widget.pet.id == 0
            ? Container()
            : const SizedBox(width: 20,),
          widget.pet.id == 0
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

  Widget _showUniquePhoto() {
    return Stack(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: widget.pet.id == 0 && !_photoChanged
            ? const Image(
                image: AssetImage('assets/no_image.png'),
                height: 160,
                width: 160,
                fit: BoxFit.cover,
              ) 
            : ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: _photoChanged 
                ? Image.file(
                    File(_image.path),
                    height: 160,
                    width: 160,
                    fit: BoxFit.cover,
                  ) 
                : CachedNetworkImage(
                    imageUrl: widget.pet.imageFullPath,
                    errorWidget: (context, url, err) => const Icon(Icons.error),
                    fit: BoxFit.cover,
                    height: 160,
                    width: 160,
                    placeholder: (context, url) => const Image(
                      image: AssetImage('assets/huellitas_logo.png'),
                      fit: BoxFit.cover,
                      height: 160,
                      width: 160,
                    )
                  ),
              ),        
        ),
        Positioned(
          bottom: 0,
          left: 100,
          child: InkWell(
            onTap: () => _takePicture(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.green[50],
                height: 60,
                width: 60,
                child: const Icon(
                  Icons.photo_camera,
                  size: 40,
                  color: Color(0xFF004489)
                )
              )
            ),
          )
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: InkWell(
            onTap: () => _selectPicture(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                color: Colors.green[50],
                height: 60,
                width: 60,
                child: const Icon(
                  Icons.image,
                  size: 40,
                  color: Color(0xFF004489)
                )
              )
            ),
          )
        )
      ] 
    );
  }

  Widget _showPhotosCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 3),
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _current = index;
                });
              }
            ),
            carouselController: _carouselController,
            items: widget.pet.petPhotos.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: i.imageFullPath,
                        errorWidget: (context, url, err) => const Icon(Icons.error),
                        fit: BoxFit.cover,
                        height: 300,
                        width: 300,
                        placeholder: (context, url) => const Image(
                          image: AssetImage('assets/huellitas_logo.png'),
                          fit: BoxFit.cover,
                          height: 300,
                          width: 300,
                        )
                      ),
                    )
                  );
                },
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.pet.petPhotos.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => _carouselController.animateToPage(entry.key),
                child: Container(
                  width: 12.0,
                  height: 12.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black)
                          .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                ),
              );
            }).toList(),
          ),
          _showImageButtons() 
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    var camera = cameras.first;
    var responseCamera = await showAlertDialog(
        context: context,
        title: 'Seleccionar cámara',
        message: '¿Qué cámara desea utilizar?',
        actions: <AlertDialogAction>[
          const AlertDialogAction(key: 'front', label: 'Delantera'),
          const AlertDialogAction(key: 'back', label: 'Trasera'),
          const AlertDialogAction(key: 'cancel', label: 'Cancelar'),
        ]);

    if (responseCamera == 'cancel') {
      return;
    }

    if (responseCamera == 'back') {
      camera = cameras.first;
    }

    if (responseCamera == 'front') {
      camera = cameras.last;
    }

    Response? response = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePictureScreen(camera: camera)));
    if (response != null) {
      setState(() {
        _photoChanged = true;
        _image = response.result;
      });
    }
  }

  Future<void> _selectPicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoChanged = true;
        _image = image;
      });
    }
  }

  Widget _showImageButtons() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const <Widget>[
                  Icon(Icons.add_a_photo),
                  Text('Adicionar Foto'),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return const Color(0xFF120E43);
                  }
                ),
              ),
              onPressed: () => _goAddPhoto(), 
            ),
          ),
          const SizedBox(width: 20,),
          Expanded(
            child: ElevatedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const <Widget>[
                  Icon(Icons.delete),
                  Text('Eliminar Foto'),
                ],
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    return const Color(0xFFB4161B);
                  }
                ),
              ),
              onPressed: () => _confirmDeletePhoto(), 
            ),
          ),
        ],
      ),
    );
  }

  _goAddPhoto() {}

  _confirmDeletePhoto() {}

  List<DropdownMenuItem<int>> _getComboPetTypes() {
    List<DropdownMenuItem<int>> list = [];

    list.add(const DropdownMenuItem(
      child: Text('Seleccione un tipo de mascota...'),
      value: 0,
    ));

    for (var petType in _petTypes) { 
      list.add(DropdownMenuItem(
        child: Text(petType.description),
        value: petType.id,
      ));
    }

    return list;
  }

  Future<void> _getPetTypes() async {
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

    Response response = await ApiHelper.getPetTypes(widget.token);

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
      _petTypes = response.result;
    });
  }

  void _loadFieldValues() {
    _petTypeId = widget.pet.petType.id;
  }

  void _save() {
    if (!_validateFields()) {
      return;
    }

    widget.pet.id == 0 ? _addRecord() : _saveRecord();
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
      '/api/Pets/',
      widget.pet.id.toString(),
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
    
    if (_petTypeId == 0) {
      isValid = false;
      _petTypeIdShowError = true;
      _petTypeIdError = 'Debes seleccionar un tipo de mascota.';
    } else {
      _petTypeIdShowError = false;
    }

    if (_name.isEmpty) {
      isValid = false;
      _nameShowError = true;
      _nameError = 'Debes ingresar un nombre.';
    } else {
      _nameShowError = false;
    }

    if (_race.isEmpty) {
      isValid = false;
      _raceShowError = true;
      _raceError = 'Debes ingresar una raza.';
    } else {
      _raceShowError = false;
    }

    if (_color.isEmpty) {
      isValid = false;
      _colorShowError = true;
      _colorError = 'Debes ingresar un color.';
    } else {
      _colorShowError = false;
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

    String base64Image = '';
    if (_photoChanged) {
      List<int> imageBytes = await _image.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    Map<String, dynamic> request = {
      'vehicleTypeId': _petTypeId,
      'name': _name,
      'race': _race,
      'color': _color,
      'userId': widget.user.id,
      'observations': _observations,
      'image': base64Image,
    };

    Response response = await ApiHelper.post(
      '/api/Pets/',
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

    String base64Image = '';
    if (_photoChanged) {
      List<int> imageBytes = await _image.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    Map<String, dynamic> request = {
      'id': widget.pet.id,
      'vehicleTypeId': _petTypeId,
      'name': _name,
      'race': _race,
      'color': _color,
      'userId': widget.user.id,
      'observations': _observations,
      'image': base64Image,
    };

    Response response = await ApiHelper.put(
      '/api/Pets/',
      widget.pet.id.toString(),
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