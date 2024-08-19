import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/models/giaoxe.dart';
import 'package:Thilogi/models/xeracong.dart';
import 'package:Thilogi/pages/dsgiaoxe/ds_giaoxe.dart';
import 'package:Thilogi/pages/lsuxeracong/ls_racong.dart';
import 'package:Thilogi/pages/lsx_giaoxe/lsx_giaoxe.dart';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as GeoLocationAccuracy;
import 'package:http/http.dart' as http;

import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/giaoxe_bloc.dart';
import '../../blocs/scan_nhanvien_bloc.dart';
import '../../config/config.dart';
import '../../models/diadiem.dart';
import '../../models/phuongthucvanchuyen.dart';
import '../../services/app_service.dart';
import '../../utils/next_screen.dart';
import '../../widgets/checksheet_upload_anh.dart';
import '../../widgets/loading.dart';
import 'package:Thilogi/models/nhanvien.dart';

class CustomBodyXeRaCong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyXeRaCongScreen());
  }
}

class BodyXeRaCongScreen extends StatefulWidget {
  const BodyXeRaCongScreen({Key? key}) : super(key: key);

  @override
  _BodyXeRaCongScreenState createState() => _BodyXeRaCongScreenState();
}

class _BodyXeRaCongScreenState extends State<BodyXeRaCongScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String? lat;
  String? long;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  XeRaCongModel? _data;
  NhanVienModel? _model;
  XeRaCongModel? _xeracong;
  XeRaCongModel? get xeracong => _xeracong;
  bool _loading = false;
  String? barcodeScanResult;
  String? viTri;

  late XeRaCongBloc _bl;
  late Scan_NhanVienBloc ub;
  File? _selectImage;
  List<File> _selectedImages = [];
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  bool _isFirstScanCompleted = false;

  String? _message;
  String? get message => _message;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  NhanVienModel? _nhanvien;
  NhanVienModel? get nhanvien => _nhanvien;

  bool _success = false;
  bool get success => _success;

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<XeRaCongBloc>(context, listen: false);
    ub = Provider.of<Scan_NhanVienBloc>(context, listen: false);

    dataWedge = FlutterDataWedge(profileName: "Example Profile");
    scanSubscription = dataWedge.onScanResult.listen((ScanResult result) {
      setState(() {
        barcodeScanResult = result.data;
      });
      print(barcodeScanResult);
      _handleBarcodeScanResult(barcodeScanResult ?? "");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> postData(XeRaCongModel scanData, String? nhanvien) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung =
          newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/XeRaCong?MaNhanVien=$nhanvien', newScanData.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");

        notifyListeners();
        _btnController.success();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: "Xe ra cổng thành công",
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        _btnController.error();
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _btnController.reset();
      }
    } catch (e) {
      _message = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Widget CardVin() {
    return Container(
      width: MediaQuery.of(context).size.width < 330 ? 100.w : 90.w,
      // height: 11.h,
      height: MediaQuery.of(context).size.height < 880 ? 11.h : 8.h,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 20.w,
            height: 11.h,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              color: AppConfig.primaryColor,
            ),
            child: Center(
              child: Text(
                'Số khung\n(VIN)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: _qrDataController,
                decoration: InputDecoration(
                  hintText: 'Nhập hoặc quét mã VIN',
                ),
                onSubmitted: (value) {
                  _handleBarcodeScanResult(value);
                },
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.primaryColor,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            color: Colors.black,
            onPressed: () async {
              String result = await FlutterBarcodeScanner.scanBarcode(
                '#A71C20',
                'Cancel',
                false,
                ScanMode.QR,
              );
              setState(() {
                barcodeScanResult = result;
                _qrDataController.text = result;
              });
              print(barcodeScanResult);
              _handleBarcodeScanResult(barcodeScanResult ?? "");
            },
          ),
        ],
      ),
    );
  }

  Future<void> getData(BuildContext context, String qrcode) async {
    _isLoading = true;
    _xeracong = null;
    try {
      final http.Response response = await requestHelper
          .getData('KhoThanhPham/GetThongTinXeRaCong?SoKhung=$qrcode');
      print(response.statusCode);
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          _xeracong = XeRaCongModel(
            key: decodedData["key"],
            id: decodedData['id'],
            soKhung: decodedData['soKhung'],
            maSanPham: decodedData['maSanPham'],
            tenSanPham: decodedData['tenSanPham'],
            soMay: decodedData['soMay'],
            maMau: decodedData['maMau'],
            tenMau: decodedData['tenMau'],
            tenKho: decodedData['tenKho'],
            maViTri: decodedData['maViTri'],
            tenViTri: decodedData['tenViTri'],
            mauSon: decodedData['mauSon'],
            ngayNhapKhoView: decodedData['ngayNhapKhoView'],
            tenTaiXe: decodedData['tenTaiXe'],
            ghiChu: decodedData['ghiChu'],
            maKho: decodedData['maKho'],
            kho_Id: decodedData['kho_Id'],
            bienSo_Id: decodedData['bienSo_Id'],
            taiXe_Id: decodedData['taiXe_Id'],
            tenDiaDiem: decodedData['tenDiaDiem'],
            tenPhuongThucVanChuyen: decodedData['tenPhuongThucVanChuyen'],
            tenLoaiPhuongTien: decodedData['tenLoaiPhuongTien'],
            tenPhuongTien: decodedData['tenPhuongTien'],
            toaDo: decodedData['toaDo'],
            noidi: decodedData['noidi'],
            noiden: decodedData['noiden'],
            benVanChuyen: decodedData['benVanChuyen'],
            soXe: decodedData['soXe'],
            maSoNhanVien: decodedData['maSoNhanVien'],
            nguoiPhuTrach: decodedData['nguoiPhuTrach'],
          );
          setState(() {
            _isFirstScanCompleted = true;
          });
        }
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();

        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );

        _isFirstScanCompleted = false;

        _xeracong = null;
        _isLoading = false;
      }

      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future<void> getDataNV(BuildContext context, String soKhung) async {
    _isLoading = true;
    _nhanvien = null;
    try {
      final http.Response response = await requestHelper
          .getData('Account/thongtincbnv?plainText=$soKhung');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        if (decodedData != null) {
          var data = decodedData['result'];
          var vaocong = decodedData['isVaoCong'];
          _nhanvien = NhanVienModel(
            id: data['id'],
            email: data['email'],
            tenNhanVien: data['tenNhanVien'],
            mustChangePass: data['mustChangePass'],
            token: data['token'],
            hinhAnh_Url: data['hinhAnh_Url'],
            maNhanVien: data['maNhanVien'],
            tenPhongBan: data['tenPhongBan'],
            isVaoCong: vaocong,
          );
          setState(() {
            _isFirstScanCompleted = false;
          });
        }
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        if (errorMessage.isEmpty) {
          errorMessage = "Không có thông tin CBNV";
        }

        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.info,
          title: '',
          text: errorMessage,
          confirmBtnText: 'Đồng ý',
        );
        _nhanvien = null;
        _isLoading = false;
      }

      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  void _handleBarcodeScanResult(String barcodeScanResult) {
    print(barcodeScanResult);

    setState(() {
      _qrData = '';
      _qrDataController.text = barcodeScanResult;
      _data = null;
      Future.delayed(const Duration(seconds: 1), () {
        _qrData = barcodeScanResult;
        _qrDataController.text = barcodeScanResult;
        if (!_isFirstScanCompleted) {
          _onScan(barcodeScanResult);
        } else {
          _data = xeracong;
          _onScanNhanVien(barcodeScanResult);
        }

        // _onScan(barcodeScanResult);
      });
    });
  }

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    getData(context, value).then((_) {
      setState(() {
        _qrData = value;
        if (xeracong == null) {
          barcodeScanResult = null;
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _data = xeracong;
      });
    });
  }

  _onScanNhanVien(value) {
    setState(() {
      _loading = true;
    });
    getDataNV(context, value).then((_) {
      setState(() {
        _qrData = value;
        if (nhanvien == null) {
          barcodeScanResult = null;
          _qrData = '';
          _qrDataController.text = '';
        }
        _loading = false;
        _model = nhanvien;
        // setState(() {
        //   _isFirstScanCompleted = false;
        // });
      });
    });
  }

  _onSave() {
    setState(() {
      _loading = true;
    });

    _data?.key = xeracong?.key;
    _data?.id = xeracong?.id;
    _data?.soKhung = xeracong?.soKhung;
    _data?.tenSanPham = xeracong?.tenSanPham;
    _data?.maSanPham = xeracong?.maSanPham;
    _data?.soMay = xeracong?.soMay;
    _data?.maMau = xeracong?.maMau;
    _data?.tenMau = xeracong?.tenMau;
    _data?.tenKho = xeracong?.tenKho;
    _data?.maViTri = xeracong?.maViTri;
    _data?.tenViTri = xeracong?.tenViTri;
    _data?.mauSon = xeracong?.mauSon;
    _data?.ngayNhapKhoView = xeracong?.ngayNhapKhoView;
    _data?.maKho = xeracong?.maKho;
    _data?.kho_Id = xeracong?.kho_Id;
    _data?.noidi = xeracong?.noidi;
    _data?.noiden = xeracong?.noiden;

    _data?.bienSo_Id = xeracong?.bienSo_Id;
    _data?.taiXe_Id = xeracong?.taiXe_Id;
    _data?.tenDiaDiem = xeracong?.tenDiaDiem;
    _data?.tenPhuongThucVanChuyen = xeracong?.tenPhuongThucVanChuyen;

    print("nhân viên: ${_model?.maNhanVien}");

    AppService().checkInternet().then((hasInternet) {
      if (!hasInternet!) {
        // openSnackBar(context, 'no internet'.tr());
        QuickAlert.show(
          // ignore: use_build_context_synchronously
          context: context,
          type: QuickAlertType.error,
          title: 'Thất bại',
          text: 'Không có kết nối internet. Vui lòng kiểm tra lại',
          confirmBtnText: 'Đồng ý',
        );
      } else {
        postData(_data!, _model?.maNhanVien ?? "").then((_) {
          setState(() {
            _data = null;
            _model = null;
            barcodeScanResult = null;
            _qrData = '';
            _qrDataController.text = '';
            _loading = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn xác nhận xe ra cổng không?',
        title: '',
        confirmBtnText: 'Đồng ý',
        cancelBtnText: 'Không',
        confirmBtnTextStyle: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
        cancelBtnTextStyle: TextStyle(
          color: Colors.red,
          fontSize: 19.0,
          fontWeight: FontWeight.bold,
        ),
        onCancelBtnTap: () {
          Navigator.of(context).pop();
          _btnController.reset();
        },
        onConfirmBtnTap: () {
          Navigator.of(context).pop();
          _onSave();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        CardVin(),
        const SizedBox(height: 5),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _loading
                      ? LoadingWidget(context)
                      : Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Thông Tin Xác Nhận',
                                    style: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () {
                                      // Hành động khi nhấn vào icon
                                      nextScreen(context, LSRaCongPage());
                                      // Điều hướng đến trang lịch sử hoặc thực hiện hành động khác
                                    },
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 1,
                                color: AppConfig.primaryColor,
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 7.h,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              'Loại xe: ',
                                              style: TextStyle(
                                                fontFamily: 'Comfortaa',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF818180),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.70),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                _data?.tenSanPham ?? '',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontFamily: 'Coda Caption',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppConfig.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Số khung: ',
                                      value: _data?.soKhung,
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                        title: 'Màu: ',
                                        // value: _data != null
                                        //     ? "${_data?.tenMau} (${_data?.maMau})"
                                        //     : "",
                                        value: _data != null
                                            ? (_data?.tenMau != null &&
                                                    _data?.maMau != null
                                                ? "${_data?.tenMau} (${_data?.maMau})"
                                                : "")
                                            : ""),
                                    const Divider(
                                        height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Số máy: ',
                                      value: _data?.soMay,
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Phương thức vận chuyển: ',
                                      value: _data?.tenPhuongThucVanChuyen,
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Nơi đi: ',
                                      value: _data?.noidi,
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Nơi đến: ',
                                      value: _data?.noiden,
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFCCCCCC)),
                                    Item(
                                      title: 'Tài xế: ',
                                      value: _model?.tenNhanVien,
                                    ),
                                    const Divider(
                                        height: 1, color: Color(0xFFCCCCCC)),
                                    CheckSheetUploadAnh(
                                      lstFiles: [],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundedLoadingButton(
                child: Text('Xác nhận',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      color: AppConfig.textButton,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    )),
                controller: _btnController,
                onPressed: _data?.soKhung != null
                    ? () => _showConfirmationDialog(context)
                    : null,
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

class Item extends StatelessWidget {
  final String title;
  final String? value;

  const Item({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF818180),
              ),
            ),
            Text(
              value ?? "",
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppConfig.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
