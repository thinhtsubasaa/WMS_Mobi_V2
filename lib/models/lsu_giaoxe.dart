class LSX_GiaoXeModel {
  String? id;

  String? soKhung;
  String? loaiXe;
  String? soMay;
  String? mauXe;
  String? yeuCau;
  String? noiGiao;
  String? bienSo;
  String? taiXe;
  String? gioNhan;
  String? nguoiPhuTrach;

  LSX_GiaoXeModel(
      {this.id,
      this.soKhung,
      this.soMay,
      this.mauXe,
      this.noiGiao,
      this.bienSo,
      this.taiXe,
      this.loaiXe,
      this.gioNhan,
      this.nguoiPhuTrach});
  factory LSX_GiaoXeModel.fromJson(Map<String, dynamic> json) {
    return LSX_GiaoXeModel(
      id: json["id"].toString(),
      soKhung: json["soKhung"],
      soMay: json["soMay"],
      mauXe: json["mauXe"],
      noiGiao: json["noiGiao"],
      gioNhan: json["gioNhan"],
      loaiXe: json["loaiXe"],
      nguoiPhuTrach: json["nguoiPhuTrach"],
    );
  }
}
