class DS_DongContModel {
  String? key;
  String? id;
  String? soCont;
  String? soSeal;
  String? loaiXe;
  String? soKhung;
  String? viTri;

  DS_DongContModel(
      {this.key,
      this.id,
      this.soCont,
      this.soSeal,
      this.loaiXe,
      this.soKhung,
      this.viTri});

  factory DS_DongContModel.fromJson(Map<String, dynamic> json) {
    return DS_DongContModel(
      key: json["key"],
      id: json["id"],
      soCont: json["soCont"],
      soSeal: json["soSeal"],
      viTri: json["viTri"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
    );
  }
  Map<String, dynamic> toJson() => {
        'key': key,
        'id': id,
        "soCont": soCont,
        "soSeal": soSeal,
        "viTri": viTri,
        "loaiXe": loaiXe,
        "soKhung": soKhung,
      };
}
