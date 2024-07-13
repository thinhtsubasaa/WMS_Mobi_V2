class LSX_NhapBaiModel {
  String? id;
  String? loaiXe;
  String? soKhung;
  String? mauXe;
  String? nguoiNhapBai;
  String? noiDen;
  String? noiNhap;
  String? gioNhan;
  LSX_NhapBaiModel(
      {this.id,
      this.loaiXe,
      this.soKhung,
      this.mauXe,
      this.gioNhan,
      this.noiDen,
      this.noiNhap,
      this.nguoiNhapBai});

  factory LSX_NhapBaiModel.fromJson(Map<String, dynamic> json) {
    return LSX_NhapBaiModel(
      id: json["id"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      mauXe: json["mauXe"],
      noiNhap: json["noiNhap"],
      nguoiNhapBai: json["nguoiNhapBai"],
      noiDen: json["noiDen"],
      gioNhan: json["gioNhan"],
    );
  }
}
