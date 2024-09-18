class NoiDenModel {
  String? id;
  String? noiDen;

  NoiDenModel({this.id, this.noiDen});
  factory NoiDenModel.fromJson(Map<String, dynamic> json) {
    return NoiDenModel(id: json["id"].toString(), noiDen: json["noiDen"]);
  }
}
