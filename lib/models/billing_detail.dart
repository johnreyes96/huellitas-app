import 'package:huellitas_app_flutter/models/service.dart';
import 'package:huellitas_app_flutter/models/service_detail.dart';

class BillingDetail {
  int id = 0;
  Service service = Service(id: 0, description: '');
  int unitValue = 0;
  int quantity = 0;
  int valueSubtotal = 0;
  List<ServiceDetail> serviceDetails = [];

  BillingDetail({
    required this.id,
    required this.service,
    required this.unitValue,
    required this.quantity,
    required this.valueSubtotal,
    required this.serviceDetails
  });

  BillingDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    service = Service.fromJson(json['service']);
    unitValue = json['unitValue'];
    quantity = json['quantity'];
    valueSubtotal = json['valueSubtotal'];
    if (json['serviceDetails'] != null) {
      serviceDetails = [];
      json['serviceDetails'].forEach((v) {
        serviceDetails.add(new ServiceDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['service'] = this.service.toJson();
    data['unitValue'] = this.unitValue;
    data['quantity'] = this.quantity;
    data['valueSubtotal'] = this.valueSubtotal;
    data['serviceDetails'] = this.serviceDetails.map((v) => v.toJson()).toList();
    return data;
  }
}