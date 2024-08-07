import 'dart:async';
import 'dart:convert';

import 'package:Thilogi/blocs/dongcont_bloc.dart';
import 'package:Thilogi/models/dongcont.dart';
import 'package:Thilogi/pages/ds_dongcont/ds_dongcont.dart';
import 'package:Thilogi/pages/lsdieuchuyen/ls_dieuchuyen.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import 'package:http/http.dart' as http;
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as GeoLocationAccuracy;

import '../../config/config.dart';
import '../../models/dsxdongcont.dart';
import '../../services/app_service.dart';
import '../../widgets/loading.dart';

class CustomBodyXuatCongXe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyBaiXeScreen());
  }
}

class BodyBaiXeScreen extends StatefulWidget {
  const BodyBaiXeScreen({Key? key}) : super(key: key);

  @override
  _BodyBaiXeScreenState createState() => _BodyBaiXeScreenState();
}

class _BodyBaiXeScreenState extends State<BodyBaiXeScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  String? soContId;

  String? DanhSachPhuongTienId;

  List<DSX_DongContModel>? _dsxdongcontList;
  List<DSX_DongContModel>? get dsxdongcont => _dsxdongcontList;

  DongContModel? _data;
  DSX_DongContModel? _dc;
  bool _loading = false;
  String? barcodeScanResult;
  String? lat;
  String? long;
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _success = false;
  bool get success => _success;

  String? _message;
  String? get message => _message;
  bool _isMovingStarted = false;

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;

  late DongContBloc _bl;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<DongContBloc>(context, listen: false);
    getSoCont();
    requestLocationPermission();
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
    textEditingController.dispose();
    super.dispose();
  }

  void requestLocationPermission() async {
    // Kiểm tra quyền truy cập vị trí
    LocationPermission permission = await Geolocator.checkPermission();
    // Nếu chưa có quyền, yêu cầu quyền truy cập vị trí
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Yêu cầu quyền truy cập vị trí
      await Geolocator.requestPermission();
    }
  }

  void getSoCont() async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_DongCont/GetListContMobi');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _dsxdongcontList = (decodedData as List)
            .map((item) => DSX_DongContModel.fromJson(item))
            .toList();
        // Gọi setState để cập nhật giao diện
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> postData(DongContModel? scanData, String soContId,
      String soKhung, String toaDo) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData?.soKhung =
          newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData?.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/DongCont?SoContId=$soContId&SoKhung=$soKhung&ViTri=$toaDo',
          newScanData?.toJson());
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
          text: "Đóng cont thành công",
          confirmBtnText: 'Đồng ý',
        );
        _isMovingStarted = true;
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

  Future<void> HuyDongCont(
      DongContModel? scanData, String soKhung, String toaDo) async {
    _isLoading = true;
    try {
      var newScanData = scanData;
      newScanData?.soKhung =
          newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData?.soKhung}");
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/HuyDongCont?SoKhung=$soKhung&ViTri=$toaDo',
          newScanData?.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        print("data: ${decodedData}");

        notifyListeners();
        _btnController.success();
        setState(() {
          _loading = false;
        });
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: "Thành công",
          text: "Hủy đóng cont thành công ",
          confirmBtnText: 'Đồng ý',
        );
        _isMovingStarted = true;
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

  void _handleBarcodeScanResult(String barcodeScanResult) {
    print(barcodeScanResult);

    setState(() {
      _qrData = '';
      _qrDataController.text = barcodeScanResult;
      _data = null;
      Future.delayed(const Duration(seconds: 0), () {
        _qrData = barcodeScanResult;
        _qrDataController.text = barcodeScanResult;
        _onScan(barcodeScanResult);
      });
    });
  }

  _onScan(value) {
    setState(() {
      _loading = true;
    });
    _bl.getData(context, value).then((_) {
      setState(() {
        _qrData = value;
        if (_bl.dongcont == null) {
          _qrData = '';
          _qrDataController.text = '';
          barcodeScanResult = null;
        }
        _loading = false;
        _data = _bl.dongcont;
        print("Số cont: ${_data?.soCont}");
        if (_data?.soCont != null) {
          _isMovingStarted = true;
        } else {
          _isMovingStarted = false;
        }
      });
    });
  }

  _onSave() {
    setState(() {
      _loading = true;
    });

    _data?.key = _bl.dongcont?.key;
    _data?.id = _bl.dongcont?.id;
    _data?.soKhung = _bl.dongcont?.soKhung;
    _data?.tenSanPham = _bl.dongcont?.tenSanPham;
    _data?.maSanPham = _bl.dongcont?.maSanPham;
    _data?.soMay = _bl.dongcont?.soMay;
    _data?.maMau = _bl.dongcont?.maMau;
    _data?.tenMau = _bl.dongcont?.tenMau;
    _data?.tenKho = _bl.dongcont?.tenKho;
    _data?.maViTri = _bl.dongcont?.maViTri;
    _data?.tenViTri = _bl.dongcont?.tenViTri;
    _data?.mauSon = _bl.dongcont?.mauSon;
    _data?.ngayNhapKhoView = _bl.dongcont?.ngayNhapKhoView;
    _data?.maKho = _bl.dongcont?.maKho;
    _data?.soCont = _bl.dongcont?.soCont;

    _data?.soSeal = _bl.dongcont?.soSeal;

    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });

      _data?.toaDo = "${lat},${long}";

      print("viTri: ${_data?.toaDo}");
      print("soContId: ${soContId}");
      print("soKhung:${_data?.soKhung}");

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
          postData(_data!, soContId ?? "", _data?.soKhung ?? "",
                  _data?.toaDo ?? "")
              .then((_) {
            setState(() {
              _data = null;
              soContId = null;
              barcodeScanResult = null;
              _qrData = '';
              _qrDataController.text = '';
              _loading = false;
            });
          });
        }
      });
    }).catchError((error) {
      // Handle error while getting location
      print("Error getting location: $error");
    });
  }

  _onHuyDongCont() {
    setState(() {
      _loading = true;
    });

    _data?.key = _bl.dongcont?.key;
    _data?.id = _bl.dongcont?.id;
    _data?.soKhung = _bl.dongcont?.soKhung;
    _data?.tenSanPham = _bl.dongcont?.tenSanPham;
    _data?.maSanPham = _bl.dongcont?.maSanPham;
    _data?.soMay = _bl.dongcont?.soMay;
    _data?.maMau = _bl.dongcont?.maMau;
    _data?.tenMau = _bl.dongcont?.tenMau;
    _data?.tenKho = _bl.dongcont?.tenKho;
    _data?.maViTri = _bl.dongcont?.maViTri;
    _data?.tenViTri = _bl.dongcont?.tenViTri;
    _data?.mauSon = _bl.dongcont?.mauSon;
    _data?.ngayNhapKhoView = _bl.dongcont?.ngayNhapKhoView;
    _data?.maKho = _bl.dongcont?.maKho;
    _data?.soCont = _bl.dongcont?.soCont;

    _data?.soSeal = _bl.dongcont?.soSeal;

    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });

      _data?.toaDo = "${lat},${long}";

      print("viTri: ${_data?.toaDo}");
      print("soContId: ${soContId}");
      print("soKhung:${_data?.soKhung}");

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
          HuyDongCont(_data!, _data?.soKhung ?? "", _data?.toaDo ?? "")
              .then((_) {
            setState(() {
              _data = null;
              soContId = null;
              barcodeScanResult = null;
              _qrData = '';
              _qrDataController.text = '';
              _loading = false;
              _isMovingStarted = false;
            });
          });
        }
      });
    }).catchError((error) {
      // Handle error while getting location
      print("Error getting location: $error");
    });
  }

  void _showConfirmationDialogHuyDongCont(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn hủy xe này không?',
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
          _onHuyDongCont();
        });
  }

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn đóng cont không?',
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

  void _startMoving(BuildContext context) {
    _showConfirmationDialog(context); // Hiển thị hộp thoại xác nhận
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
                                      nextScreen(context, LSDaDongContPage());
                                    },
                                  ),
                                ],
                              ),
                              Divider(height: 1, color: Color(0xFFA71C20)),
                              SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!_isMovingStarted)
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height <
                                                  600
                                              ? 10.h
                                              : 7.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: const Color(0xFF818180),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 20.w,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF6C6C7),
                                              border: Border(
                                                right: BorderSide(
                                                  color: Color(0xFF818180),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Số Cont",
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  fontFamily: 'Comfortaa',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppConfig.textInput,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Container(
                                                  padding: EdgeInsets.only(
                                                      top:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .height <
                                                                  600
                                                              ? 0
                                                              : 5),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton2<String>(
                                                      isExpanded: true,
                                                      items: _dsxdongcontList
                                                          ?.map((item) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: item.id,
                                                          child: Container(
                                                            constraints: BoxConstraints(
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.9),
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Text(
                                                                item.soCont ??
                                                                    "",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily:
                                                                      'Comfortaa',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: AppConfig
                                                                      .textInput,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      value: soContId,
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          soContId = newValue;
                                                        });
                                                      },
                                                      buttonStyleData:
                                                          const ButtonStyleData(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 16),
                                                        height: 40,
                                                        width: 200,
                                                      ),
                                                      dropdownStyleData:
                                                          const DropdownStyleData(
                                                        maxHeight: 200,
                                                      ),
                                                      menuItemStyleData:
                                                          const MenuItemStyleData(
                                                        height: 40,
                                                      ),
                                                      dropdownSearchData:
                                                          DropdownSearchData(
                                                        searchController:
                                                            textEditingController,
                                                        searchInnerWidgetHeight:
                                                            50,
                                                        searchInnerWidget:
                                                            Container(
                                                          height: 50,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            top: 8,
                                                            bottom: 4,
                                                            right: 8,
                                                            left: 8,
                                                          ),
                                                          child: TextFormField(
                                                            expands: true,
                                                            maxLines: null,
                                                            controller:
                                                                textEditingController,
                                                            decoration:
                                                                InputDecoration(
                                                              isDense: true,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 10,
                                                                vertical: 8,
                                                              ),
                                                              hintText:
                                                                  'Tìm số cont',
                                                              hintStyle:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        searchMatchFn: (item,
                                                            searchValue) {
                                                          if (item
                                                              is DropdownMenuItem<
                                                                  String>) {
                                                            // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                            String itemId =
                                                                item.value ??
                                                                    "";
                                                            // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                            return _dsxdongcontList?.any((soCont) =>
                                                                    soCont.id ==
                                                                        itemId &&
                                                                    soCont.soCont
                                                                            ?.toLowerCase()
                                                                            .contains(searchValue.toLowerCase()) ==
                                                                        true) ??
                                                                false;
                                                          } else {
                                                            return false;
                                                          }
                                                        },
                                                      ),
                                                      onMenuStateChange:
                                                          (isOpen) {
                                                        if (!isOpen) {
                                                          textEditingController
                                                              .clear();
                                                        }
                                                      },
                                                    ),
                                                  ))),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
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
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
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
                            const Divider(height: 1, color: Color(0xFFCCCCCC)),
                            Item(
                              title: 'Số khung: ',
                              value: _data?.soKhung,
                            ),
                            const Divider(height: 1, color: Color(0xFFCCCCCC)),
                            Item(
                                title: 'Màu: ',
                                value: _data != null
                                    ? (_data?.tenMau != null &&
                                            _data?.maMau != null
                                        ? "${_data?.tenMau} (${_data?.maMau})"
                                        : "")
                                    : ""),
                            // value: _data != null
                            //     ? "${_data?.tenMau} (${_data?.maMau})"
                            //     : "",

                            const Divider(height: 1, color: Color(0xFFCCCCCC)),
                            Item(
                              title: 'Số máy: ',
                              value: _data?.soMay,
                            ),
                            const Divider(height: 1, color: Color(0xFFCCCCCC)),
                            Item(
                              title: 'Khu Vực: ',
                              value: _data?.khuVuc,
                            ),
                            const Divider(height: 1, color: Color(0xFFCCCCCC)),
                            if (_isMovingStarted)
                              Item(
                                title: 'Số cont: ',
                                value: _data?.soCont,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Container(
        //   width: 100.w,
        //   padding: const EdgeInsets.all(5),
        //   child: Row(
        //     mainAxisAlignment:
        //         MainAxisAlignment.spaceBetween, // Chia đều không gian
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Expanded(
        //           child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: _isMovingStarted ? Colors.green : Colors.red,
        //           shape: RoundedRectangleBorder(
        //             borderRadius:
        //                 BorderRadius.circular(35.0), // Đường viền cong
        //           ),
        //           minimumSize: Size(200, 50), // Kích thước tối thiểu của button
        //         ),
        //         onPressed: _isMovingStarted
        //             ? null // Không cho phép click khi đang di chuyển
        //             : (_data?.soKhung != null
        //                 ? () => _startMoving(context)
        //                 : null),
        //         child: _isMovingStarted
        //             ? Text(
        //                 'Đang đóng cont',
        //                 style: TextStyle(
        //                   fontFamily: 'Comfortaa',
        //                   fontWeight: FontWeight.w700,
        //                   fontSize: 15,
        //                 ),
        //               )
        //             : Text(
        //                 'Đóng cont',
        //                 style: TextStyle(
        //                   fontFamily: 'Comfortaa',
        //                   fontWeight: FontWeight.w700,
        //                   fontSize: 15,
        //                 ),
        //               ),
        //       )
        //           // child: RoundedLoadingButton(
        //           //   child: Text('Bắt đầu di chuyển',
        //           //       style: TextStyle(
        //           //         fontFamily: 'Comfortaa',
        //           //         color: AppConfig.textButton,
        //           //         fontWeight: FontWeight.w700,
        //           //         fontSize: 16,
        //           //       )),
        //           //   controller: _btnController,
        //           //   onPressed: _data?.soKhung != null
        //           //       ? () => _startMoving(context)
        //           //       : null,
        //           //   successColor: Colors.green, // Thiết lập màu khi thành công
        //           //   successIcon: Icons.check, // Icon hiển thị khi thành công
        //           //   width: 200,
        //           // ),

        //           ),
        //       const SizedBox(width: 4),
        //       if (_isMovingStarted == true) // Chỉnh lại width thay vì height
        //         Expanded(
        //           child: RoundedLoadingButton(
        //               child: Text('Hủy',
        //                   style: TextStyle(
        //                     fontFamily: 'Comfortaa',
        //                     color: AppConfig.textButton,
        //                     fontWeight: FontWeight.w700,
        //                     fontSize: 15,
        //                   )),
        //               controller: _btnController,
        //               onPressed: (_isMovingStarted == true)
        //                   ? () => _showConfirmationDialogHuyDongCont(
        //                         context,
        //                       )
        //                   : null),
        //         ),
        //     ],
        //   ),
        // ),
        if (_data?.soCont == null)
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
                  onPressed: soContId != null
                      ? () => _showConfirmationDialog(context)
                      : null,
                ),
              ],
            ),
          ),
        if (_data?.soCont != null)
          Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoundedLoadingButton(
                  child: Text('Hủy',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        color: AppConfig.textButton,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      )),
                  controller: _btnController,
                  onPressed: _data?.soCont != null
                      ? () => _showConfirmationDialogHuyDongCont(context)
                      : null,
                ),
              ],
            ),
          ),
      ],
    ));
  }
}

class MyInputWidget extends StatelessWidget {
  final String title;
  final String text;
  final TextStyle textStyle;

  const MyInputWidget({
    Key? key,
    required this.title,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            decoration: const BoxDecoration(
              color: Color(0xFFF6C6C7),
              border: Border(
                right: BorderSide(
                  color: Color(0xFF818180),
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppConfig.textInput,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(top: 5, left: 15.sp),
              child: Text(
                text,
                style: textStyle,
              ),
            ),
          ),
        ],
      ),
    );
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
      height: 9.h,
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 15,
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
