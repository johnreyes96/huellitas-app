import 'package:huellitas_app_flutter/models/billing.dart';
import 'package:huellitas_app_flutter/models/pet_photo.dart';
import 'package:huellitas_app_flutter/models/pet_type.dart';

class Pet {
  int id = 0;
  PetType petType = PetType(id: 0, description: '');
  String name = '';
  String race = '';
  String color = '';
  String? observations = '';
  int petPhotosCount = 0;
  List<PetPhoto> petPhotos = [];
  String imageFullPath = '';
  List<Billing> billings = [];
  int billingsCount = 0;

  Pet({
    required this.id,
    required this.petType,
    required this.name,
    required this.race,
    required this.color,
    required this.observations,
    required this.petPhotosCount,
    required this.petPhotos,
    required this.imageFullPath,
    required this.billings,
    required this.billingsCount
  });

  Pet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    petType = new PetType.fromJson(json['petType']);
    name = json['name'];
    race = json['race'];
    color = json['color'];
    observations = json['observations'];
    petPhotosCount = json['petPhotosCount'];
    if (json['petPhotos'] != null) {
      petPhotos = [];
      json['petPhotos'].forEach((v) {
        petPhotos.add(new PetPhoto.fromJson(v));
      });
    }
    imageFullPath = json['imageFullPath'];
    if (json['billings'] != null) {
      billings = [];
      json['billings'].forEach((v) {
        billings.add(new Billing.fromJson(v));
      });
    }
    billingsCount = json['billingsCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['petType'] = this.petType.toJson();
    data['name'] = this.name;
    data['race'] = this.race;
    data['color'] = this.color;
    data['observations'] = this.observations;
    data['petPhotosCount'] = this.petPhotosCount;
    data['petPhotos'] = this.petPhotos.map((v) => v.toJson()).toList();
    data['imageFullPath'] = this.imageFullPath;
    data['billings'] = this.billings.map((v) => v.toJson()).toList();
    data['billingsCount'] = this.billingsCount;
    return data;
  }
}