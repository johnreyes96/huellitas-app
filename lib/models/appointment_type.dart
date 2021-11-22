class AppointmentType {
  int id = 0;
  String description= '';

  AppointmentType({required this.id, required this.description});

  AppointmentType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['description'] = this.description;
    return data;
  }
}