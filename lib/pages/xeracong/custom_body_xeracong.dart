import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/blocs/xeracong_bloc.dart';
import 'package:Thilogi/models/checksheet.dart';
import 'package:Thilogi/models/lydo.dart';
import 'package:Thilogi/models/noiden.dart';
import 'package:Thilogi/models/xeracong.dart';
import 'package:Thilogi/pages/lsuxeracong/ls_racong.dart';
import 'package:Thilogi/utils/delete_dialog.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart' as GeoLocationAccuracy;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/user_bloc.dart';
import '../../config/config.dart';
import '../../services/app_service.dart';
import '../../utils/next_screen.dart';
import '../../widgets/loading.dart';

class CustomBodyXeRaCong extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BodyXeRaCongScreen(
      lstFiles: [],
    ));
  }
}

class BodyXeRaCongScreen extends StatefulWidget {
  final List<CheckSheetFileModel?> lstFiles;
  const BodyXeRaCongScreen({super.key, required this.lstFiles});

  @override
  _BodyXeRaCongScreenState createState() => _BodyXeRaCongScreenState();
}

class _BodyXeRaCongScreenState extends State<BodyXeRaCongScreen> with SingleTickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  String? lat;
  String? long;
  String _qrData = '';
  final _qrDataController = TextEditingController();
  XeRaCongModel? _data;

  bool _loading = false;

  String? barcodeScanResult;
  String? viTri;

  late XeRaCongBloc _bl;

  String? _errorCode;
  String? get errorCode => _errorCode;

  late FlutterDataWedge dataWedge;
  late StreamSubscription<ScanResult> scanSubscription;
  String? id;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _message;
  String? get message => _message;
  bool _hasError = false;
  bool get hasError => _hasError;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  final TextEditingController _ghiChu = TextEditingController();
  final TextEditingController _noiden = TextEditingController();
  final TextEditingController _lido = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController textEditingController = TextEditingController();

  bool _Isred = false;
  bool _Iskehoach = false;
  List<String> noiDenList = [];
  List<NoiDenModel>? _noidenList;
  List<NoiDenModel>? get noidenList => _noidenList;
  List<LyDoModel>? _lydoList;
  List<LyDoModel>? get lydoList => _lydoList;
  late UserBloc? _ub;

  PickedFile? _pickedFile;
  List<FileItem?> _lstFiles = [];
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    for (var file in widget.lstFiles) {
      _lstFiles.add(FileItem(
        uploaded: true,
        file: file!.path,
        local: false,
        isRemoved: file.isRemoved,
      ));
    }
    _bl = Provider.of<XeRaCongBloc>(context, listen: false);
    _ub = Provider.of<UserBloc>(context, listen: false);
    getData();
    getDataLyDo();
    dataWedge = FlutterDataWedge(profileName: "Example Profile");
    scanSubscription = dataWedge.onScanResult.listen((ScanResult result) {
      setState(() {
        barcodeScanResult = result.data;
      });
      print(barcodeScanResult);
      _handleBarcodeScanResult(barcodeScanResult ?? "");
    });
  }

  Future imageSelector(BuildContext context, String pickerType) async {
    switch (pickerType) {
      case "gallery":

        /// GALLERY IMAGE PICKER
        _pickedFile = await _picker.getImage(source: ImageSource.gallery);
        break;

      case "camera":

        /// CAMERA CAPTURE CODE
        _pickedFile = await _picker.getImage(source: ImageSource.camera);
        break;
    }

    if (_pickedFile != null) {
      setState(() {
        _lstFiles.add(FileItem(
          uploaded: false,
          file: _pickedFile!.path,
          local: true,
          isRemoved: false,
        ));
      });
    }
  }

  // Upload image to server and return path(url)
  Future<void> _uploadAnh() async {
    for (var fileItem in _lstFiles) {
      if (fileItem!.uploaded == false && fileItem.isRemoved == false) {
        setState(() {
          _loading = true;
        });
        File file = File(fileItem.file!);
        var response = await RequestHelper().uploadFile(file);
        widget.lstFiles.add(CheckSheetFileModel(
          isRemoved: response["isRemoved"],
          id: response["id"],
          fileName: response["fileName"],
          path: response["path"],
        ));
        fileItem.uploaded = true;
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool _allowUploadFile() {
    var item = _lstFiles.firstWhere(
      (file) => file!.uploaded == false,
      orElse: () => null,
    );
    if (item == null) {
      return false;
    }
    return true;
  }

  _removeImage(FileItem image) {
    // find and remove
    // if don't have
    setState(() {
      _lstFiles.removeWhere((img) => img!.file == image.file);
      // check item exists in widget.lstFiles
      if (image.local == true) {
        widget.lstFiles.removeWhere((img) => img!.path == image.file);
      } else {
        widget.lstFiles.map((file) {
          if (file!.path == image.file) {
            file.isRemoved = true;
            return file;
          }
        }).toList();
      }

      Navigator.pop(context);
    });
  }

  bool _isEmptyLstFile() {
    var isRemoved = false;
    if (_lstFiles.isEmpty) {
      isRemoved = true;
    } else {
      // find in list don't have isRemoved = false and have isRemoved = true
      var tmp = _lstFiles.firstWhere((file) => file!.isRemoved == false, orElse: () => null);
      if (tmp == null) {
        isRemoved = true;
      }
    }
    return isRemoved;
  }

  Future<void> getData() async {
    try {
      final http.Response response = await requestHelper.getData('KhoThanhPham/GetListNoiDen');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _noidenList = (decodedData as List).map((item) => NoiDenModel.fromJson(item)).toList();
        _noidenList?.insert(0, NoiDenModel(id: '', noiDen: 'Thêm mới'));
        _noidenList?.insert(1, NoiDenModel(id: '1', noiDen: ''));

        // Gọi setState để cập nhật giao diện
        setState(() {
          _noiden.text = 'Thêm mới';
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getDataLyDo() async {
    try {
      final http.Response response = await requestHelper.getData('KhoThanhPham/GetListLyDo');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _lydoList = (decodedData as List).map((item) => LyDoModel.fromJson(item)).toList();
        _lydoList?.insert(0, LyDoModel(id: '', lyDo: 'Nhập lý do'));
        _lydoList?.insert(1, LyDoModel(id: '1', lyDo: ''));

        // Gọi setState để cập nhật giao diện
        setState(() {
          _lido.text = 'Nhập lý do';
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  @override
  void dispose() {
    _lido.dispose();
    _textController.dispose();
    textEditingController.dispose();
    _noiden.dispose();
    super.dispose();
  }

  Future<void> postData(XeRaCongModel scanData, String? nhanvien, String? noiDi, String? noiDen, String? ghiChu, String? maPin, String? liDo, String? file, String? hinhAnh) async {
    _isLoading = true;

    try {
      var newScanData = scanData;
      newScanData.soKhung = newScanData.soKhung == 'null' ? null : newScanData.soKhung;
      print("print data: ${newScanData.soKhung}");
      final http.Response response =
          await requestHelper.postData('KhoThanhPham/XeRaCong?MaNhanVien=$nhanvien&NoiDi=$noiDi&NoiDen=$noiDen&GhiChu=$ghiChu&MaPin=$maPin&LyDo=$liDo&File=$file&HinhAnh=$hinhAnh', newScanData.toJson());
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: ${decodedData}");
        notifyListeners();
        if (_data?.maNhanVien == null || _lido.text != '') {
          _btnController.success();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: '',
            text: " Xác nhận ra cổng thất bại",
            confirmBtnText: 'Đồng ý',
          );
          _btnController.reset();
        } else {
          _btnController.success();
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: " Xác nhận ra cổng thành công",
            confirmBtnText: 'Đồng ý',
          );
          _btnController.reset();
        }
        setState(() {
          _data = null;
          barcodeScanResult = null;
          _ghiChu.text = "";
          _textController.text = "";
          _noiden.text = 'Thêm mới';
          _lido.text = 'Nhập lý do';
          _qrData = '';
          _qrDataController.text = '';
          _lstFiles.clear();
          _loading = false;
          _Isred = false;
          _Iskehoach = false;
        });
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
      Future.delayed(const Duration(seconds: 1), () {
        _qrData = barcodeScanResult;
        _qrDataController.text = barcodeScanResult;
        _onScan(barcodeScanResult);
      });
    });
  }

  _onScan(value) {
    setState(() {
      _loading = true;
      _Iskehoach = false;
      _Isred = false;
    });
    _bl.getData(context, value).then((_) {
      setState(() {
        _qrData = value;
        if (_bl.xeracong == null) {
          barcodeScanResult = null;
          _qrData = '';
          _qrDataController.text = '';
          _Iskehoach = false;
          _Isred = false;
        }
        _loading = false;
        _data = _bl.xeracong;
        print("MaNhanVien: ${_bl.xeracong?.maNhanVien}");
        print("NoiDen: ${_bl.xeracong?.noiden}");
        if (_bl.xeracong?.maNhanVien == null) {
          _Isred = true;
        }
        if (_bl.xeracong?.noiden == null) {
          _Iskehoach = true;
        }
        print("isred: ${_Isred}");
        print("iskehoach: ${_Iskehoach}");
      });
    });
  }

  _onSave() async {
    setState(() {
      _loading = true;
    });

    List<String> imageUrls = [];

    // if (_lstFiles.isNotEmpty) {
    //   for (var fileItem in _lstFiles) {
    //     if (fileItem?.uploaded == true) {
    //       // Giả sử rằng bạn đã lấy URL từ phương thức uploadFile
    //       var response =
    //           await RequestHelper().uploadFile(File(fileItem!.file!));

    //       String? url = response["path"]; // Lấy URL từ phản hồi
    //       // String? url = fileItem?.file;
    //       if (url != null) {
    //         imageUrls.add(url); // Thêm URL vào danh sách
    //       }
    //     }
    //   }
    // }
    for (var fileItem in _lstFiles) {
      if (fileItem?.uploaded == false && fileItem?.isRemoved == false) {
        File file = File(fileItem!.file!);
        var response = await RequestHelper().uploadFile(file);
        widget.lstFiles.add(CheckSheetFileModel(
          isRemoved: response["isRemoved"],
          id: response["id"],
          fileName: response["fileName"],
          path: response["path"],
        ));
        fileItem.uploaded = true;
        // setState(() {
        //   _loading = false;
        // });

        fileItem.uploaded = true; // Đánh dấu file đã được upload

        if (response["path"] != null) {
          imageUrls.add(response["path"]);
        }
        // } else if (fileItem?.uploaded == true && fileItem?.file != null) {
        //   imageUrls.add(fileItem.path!); // Nếu đã upload trước đó, chỉ thêm URL
      }
    }

// Chuyển đổi danh sách URL thành chuỗi cách nhau bởi dấu phẩy
    String? imageUrlsString = imageUrls.join(',');
    _data?.key = _bl.xeracong?.key;
    _data?.id = _bl.xeracong?.id;
    _data?.soKhung = _bl.xeracong?.soKhung;
    _data?.tenSanPham = _bl.xeracong?.tenSanPham;
    _data?.maSanPham = _bl.xeracong?.maSanPham;
    _data?.soMay = _bl.xeracong?.soMay;
    _data?.maMau = _bl.xeracong?.maMau;
    _data?.tenMau = _bl.xeracong?.tenMau;
    _data?.tenKho = _bl.xeracong?.tenKho;
    _data?.maViTri = _bl.xeracong?.maViTri;
    _data?.tenViTri = _bl.xeracong?.tenViTri;
    _data?.mauSon = _bl.xeracong?.mauSon;
    _data?.noidi = _bl.xeracong?.noidi;
    _data?.noiden = _bl.xeracong?.noiden;
    _data?.bienSo_Id = _bl.xeracong?.bienSo_Id;
    _data?.taiXe_Id = _bl.xeracong?.taiXe_Id;
    _data?.tenDiaDiem = _bl.xeracong?.tenDiaDiem;
    _data?.tenPhuongThucVanChuyen = _bl.xeracong?.tenPhuongThucVanChuyen;
    _data?.maNhanVien = _bl.xeracong?.maNhanVien;
    _data?.hinhAnhUrl = _bl.xeracong?.hinhAnhUrl;
    _data?.tenNhanVien = _bl.xeracong?.tenNhanVien;
    _data?.sdt = _bl.xeracong?.sdt;
    _data?.noidi = _bl.xeracong?.noidi;
    _data?.noiden = _bl.xeracong?.noiden;
    _data?.ghiChu = _ghiChu.text;
    _data?.maPin = _textController.text;
    _data?.tencong = _bl.xeracong?.tencong;
    _data?.noiditaixe = _bl.xeracong?.noiditaixe;
    if (_noiden.text == 'Thêm mới') {
      _noiden.text = '';
    }

    if (_lido.text == 'Nhập lý do') {
      _lido.text = '';
    }
    _data?.hinhAnh = imageUrlsString;

    print("MaNhanVien: ${_data?.maNhanVien}");
    print("noiden: ${_noiden.text}");

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
        postData(_data!, _data?.maNhanVien ?? "", _data?.tencong ?? "", _data?.noiden ?? _noiden.text, _ghiChu.text, _textController.text, _lido.text, _data?.hinhAnh ?? "", _data?.hinhAnhUrl ?? "").then((_) {
          print("loading: ${_loading}");
          setState(() {
            // _data = null;
            // barcodeScanResult = null;
            // _ghiChu.text = "";
            // _textController.text = "";
            // _lido.text = "";
            // _qrData = '';
            // _qrDataController.text = '';
            _loading = false;
            _noiden.text = 'Thêm mới';
            _lido.text = 'Nhập lý do';
            // _Isred = false;
            // _Iskehoach = false;
          });
        });
      }
    });
  }

  void _showConfirmationDialogTuChoi(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Vui lòng nhập lí do từ chối?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 100.w,
                        height: 8.h,
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
                              width: 12.w,
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
                                  "Lý do",
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppConfig.textInput,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      items: _lydoList
                                          ?.map((item) {
                                            if (item.lyDo != null && item.lyDo!.isNotEmpty) {
                                              return DropdownMenuItem<String>(
                                                value: item.lyDo ?? "",
                                                child: Container(
                                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: Text(
                                                      item.lyDo ?? "",
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        fontFamily: 'Comfortaa',
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppConfig.textInput,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            return null; // Ẩn giá trị rỗng khỏi danh sách hiển thị
                                          })
                                          .whereType<DropdownMenuItem<String>>()
                                          .toList(),
                                      value: _lido.text.isNotEmpty ? _lido.text : null,
                                      onChanged: (String? newValue) {
                                        if (newValue == 'Nhập lý do') {
                                          _lido.text = "";
                                          _showInputDialogLiDo(context);
                                        } else {
                                          setState(() {
                                            _lido.text = newValue!;
                                          });
                                        }
                                      },
                                      buttonStyleData: const ButtonStyleData(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        height: 40,
                                        width: 200,
                                      ),
                                      dropdownStyleData: const DropdownStyleData(
                                        maxHeight: 200,
                                      ),
                                      menuItemStyleData: const MenuItemStyleData(
                                        height: 40,
                                      ),
                                      dropdownSearchData: DropdownSearchData(
                                        searchController: textEditingController,
                                        searchInnerWidgetHeight: 50,
                                        searchInnerWidget: Container(
                                          height: 50,
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 4,
                                            right: 8,
                                            left: 8,
                                          ),
                                          child: TextFormField(
                                            expands: true,
                                            maxLines: null,
                                            controller: textEditingController,
                                            decoration: InputDecoration(
                                              isDense: true,
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 8,
                                              ),
                                              hintText: 'Tìm lý do',
                                              hintStyle: const TextStyle(fontSize: 10),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                        ),
                                        searchMatchFn: (item, searchValue) {
                                          return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
                                        },
                                      ),
                                      onMenuStateChange: (isOpen) {
                                        if (!isOpen) {
                                          textEditingController.clear();
                                        }
                                      },
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Vui lòng nhập mã pin của bạn?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _textController,
                        onChanged: (text) {
                          // Gọi setState để cập nhật giao diện khi giá trị TextField thay đổi
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'Nhập mã pin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _btnController.reset();
                            },
                            child: Text(
                              'Không',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: _textController.text.isNotEmpty ? () => _showConfirmationDialogMaPin(context) : null,
                            child: Text(
                              'Đồng ý',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmationDialogMaPin(BuildContext context) {
    Navigator.of(context).pop();
    _onSave();
  }

  void _showInputDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Vui lòng nhập nơi đến của bạn?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _noiden,
                        decoration: InputDecoration(
                          labelText: 'Nhập nơi đến',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _noiden.text = (_noidenList!.isNotEmpty ? _noidenList!.first.noiDen : '')!; // Đảm bảo giá trị hợp lệ
                              });
                              Navigator.of(context).pop();
                              _btnController.reset();
                            },
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              setState(() {
                                String newValue = _noiden.text;
                                if (_noidenList != null && newValue.isNotEmpty) {
                                  _noidenList!.add(NoiDenModel(noiDen: newValue));
                                  _noiden.text = newValue;
                                }
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Lưu',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).then((_) {
      // Kiểm tra xem _selectedValue có còn hợp lệ không
      if (_noiden.text != '' && !_noidenList!.any((item) => item.noiDen == _noiden.text)) {
        setState(() {
          _noiden.text = (_noidenList!.isNotEmpty ? _noidenList!.first.noiDen : '')!; // Hoặc đặt về giá trị mặc định
        });
      }
    });
    ;
  }

  void _showInputDialogLiDo(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Vui lòng nhập lý do của bạn?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _lido,
                        decoration: InputDecoration(
                          labelText: 'Nhập lý do',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _lido.text = (_lydoList!.isNotEmpty ? _lydoList!.first.lyDo : '')!; // Đảm bảo giá trị hợp lệ
                              });
                              Navigator.of(context).pop();
                              _btnController.reset();
                            },
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: () {
                              setState(() {
                                String newValue = _lido.text;
                                if (_lydoList != null && newValue.isNotEmpty) {
                                  _lydoList!.add(LyDoModel(lyDo: newValue));
                                  _lido.text = newValue;
                                }
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Lưu',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).then((_) {
      // Kiểm tra xem _selectedValue có còn hợp lệ không
      if (_lido.text != '' && !_lydoList!.any((item) => item.lyDo == _lido.text)) {
        setState(() {
          _lido.text = (_lydoList!.isNotEmpty ? _lydoList!.first.lyDo : '')!; // Hoặc đặt về giá trị mặc định
        });
      }
    });
    ;
  }

  void _showConfirmationDialogXacNhan(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Vui lòng nhập mã pin của bạn?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _textController,
                        onChanged: (text) {
                          // Gọi setState để cập nhật giao diện khi giá trị TextField thay đổi
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: 'Nhập mã pin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _btnController.reset();
                            },
                            child: const Text(
                              'Không',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: _textController.text.isNotEmpty ? () => _showConfirmationDialogMaPin(context) : null,
                            child: const Text(
                              'Đồng ý',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppBloc ab = context.watch<AppBloc>();
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
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 100.w,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xFFE96327),
                                            Color(0xFFBC2925),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Thông tin xe ra cổng',
                                            style: TextStyle(
                                              fontFamily: 'Comfortaa',
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.visibility),
                                            color: Colors.blue,
                                            onPressed: () {
                                              nextScreen(context, LSRaCongPage());
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      height: 1,
                                      color: AppConfig.primaryColor,
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Item(
                                            title: 'Loại xe: ',
                                            value: _data?.tenSanPham,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          Item(
                                            title: 'Số khung: ',
                                            value: _data?.soKhung,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          Item(title: 'Màu: ', value: _data != null ? (_data?.tenMau != null && _data?.maMau != null ? "${_data?.tenMau} (${_data?.maMau})" : "") : ""),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _Iskehoach == true ? Colors.red : Colors.grey,
                                    width: _Iskehoach == true ? 5 : 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 100.w,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xFFE96327),
                                            Color(0xFFBC2925),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: const Text(
                                        'Kế hoạch xuất xe',
                                        style: TextStyle(
                                          fontFamily: 'Comfortaa',
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      height: 1,
                                      color: AppConfig.primaryColor,
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Item(
                                            title: 'Phương thức vận chuyển: ',
                                            value: _data?.tenPhuongThucVanChuyen,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          Item(
                                            title: 'Nơi đi: ',
                                            value: _data?.noidi,
                                          ),
                                          const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                          Item(
                                            title: 'Nơi đến: ',
                                            value: _data?.noiden,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _Isred == true ? Colors.red : Colors.grey,
                                    width: _Isred == true ? 5 : 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 100.w,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xFFE96327),
                                            Color(0xFFBC2925),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          topRight: Radius.circular(5),
                                        ),
                                      ),
                                      child: const Text(
                                        'Thông tin lái xe ra cổng',
                                        style: TextStyle(
                                          fontFamily: 'Comfortaa',
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      height: 1,
                                      color: AppConfig.primaryColor,
                                    ),
                                    Row(
                                      // mainAxisAlignment:
                                      //     MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              width: 120,
                                              height: 120,
                                              child: _data?.hinhAnhUrl != null
                                                  ? Image.network(
                                                      _data?.hinhAnhUrl ?? "",
                                                      fit: BoxFit.contain,
                                                    )
                                                  : Image.network(
                                                      AppConfig.defaultImage,
                                                      fit: BoxFit.contain,
                                                    ),
                                            ),
                                            ItemTaiXe(
                                              title: 'Mã tài xế: ',
                                              value: _data?.maNhanVien,
                                            ),
                                          ],
                                        ),
                                        Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ItemTaiXe(
                                                title: 'Tên tài xế: ',
                                                value: _data?.tenNhanVien,
                                              ),
                                              const Divider(height: 1, color: Color(0xFFCCCCCC)),
                                              ItemTaiXe(
                                                title: 'SDT: ',
                                                value: _data?.sdt,
                                              ),
                                              // ItemTaiXe(
                                              //   title: 'Nơi đi: ',
                                              //   value: _data?.noiditaixe,
                                              // ),
                                              Container(
                                                height: 7.h,
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      child: Text(
                                                        'Nơi đi: ',
                                                        style: TextStyle(
                                                          fontFamily: 'Comfortaa',
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w700,
                                                          color: Color(0xFF818180),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.43),
                                                      child: SingleChildScrollView(
                                                        scrollDirection: Axis.horizontal,
                                                        child: Text(
                                                          _data?.noiditaixe ?? '',
                                                          textAlign: TextAlign.left,
                                                          style: TextStyle(
                                                            fontFamily: 'Comfortaa',
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w700,
                                                            color: AppConfig.primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              _data?.noiden != null
                                                  ? ItemTaiXe(
                                                      title: 'Nơi đến: ',
                                                      value: _data?.noiden,
                                                    )
                                                  : Container(
                                                      width: 56.w,
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
                                                            width: 12.w,
                                                            decoration: const BoxDecoration(
                                                              color: Color(0xFFF6C6C7),
                                                              border: Border(
                                                                right: BorderSide(
                                                                  color: Color(0xFF818180),
                                                                  width: 1,
                                                                ),
                                                              ),
                                                            ),
                                                            child: const Center(
                                                              child: Text(
                                                                "Nơi đến",
                                                                textAlign: TextAlign.left,
                                                                style: TextStyle(
                                                                  fontFamily: 'Comfortaa',
                                                                  fontSize: 10,
                                                                  fontWeight: FontWeight.w400,
                                                                  color: AppConfig.textInput,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                                                child: DropdownButtonHideUnderline(
                                                                  child: DropdownButton2<String>(
                                                                    isExpanded: true,
                                                                    items: _noidenList
                                                                        ?.map((item) {
                                                                          if (item.noiDen != null && item.noiDen!.isNotEmpty) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: item.noiDen ?? "",
                                                                              child: Container(
                                                                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                                                child: SingleChildScrollView(
                                                                                  scrollDirection: Axis.horizontal,
                                                                                  child: Text(
                                                                                    item.noiDen ?? "",
                                                                                    textAlign: TextAlign.center,
                                                                                    style: const TextStyle(
                                                                                      fontFamily: 'Comfortaa',
                                                                                      fontSize: 12,
                                                                                      fontWeight: FontWeight.w600,
                                                                                      color: AppConfig.textInput,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }
                                                                          return null; // Ẩn giá trị rỗng khỏi danh sách hiển thị
                                                                        })
                                                                        .whereType<DropdownMenuItem<String>>()
                                                                        .toList(),
                                                                    value: _noiden.text.isNotEmpty ? _noiden.text : null,
                                                                    onChanged: (String? newValue) {
                                                                      if (newValue == 'Thêm mới') {
                                                                        _noiden.text = "";
                                                                        _showInputDialog(context);
                                                                      } else {
                                                                        setState(() {
                                                                          _noiden.text = newValue ?? "";
                                                                        });
                                                                      }
                                                                    },
                                                                    buttonStyleData: const ButtonStyleData(
                                                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                                                      height: 40,
                                                                      width: 200,
                                                                    ),
                                                                    dropdownStyleData: const DropdownStyleData(
                                                                      maxHeight: 200,
                                                                    ),
                                                                    menuItemStyleData: const MenuItemStyleData(
                                                                      height: 40,
                                                                    ),
                                                                    dropdownSearchData: DropdownSearchData(
                                                                      searchController: textEditingController,
                                                                      searchInnerWidgetHeight: 50,
                                                                      searchInnerWidget: Container(
                                                                        height: 50,
                                                                        padding: const EdgeInsets.only(
                                                                          top: 8,
                                                                          bottom: 4,
                                                                          right: 8,
                                                                          left: 8,
                                                                        ),
                                                                        child: TextFormField(
                                                                          expands: true,
                                                                          maxLines: null,
                                                                          controller: textEditingController,
                                                                          decoration: InputDecoration(
                                                                            isDense: true,
                                                                            contentPadding: const EdgeInsets.symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 8,
                                                                            ),
                                                                            hintText: 'Tìm nơi đến',
                                                                            hintStyle: const TextStyle(fontSize: 10),
                                                                            border: OutlineInputBorder(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      searchMatchFn: (item, searchValue) {
                                                                        return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
                                                                      },
                                                                    ),
                                                                    onMenuStateChange: (isOpen) {
                                                                      if (!isOpen) {
                                                                        textEditingController.clear();
                                                                      }
                                                                    },
                                                                  ),
                                                                )),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ItemGhiChu(
                                title: 'Ghi chú của bảo vệ: ',
                                controller: _ghiChu,
                              ),
                              const Divider(height: 1, color: Color(0xFFCCCCCC)),
                              Container(
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.87),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orangeAccent,
                                              ),
                                              onPressed: () => imageSelector(context, 'gallery'),
                                              icon: const Icon(Icons.photo_library),
                                              label: const Text(""),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                  // backgroundColor: Theme.of(context).primaryColor,
                                                  ),
                                              onPressed: () => imageSelector(context, 'camera'),
                                              icon: const Icon(Icons.camera_alt),
                                              label: const Text(""),
                                            ),
                                            const SizedBox(width: 10),
                                            // ElevatedButton.icon(
                                            //   style: ElevatedButton.styleFrom(
                                            //     backgroundColor:
                                            //         Color(0xFF00B528),
                                            //   ),
                                            //   onPressed: (_loading ||
                                            //           _allowUploadFile() ==
                                            //               false)
                                            //       ? null
                                            //       : () => _uploadAnh(),
                                            //   icon: const Icon(
                                            //       Icons.cloud_upload),
                                            //   label: const Text("Tải ảnh"),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Ảnh đã chọn",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    if (_isEmptyLstFile())
                                      const SizedBox(
                                        height: 100,
                                        // child: Center(child: Text("Chưa có ảnh nào")),
                                      ),
                                    // Display list image
                                    ResponsiveGridRow(
                                      children: _lstFiles.map((image) {
                                        if (image!.isRemoved == false) {
                                          return ResponsiveGridCol(
                                            xs: 6,
                                            md: 3,
                                            child: InkWell(
                                              onLongPress: () {
                                                deleteDialog(
                                                  context,
                                                  "Bạn có muốn xoá ảnh này? Việc xoá sẽ không thể quay lại.",
                                                  "Xoá ảnh",
                                                  () => _removeImage(image),
                                                );
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(left: 5),
                                                child: image.local == true
                                                    ? Image.file(File(image.file!))
                                                    : Image.network(
                                                        '${ab.apiUrl}/${image.file}',
                                                        errorBuilder: ((context, error, stackTrace) {
                                                          return Container(
                                                            height: 100,
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.redAccent),
                                                            ),
                                                            child: const Center(
                                                                child: Text(
                                                              "Error Image (404)",
                                                              style: TextStyle(color: Colors.redAccent),
                                                            )),
                                                          );
                                                        }),
                                                      ),
                                              ),
                                            ),
                                          );
                                        }
                                        return ResponsiveGridCol(
                                          child: const SizedBox.shrink(),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              // CheckSheetUploadAnh(
                              //   lstFiles: [],
                              // )
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 100.w,
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35.0),
                      ),
                      minimumSize: Size(200, 50), // Kích thước tối thiểu của button
                    ),
                    // onPressed: _data?.maNhanVien != null
                    //     ? () async {
                    //         if (!_loading && _allowUploadFile()) {
                    //           await _uploadAnh(); // Thực hiện hành động upload ảnh
                    //         }
                    //         _showConfirmationDialogXacNhan(context);
                    //       }
                    //     : null,
                    onPressed: _data?.maNhanVien != null ? () => _showConfirmationDialogXacNhan(context) : null,
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontFamily: 'Comfortaa',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    )),
              ),
              Expanded(
                child: RoundedLoadingButton(
                  child: Text(
                    'Từ chối',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  color: Colors.red,
                  controller: _btnController,
                  // onPressed: _data?.soKhung != null
                  //     ? () async {
                  //         if (!_loading && _allowUploadFile()) {
                  //           await _uploadAnh();
                  //         }
                  //         _showConfirmationDialogTuChoi(
                  //             context);
                  //       }
                  //     : null,
                  onPressed: _data?.soKhung != null ? () => _showConfirmationDialogTuChoi(context) : null,
                ),
              )
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 11,
          padding: EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: AppConfig.bottom,
          ),
          child: customTitle(
            _ub?.congBaoVe?.toUpperCase() ?? "",
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
                fontSize: 15,
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

class ItemTaiXe extends StatelessWidget {
  final String title;
  final String? value;

  const ItemTaiXe({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF818180),
            ),
          ),
          Text(
            value ?? "",
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppConfig.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemTaiXeNoiDen extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const ItemTaiXeNoiDen({
    Key? key,
    required this.title,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7.h,
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF818180),
            ),
          ),
          Container(
            width: 37.w,
            // Hoặc dùng Flexible

            child: TextFormField(
              controller: controller,
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppConfig.primaryColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 13.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemNoiden extends StatelessWidget {
  final String title;
  final String? value;
  final ValueChanged<String>? onChanged;

  const ItemNoiden({
    Key? key,
    required this.title,
    this.value,
    this.onChanged,
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
            Expanded(
              child: TextFormField(
                initialValue: value,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
                onChanged: onChanged,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 13.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemGhiChu extends StatelessWidget {
  final String title;
  final TextEditingController controller;

  const ItemGhiChu({
    Key? key,
    required this.title,
    required this.controller,
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
            SizedBox(width: 10), // Khoảng cách giữa title và text field
            Expanded(
              child: TextField(
                controller: controller,
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppConfig.primaryColor,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none, // Loại bỏ đường viền mặc định
                  hintText: '',
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FileItem {
  bool? uploaded = false;
  String? file;
  bool? local = true;
  bool? isRemoved = false;

  FileItem({
    required this.uploaded,
    required this.file,
    required this.local,
    required this.isRemoved,
  });
}