import 'dart:async';
import 'dart:convert';
import 'package:Thilogi/pages/ds_dongcont/ds_dongcont.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:Thilogi/widgets/checksheet_upload_anh.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as GeoLocationAccuracy;

import '../../blocs/dongseal_bloc.dart';
import '../../config/config.dart';
import '../../models/danhsachphuongtien.dart';
import '../../models/dongseal.dart';
import '../../models/dsdongcont.dart';
import '../../models/dsxdongcont.dart';

import '../../services/app_service.dart';
import '../../widgets/loading.dart';

class CustomBodyDongSealXe extends StatelessWidget {
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
  String? SoContId;
  final _qrDataController = TextEditingController();
  String? soCont;
  String? TauId;
  String? viTri;
  final TextEditingController _soSeal = TextEditingController();

  List<DSX_DongContModel>? _dsxdongcontList;
  List<DSX_DongContModel>? get dsxdongcont => _dsxdongcontList;
  List<DS_DongContModel>? _dsdongcontList;
  List<DS_DongContModel>? get dsdongcont => _dsdongcontList;

  List<DanhSachPhuongTienModel>? _danhsachphuongtientauList;
  List<DanhSachPhuongTienModel>? get danhsachphuongtientauList =>
      _danhsachphuongtientauList;

  DongSealModel? _data;
  bool _loading = false;
  String? lat;
  String? long;
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;

