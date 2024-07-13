class DongSealModel {
  String? key;
  String? id;
  String? lat;
  String? long;
  String? soCont;
  String? soSeal;
  String? toaDo;
  String? soKhung;

  DongSealModel(
      {this.key,
      this.id,
      this.lat,
      this.long,
      this.soCont,
      this.soSeal,
      this.toaDo,
      this.soKhung});

  factory DongSealModel.fromJson(Map<String, dynamic> json) {
    return DongSealModel(
        key: json["key"],
        id: json["id"],
        soCont: json["soCont"],
        soSeal: json["soSeal"],
        lat: json["lat"],
        long: json["long"],
        toaDo: json["toaDo"],
        soKhung: json["soKhung"]);
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        "soCont": soCont,
        "soSeal": soSeal,
        "lat": lat,
        "long": long,
        "toaDo": toaDo,
        "soKhung": soKhung,
      };
}
