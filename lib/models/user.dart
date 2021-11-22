import 'package:huellitas_app_flutter/models/appointment.dart';
import 'package:huellitas_app_flutter/models/pet.dart';

import 'document_type.dart';

class User {
  String firstName = '';
  String lastName = '';
  DocumentType documentType = DocumentType(id: 0, description: '');
  String document = '';
  String address = '';
  String imageId = '';
  String imageFullPath = '';
  int userType = 0;
  String fullName = '';
  List<Pet> pets = [];
  int petsCount = 0;
  List<Appointment> appointments = [];
  String id = '';
  String userName = '';
  String email = '';
  String phoneNumber = '';

  User({
    required this.firstName,
    required this.lastName,
    required this.documentType,
    required this.document,
    required this.address,
    required this.imageId,
    required this.imageFullPath,
    required this.userType,
    required this.fullName,
    required this.pets,
    required this.petsCount,
    required this.appointments,
    required this.id,
    required this.userName,
    required this.email,
    required this.phoneNumber,
  });

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    documentType = DocumentType.fromJson(json['documentType']);
    document = json['document'];
    address = json['address'];
    imageId = json['imageId'];
    imageFullPath = json['imageFullPath'];
    userType = json['userType'];
    fullName = json['fullName'];
    if (json['pets'] != null) {
      pets = [];
      json['pets'].forEach((v) {
        pets.add(new Pet.fromJson(v));
      });
    }
    if (json['appointments'] != null) {
      appointments = [];
      json['appointments'].forEach((v) {
        appointments.add(new Appointment.fromJson(v));
      });
    }
    petsCount = json['petsCount'];
    id = json['id'];
    userName = json['userName'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['documentType'] = this.documentType.toJson();
    data['document'] = this.document;
    data['address'] = this.address;
    data['imageId'] = this.imageId;
    data['imageFullPath'] = this.imageFullPath;
    data['userType'] = this.userType;
    data['fullName'] = this.fullName;
    data['pets'] = this.pets.map((v) => v.toJson()).toList();
    data['petsCount'] = this.petsCount;
    data['appointments'] = this.appointments.map((v) => v.toJson()).toList();
    data['id'] = this.id;
    data['userName'] = this.userName;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}