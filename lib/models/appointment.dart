import 'package:huellitas_app_flutter/models/appointment_type.dart';

class Appointment {
  int id = 0;
  String date = '';
  AppointmentType appointmentType = AppointmentType(id: 0, description: '');

  Appointment({required this.id, required this.date, required this.appointmentType});

  Appointment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    appointmentType = AppointmentType.fromJson(json['appointmentType']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['date'] = this.date;
    data['appointmentType'] = this.appointmentType.toJson();
    return data;
  }
}