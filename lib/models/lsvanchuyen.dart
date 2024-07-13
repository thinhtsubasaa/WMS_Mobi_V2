class LSVanChuyenModel {
  String? id;
  String? ngay;
  String? loaiXe;
  String? soKhung;
  String? thongTinVanChuyen;
  String? thongTinChiTiet;
  String? nguoiVanChuyen;
  String? gioNhan;

  LSVanChuyenModel(
      {this.id,
      this.ngay,
      this.loaiXe,
      this.soKhung,
      this.thongTinVanChuyen,
      this.thongTinChiTiet,
      this.nguoiVanChuyen,
      this.gioNhan});
  factory LSVanChuyenModel.fromJson(Map<String, dynamic> json) {
    return LSVanChuyenModel(
      id: json["id"].toString(),
      ngay: json["ngay"],
      loaiXe: json["loaiXe"],
      soKhung: json["soKhung"],
      thongTinChiTiet: json["thongTinChiTiet"],
      thongTinVanChuyen: json["thongTinVanChuyen"],
      nguoiVanChuyen: json["nguoiVanChuyen"],
      gioNhan: json["gioNhan"],
    );
  }
}
