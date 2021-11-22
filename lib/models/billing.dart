import 'package:huellitas_app_flutter/models/billing_detail.dart';

class Billing {
  int id = 0;
  String date = '';
  String dateLocal = '';
  int totalValue = 0;
  List<BillingDetail> billingDetails = [];
  int billingDetailsCount = 0;

  Billing({
    required this.id,
    required this.date,
    required this.dateLocal,
    required this.totalValue,
    required this.billingDetails,
    required this.billingDetailsCount
  });

  Billing.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    dateLocal = json['dateLocal'];
    totalValue = json['totalValue'];
    if (json['billingDetails'] != null) {
      billingDetails = [];
      json['billingDetails'].forEach((v) {
        billingDetails.add(new BillingDetail.fromJson(v));
      });
    }
    billingDetailsCount = json['billingDetailsCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['dateLocal'] = this.dateLocal;
    data['totalValue'] = this.totalValue;
    data['billingDetails'] = this.billingDetails.map((v) => v.toJson()).toList();
    data['billingDetailsCount'] = this.billingDetailsCount;
    return data;
  }
}