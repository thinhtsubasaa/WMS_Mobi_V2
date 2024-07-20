import 'dart:convert';

import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/baixe.dart';
import 'package:Thilogi/models/doitac.dart';
import 'package:Thilogi/models/khoxe.dart';
import 'package:Thilogi/models/phuongthucvanchuyen.dart';
import 'package:Thilogi/pages/timxe/timxe.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';

import '../../models/dsxchoxuat.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyDSXChoXuat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyDSXScreenChoXuat());
  }
}

class BodyDSXScreenChoXuat extends StatefulWidget {
  const BodyDSXScreenChoXuat({Key? key}) : super(key: key);

  @override
  _BodyDSXScreenChoXuatState createState() => _BodyDSXScreenChoXuatState();
}

class _BodyDSXScreenChoXuatState extends State<BodyDSXScreenChoXuat>
    with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  bool _loading = false;
  List<BaiXeModel>? _baixeList;
  List<BaiXeModel>? get baixeList => _baixeList;
  String? id;
  String? KhoXeId;
  String? doiTac_Id;
  String? phuongThuc_Id;
  List<KhoXeModel>? _khoxeList;
  List<KhoXeModel>? get khoxeList => _khoxeList;
  List<DoiTacModel>? _doitacList;
  List<DoiTacModel>? get doitacList => _doitacList;
  List<PhuongThucVanChuyenModel>? _ptvcList;
  List<PhuongThucVanChuyenModel>? get ptvcList => _ptvcList;
  List<DS_ChoXuatModel>? _cx;
  List<DS_ChoXuatModel>? get cx => _cx;
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDoiTac();
    getPTVC();
    // getData();
    // getBaiXeList(KhoXeId ?? "");
  }

  void getDoiTac() async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_DoiTac/Get_DoiTac');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _doitacList = (decodedData as List)
            .map((item) => DoiTacModel.fromJson(item))
            .toList();
        _doitacList!.insert(0, DoiTacModel(id: '', tenDoiTac: 'Tất cả'));

        // Gọi setState để cập nhật giao diện
        setState(() {
          doiTac_Id = '';
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getPTVC() async {
    try {
      final http.Response response =
          await requestHelper.getData('TMS_PhuongThucVanChuyen/PTVC');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        // print("PTVC: " + decodedData);

        _ptvcList = (decodedData as List)
            .map((item) => PhuongThucVanChuyenModel.fromJson(item))
            .toList();
        _ptvcList!.insert(0,
            PhuongThucVanChuyenModel(id: '', tenPhuongThucVanChuyen: 'Tất cả'));

        // Gọi setState để cập nhật giao diện
        setState(() {
          phuongThuc_Id = '';
          _loading = false;
        });
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getData() async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_WMS_Kho_KhoXe/GetKhoLogistic');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _khoxeList = (decodedData as List)
            .map((item) => KhoXeModel.fromJson(item))
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

  void getBaiXeList(String KhoXeId) async {
    try {
      final http.Response response =
          await requestHelper.getData('DM_WMS_Kho_BaiXe?khoXe_Id=$KhoXeId');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        _baixeList = (decodedData as List)
            .map((item) => BaiXeModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getDSXChoXuat(
      String? id, String? doiTac_Id, String? phuongThuc_Id) async {
    _cx = [];
    try {
      final http.Response response = await requestHelper.getData(
          'KhoThanhPham/GetDanhSachXeChoXuat?id=$id&DoiTac_Id=$doiTac_Id&PhuongThuc_Id=$phuongThuc_Id');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        if (decodedData != null) {
          // Lọc dữ liệu chỉ bao gồm các mục có 'isKeHoach' là true
          var filteredData =
              decodedData.where((item) => item['isKeHoach'] == true).toList();
          print("dayaaaa:$filteredData");

          if (filteredData.isNotEmpty) {
            _cx = (filteredData as List)
                .map((item) => DS_ChoXuatModel.fromJson(item))
                .toList();
            print("Updated _cx: $_cx");

            setState(() {
              _loading = false;
            });
          }
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 2.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: {
                0: FlexColumnWidth(0.3),
                1: FlexColumnWidth(0.3),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.25),
                5: FlexColumnWidth(0.18),
                6: FlexColumnWidth(0.12),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Đơn vị vận chuyển',
                          textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Phương thức',
                          textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Số Khung', textColor: Colors.white),
                    ),
                    Container(
                      width: double.infinity,
                      color: Colors.red,
                      child:
                          _buildTableCell('Loại Xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Mã Màu', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Vị trí', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell(''),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height, // Chiều cao cố định
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FlexColumnWidth(0.3),
                    1: FlexColumnWidth(0.3),
                    2: FlexColumnWidth(0.3),
                    3: FlexColumnWidth(0.3),
                    4: FlexColumnWidth(0.25),
                    5: FlexColumnWidth(0.18),
                    6: FlexColumnWidth(0.12),
                  },
                  children: [
                    ..._cx?.map((item) {
                          index++; // Tăng số thứ tự sau mỗi lần lặp

                          return TableRow(
                            children: [
                              _buildTableCell(item.donVi ?? ""),
                              _buildTableCell(item.phuongThuc ?? ""),
                              _buildTableCell(item.soKhung ?? ""),
                              _buildTableCell(item.loaiXe ?? ""),
                              _buildTableCell(item.maMau ?? ""),
                              _buildTableCell(item.tenViTri ?? ""),
                              Center(
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(Icons.remove_red_eye),
                                  iconSize: 20.0,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TimXePage(
                                          soKhung: item.soKhung ?? "",
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList() ??
                        [],
                    // TableRow(
                    //   children: [
                    //     _buildTableCell('Tổng số', textColor: Colors.red),
                    //     _buildTableCell(_cx?.length.toString() ?? ''),
                    //     Container(),
                    //     Container(),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getData();
    getBaiXeList(KhoXeId ?? "");

    return Container(
      child: Column(
        children: [
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
                                const Text(
                                  'Danh sách xe chờ xuất',
                                  style: TextStyle(
                                    fontFamily: 'Comfortaa',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFA71C20)),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height <
                                                    600
                                                ? 10.h
                                                : 7.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                                                  "Bãi Xe",
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
                                                      items: _baixeList
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
                                                                item.tenBaiXe ??
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
                                                      value: id,
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          id = newValue;
                                                          // doiTac_Id = null;
                                                        });
                                                        if (newValue != null) {
                                                          getDSXChoXuat(
                                                              newValue,
                                                              doiTac_Id ?? "",
                                                              phuongThuc_Id ??
                                                                  "");
                                                          print(
                                                              "object : ${id}");
                                                        }
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
                                                                  'Tìm bãi xe',
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
                                                            return _baixeList?.any((baiXe) =>
                                                                    baiXe.id ==
                                                                        itemId &&
                                                                    baiXe.tenBaiXe
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
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height <
                                                    600
                                                ? 10.h
                                                : 7.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: const Color(0xFF818180),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 25.w,
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
                                                  "Đơn vị vận chuyển ",
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
                                                      items: _doitacList
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
                                                                item.tenDoiTac ??
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
                                                      value: doiTac_Id,
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          doiTac_Id = newValue;
                                                        });
                                                        if (newValue != null) {
                                                          if (newValue == '') {
                                                            getDSXChoXuat(
                                                                id,
                                                                '',
                                                                phuongThuc_Id ??
                                                                    "");
                                                          } else {
                                                            getDSXChoXuat(
                                                                id,
                                                                newValue,
                                                                phuongThuc_Id ??
                                                                    "");
                                                            print(
                                                                "object : ${doiTac_Id}");
                                                          }
                                                        }
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
                                                                  'Tìm đơn vị',
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
                                                            return _doitacList?.any((baiXe) =>
                                                                    baiXe.id ==
                                                                        itemId &&
                                                                    baiXe.tenDoiTac
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
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height <
                                                    600
                                                ? 10.h
                                                : 7.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: const Color(0xFF818180),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 25.w,
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
                                                  "Phương thức ",
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
                                                      items: _ptvcList
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
                                                                item.tenPhuongThucVanChuyen ??
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
                                                      value: phuongThuc_Id,
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          phuongThuc_Id =
                                                              newValue;
                                                        });
                                                        if (newValue != null) {
                                                          if (newValue == '') {
                                                            getDSXChoXuat(
                                                                id,
                                                                doiTac_Id ?? "",
                                                                '');
                                                          } else {
                                                            getDSXChoXuat(
                                                                id,
                                                                doiTac_Id ?? "",
                                                                newValue);
                                                            print(
                                                                "object : ${phuongThuc_Id}");
                                                          }
                                                        }
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
                                                                  'Tìm đơn vị',
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
                                                            return _ptvcList?.any((baiXe) =>
                                                                    baiXe.id ==
                                                                        itemId &&
                                                                    baiXe.tenPhuongThucVanChuyen
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
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(
                                          height: 1, color: Color(0xFFCCCCCC)),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              'Tổng số xe: ${_cx?.length.toString() ?? ''}',
                                              style: TextStyle(
                                                fontFamily: 'Comfortaa',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            _buildTableOptions(context),
                                          ],
                                        ),
                                      ),
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
        ],
      ),
    );
  }
}