  late DongSealBloc _bl;
  Map<String, String> _soContIdMap = {};

  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bl = Provider.of<DongSealBloc>(context, listen: false);
    // getDSXChoXuat();
    requestLocationPermission();
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

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getDongCont(String SoContId) async {
    try {
      final http.Response response =
          await requestHelper.getData('DSX_DongCont/Mobi?SoCont_Id=$SoContId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _dsdongcontList = (decodedData as List)
            .map((item) => DS_DongContModel.fromJson(item))
            .toList();

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getDanhSachPhuongTienTauList() async {
    try {
      final http.Response response =
          await requestHelper.getData('TMS_DanhSachPhuongTien/Tau');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _danhsachphuongtientauList = (decodedData as List)
            .map((item) => DanhSachPhuongTienModel.fromJson(item))
            .toList();

        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> postData(
      String soSeal, String viTri, String soCont, String TauId) async {
    _isLoading = true;

    try {
      final http.Response response = await requestHelper.postData(
          'KhoThanhPham/DongSeal?SoSeal=$soSeal&ViTri=$viTri&SoCont=$soCont&TauId=$TauId',
          _data?.toJson());
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
          text: "Đóng seal thành công",
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

  _onSave() {
    setState(() {
      _loading = true;
    });

    Geolocator.getCurrentPosition(
      desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
    ).then((position) {
      setState(() {
        lat = "${position.latitude}";
        long = "${position.longitude}";
      });

      viTri = "${lat},${long}";
      _data?.soSeal = _soSeal.text;

      print("viTri: ${viTri}");
      print("soSeal:${_soSeal.text}");
      print("soCont:${soCont}");
      print("TauId: ${TauId}");
      print("SoContId:${SoContId}");

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
          postData(_soSeal.text, viTri ?? "", soCont ?? "", TauId ?? "")
              .then((_) {
            setState(() {
              soCont = null;
              _soSeal.text = '';
              TauId = null;
              _dsdongcontList = null;
              _data = null;
              _qrData = '';
              _qrDataController.text = '';
              _loading = false;
            });
          });
        }
      });
    }).catchError((error) {
      print("Error getting location: $error");
    });
  }

  void _showConfirmationDialog(BuildContext context) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: 'Bạn có muốn đóng seal không?',
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

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự
    return Container(
      width: 100.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách xe : ${_dsdongcontList?.length.toString() ?? ''}',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Table(
            border: TableBorder.all(),
            columnWidths: {
              0: FlexColumnWidth(0.5),
              1: FlexColumnWidth(0.5),
            },
            children: [
              TableRow(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.red,
                    child: _buildTableCell('Loại Xe', textColor: Colors.white),
                  ),
                  Container(
                    color: Colors.red,
                    child: _buildTableCell('Số Khung', textColor: Colors.white),
                  ),
                ],
              ),
              ..._dsdongcontList?.map((item) {
                    index++; // Tăng số thứ tự sau mỗi lần lặp

                    return TableRow(
                      children: [
                        // _buildTableCell(index.toString()), // Số thứ tự
                        _buildTableCell(item.loaiXe ?? ""),
                        _buildTableCell(item.soKhung ?? ""),
                      ],
                    );
                  }).toList() ??
                  [],
              // TableRow(
              //   children: [
              //     _buildTableCell('Tổng số', textColor: Colors.red),
              //     _buildTableCell(_dsdongcontList?.length.toString() ?? ''),
              //   ],
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String content, {Color textColor = Colors.black}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        content,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getSoCont();
    getDanhSachPhuongTienTauList();
    _dsxdongcontList?.forEach((item) {
      _soContIdMap[item.soCont ?? ""] =
          item.id ?? ""; // Thêm cặp giá trị vào Map
    });

    return Container(
        child: Column(
      children: [
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
                          margin: EdgeInsets.only(top: 20),
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
                                  Container(
                                    height:
                                        MediaQuery.of(context).size.height < 600
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
                                                    top: MediaQuery.of(context)
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
                                                    // items: _dsxdongcontList
                                                    //     ?.map((item) {

                                                    items: _soContIdMap.keys
                                                        .map((String soCont) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: soCont,
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
                                                              soCont ?? "",
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
                                                    value: soCont,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        soCont = newValue;
                                                        SoContId = _soContIdMap[
                                                            newValue];
                                                      });
                                                      if (newValue != null) {
                                                        getDongCont(
                                                            SoContId ?? "");
                                                        print(
                                                            "object : ${SoContId}");
                                                      }
                                                    },
                                                    buttonStyleData:
                                                        const ButtonStyleData(
                                                      padding:
                                                          EdgeInsets.symmetric(
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
                                                      searchMatchFn:
                                                          (item, searchValue) {
                                                        return item.value
                                                            .toString()
                                                            .toLowerCase()
                                                            .contains(searchValue
                                                                .toLowerCase());
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
                                  const SizedBox(height: 10),
                                  MyInputWidget(
                                    title: 'Số Seal',
                                    controller: _soSeal,
                                    textStyle: TextStyle(
                                      fontFamily: 'Comfortaa',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppConfig.textInput,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    height:
                                        MediaQuery.of(context).size.height < 600
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
                                              "Tàu",
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
                                                    top: MediaQuery.of(context)
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
                                                    items:
                                                        _danhsachphuongtientauList
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
                                                              item.tenPhuongTien ??
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
                                                    value: TauId,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        TauId = newValue;
                                                      });
                                                    },
                                                    buttonStyleData:
                                                        const ButtonStyleData(
                                                      padding:
                                                          EdgeInsets.symmetric(
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
                                                                'Tìm tên phương tiện',
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
                                                      searchMatchFn:
                                                          (item, searchValue) {
                                                        if (item
                                                            is DropdownMenuItem<
                                                                String>) {
                                                          // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                          String itemId =
                                                              item.value ?? "";
                                                          // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                          return _danhsachphuongtientauList?.any((ds) =>
                                                                  ds.id ==
                                                                      itemId &&
                                                                  ds.tenPhuongTien
                                                                          ?.toLowerCase()
                                                                          .contains(
                                                                              searchValue.toLowerCase()) ==
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
                                  SizedBox(height: 4),
                                  _buildTableOptions(context),
                                  CheckSheetUploadAnh(
                                    lstFiles: [],
                                  )
                                ],
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
                onPressed: soCont != null
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

class MyInputWidget extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final TextStyle textStyle;

  const MyInputWidget({
    Key? key,
    required this.title,
    required this.controller,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height < 600 ? 10.h : 7.h,
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
              padding: EdgeInsets.only(left: 15.sp),
              child: TextFormField(
                controller: controller,
                style: textStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
