import 'dart:convert';

import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/dongxe.dart';
import 'package:Thilogi/models/dsxdanhan.dart';
import 'package:Thilogi/models/khoxe.dart';
import 'package:Thilogi/models/nhamay.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';

import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyDSXDaNhan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyDSXScreen());
  }
}

class BodyDSXScreen extends StatefulWidget {
  const BodyDSXScreen({Key? key}) : super(key: key);

  @override
  _BodyDSXScreenState createState() => _BodyDSXScreenState();
}

class _BodyDSXScreenState extends State<BodyDSXScreen> with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  String? id;
  String? KhoXeId;
  String? DongXeId;
  List<NhaMayModel>? _nhamayList;
  List<NhaMayModel>? get nhamayList => _nhamayList;
  List<DS_DaNhanModel>? _dn;
  List<DS_DaNhanModel>? get dn => _dn;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;
  String? selectedFromDate;
  String? selectedToDate;
  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController maNhanVienController = TextEditingController();
  List<KhoXeModel>? _khoxeList;
  List<KhoXeModel>? get khoxeList => _khoxeList;
  List<DongXeModel>? _dongxeList;
  List<DongXeModel>? get dongxeList => _dongxeList;

  @override
  void initState() {
    super.initState();
    setState(() {
      KhoXeId = "9001663f-0164-477d-b576-09c7541f4cce";
      _loading = false;
    });
    getDataKho();
    getDataDongXe();
    getData();
    selectedFromDate = DateFormat('MM/dd/yyyy').format(DateTime.now());
    selectedToDate = DateFormat('MM/dd/yyyy').format(DateTime.now().add(Duration(days: 1)));
    // getDSXDaNhan(selectedFromDate, selectedToDate, id ?? "", KhoXeId ?? "", DongXeId ?? "", maNhanVienController.text);
  }

  void getDataKho() async {
    try {
      final http.Response response = await requestHelper.getData('DM_WMS_Kho_KhoXe/GetKhoLogistic');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _khoxeList = (decodedData as List).map((item) => KhoXeModel.fromJson(item)).where((item) => item.maKhoXe == "MT_CLA" || item.maKhoXe == "MN_NAMBO" || item.maKhoXe == "MB_BACBO").toList();

        // Gọi setState để cập nhật giao diện
        setState(() {
          KhoXeId = "9001663f-0164-477d-b576-09c7541f4cce";
          _loading = false;
        });
        getDSXDaNhan(selectedFromDate, selectedToDate, id ?? "", KhoXeId ?? "", DongXeId ?? "", maNhanVienController.text);
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getDataDongXe() async {
    try {
      final http.Response response = await requestHelper.getData('Xe_DongXe');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _dongxeList = (decodedData["datalist"] as List).map((item) => DongXeModel.fromJson(item)).toList();
        _dongxeList!.insert(0, DongXeModel(id: '', tenDongXe: 'Tất cả'));

        // Gọi setState để cập nhật giao diện
        setState(() {
          DongXeId = '';
          _loading = false;
        });
        getDSXDaNhan(selectedFromDate, selectedToDate, id ?? "", KhoXeId ?? "", '', maNhanVienController.text);
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void getData() async {
    try {
      final http.Response response = await requestHelper.getData('NhaMay');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _nhamayList = (decodedData as List).map((item) => NhaMayModel.fromJson(item)).toList();
        _nhamayList!.insert(0, NhaMayModel(id: '', tenNhaMay: 'Tất cả'));

        // Gọi setState để cập nhật giao diện
        setState(() {
          id = '';
          _loading = false;
        });
        getDSXDaNhan(selectedFromDate, selectedToDate, '', KhoXeId ?? "", DongXeId ?? "", maNhanVienController.text);
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getDSXDaNhan(String? tuNgay, String? denNgay, String? id, String? KhoXe_Id, String? DongXe_Id, String? keyword) async {
    _dn = [];

    try {
      final http.Response response = await requestHelper.getData('KhoThanhPham/GetDanhSachXeDaNhanAll?TuNgay=$tuNgay&DenNgay=$denNgay&NhaMay_Id=$id&KhoXe_Id=$KhoXe_Id&DongXe_Id=$DongXe_Id&keyword=$keyword');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: " + decodedData.toString()); // In dữ liệu nhận được từ API để kiểm tra
        if (decodedData != null) {
          _dn = (decodedData as List).map((item) => DS_DaNhanModel.fromJson(item)).toList();
          setState(() {
            _loading = false;
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: 1)),
      ),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedFromDate = DateFormat('MM/dd/yyyy').format(picked.start);
        selectedToDate = DateFormat('MM/dd/yyyy').format(picked.end);
        _loading = false;
      });
      print("TuNgay: $selectedFromDate");
      print("DenNgay: $selectedToDate");
      await getDSXDaNhan(selectedFromDate, selectedToDate, id ?? "", KhoXeId ?? "", DongXeId ?? "", maNhanVienController.text);
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự
    const String defaultDate = "1970-01-01 ";

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '',
              style: TextStyle(
                fontFamily: 'Comfortaa',
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(0.3),
                1: FlexColumnWidth(0.2),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.2),
                5: FlexColumnWidth(0.35),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Ngày nhận', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Nhà Máy', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Số Khung', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Loại Xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Màu xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người nhận', textColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7, // Chiều cao cố định
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(0.3),
                    1: FlexColumnWidth(0.2),
                    2: FlexColumnWidth(0.3),
                    3: FlexColumnWidth(0.3),
                    4: FlexColumnWidth(0.2),
                    5: FlexColumnWidth(0.35),
                  },
                  children: [
                    ..._dn?.map((item) {
                          index++; // Tăng số thứ tự sau mỗi lần lặp

                          return TableRow(
                            children: [
                              // _buildTableCell(index.toString()), // Số thứ tự
                              _buildTableCell(item.ngay ?? ""),
                              _buildTableCell(item.nhaMay ?? ""),
                              _buildTableCell(item.soKhung ?? ""),
                              _buildTableCell(item.loaiXe ?? ""),
                              _buildTableCell(item.mauXe ?? ""),
                              _buildTableCell(item.nguoiNhan ?? ""),
                            ],
                          );
                        }).toList() ??
                        [],
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
                            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calendar_today, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text(
                                          selectedFromDate != null && selectedToDate != null
                                              ? '${DateFormat('dd/MM/yyyy').format(DateFormat('MM/dd/yyyy').parse(selectedFromDate!))} - ${DateFormat('dd/MM/yyyy').format(DateFormat('MM/dd/yyyy').parse(selectedToDate!))}'
                                              : 'Chọn ngày',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                const Divider(height: 1, color: Color(0xFFA71C20)),
                                SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                              color: const Color(0xFFBC2925),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2<String>(
                                              isExpanded: true,
                                              items: _khoxeList?.map((item) {
                                                return DropdownMenuItem<String>(
                                                  value: item.id,
                                                  child: Container(
                                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                    child: SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: Text(
                                                        item.tenKhoXe ?? "",
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                          fontFamily: 'Comfortaa',
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                          color: AppConfig.textInput,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              value: KhoXeId,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  KhoXeId = newValue;
                                                });
                                                if (newValue != null) {
                                                  getDataDongXe();
                                                  getDSXDaNhan(selectedFromDate, selectedToDate, id ?? "", newValue, DongXeId ?? "", maNhanVienController.text);
                                                  print("object : ${newValue}");
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
                                                      hintText: 'Tìm kho xe',
                                                      hintStyle: const TextStyle(fontSize: 12),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                searchMatchFn: (item, searchValue) {
                                                  if (item is DropdownMenuItem<String>) {
                                                    // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                    String itemId = item.value ?? "";
                                                    // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                    return _khoxeList?.any((baiXe) => baiXe.id == itemId && baiXe.tenKhoXe?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                                                  } else {
                                                    return false;
                                                  }
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
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Expanded(
                                      child: Container(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                              color: const Color(0xFFBC2925),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2<String>(
                                              isExpanded: true,
                                              items: _dongxeList?.map((item) {
                                                return DropdownMenuItem<String>(
                                                  value: item.id,
                                                  child: Container(
                                                    child: Text(
                                                      item.tenDongXe ?? "",
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        fontFamily: 'Comfortaa',
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppConfig.textInput,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              value: DongXeId,
                                              onChanged: (newValue) {
                                                setState(() {
                                                  DongXeId = newValue;
                                                });
                                                if (newValue != null) {
                                                  if (newValue == '') {
                                                    getDSXDaNhan(selectedFromDate, selectedToDate, id ?? "", KhoXeId ?? "", '', maNhanVienController.text);
                                                  } else {
                                                    getDSXDaNhan(selectedFromDate, selectedToDate, id ?? "", KhoXeId ?? "", newValue, maNhanVienController.text);
                                                    print("objectcong : ${newValue}");
                                                  }
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
                                                      hintText: 'Tìm dòng xe',
                                                      hintStyle: const TextStyle(fontSize: 12),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                searchMatchFn: (item, searchValue) {
                                                  if (item is DropdownMenuItem<String>) {
                                                    // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                    String itemId = item.value ?? "";
                                                    // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                    return _dongxeList?.any((viTri) => viTri.id == itemId && viTri.tenDongXe?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                                                  } else {
                                                    return false;
                                                  }
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
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height < 600 ? 10.h : 6.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: const Color(0xFFBC2925),
                                      width: 1.5,
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
                                        child: const Center(
                                          child: Text(
                                            "Nhà máy",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontSize: 15,
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
                                                items: _nhamayList?.map((item) {
                                                  return DropdownMenuItem<String>(
                                                    value: item.id,
                                                    child: Container(
                                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                                      child: SingleChildScrollView(
                                                        scrollDirection: Axis.horizontal,
                                                        child: Text(
                                                          item.tenNhaMay ?? "",
                                                          textAlign: TextAlign.center,
                                                          style: const TextStyle(
                                                            fontFamily: 'Comfortaa',
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w600,
                                                            color: AppConfig.textInput,
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
                                                  });
                                                  if (newValue != null) {
                                                    if (id == '') {
                                                      getDSXDaNhan(selectedFromDate, selectedToDate, '', KhoXeId ?? "", DongXeId ?? "", maNhanVienController.text);
                                                    } else {
                                                      getDSXDaNhan(selectedFromDate, selectedToDate, newValue, KhoXeId ?? "", DongXeId ?? "", maNhanVienController.text);
                                                      print("object : ${id}");
                                                    }
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
                                                        hintText: 'Tìm nhà máy',
                                                        hintStyle: const TextStyle(fontSize: 12),
                                                        border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  searchMatchFn: (item, searchValue) {
                                                    if (item is DropdownMenuItem<String>) {
                                                      // Truy cập vào thuộc tính value để lấy ID của ViTriModel
                                                      String itemId = item.value ?? "";
                                                      // Kiểm tra ID của item có tồn tại trong _vl.vitriList không
                                                      return _nhamayList?.any((baiXe) => baiXe.id == itemId && baiXe.tenNhaMay?.toLowerCase().contains(searchValue.toLowerCase()) == true) ?? false;
                                                    } else {
                                                      return false;
                                                    }
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
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: MediaQuery.of(context).size.height < 600 ? 10.h : 6.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: const Color(0xFFBC2925),
                                      width: 1.5,
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
                                        child: const Center(
                                          child: Text(
                                            "Tìm kiếm",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                              color: AppConfig.textInput,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height < 600 ? 0 : 5),
                                          child: TextField(
                                            controller: maNhanVienController,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              hintText: 'Nhập mã nhân viên hoặc tên đầy đủ',
                                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                                            ),
                                            style: const TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.search),
                                        onPressed: () {
                                          setState(() {
                                            _loading = true;
                                          });
                                          // Gọi API với từ khóa tìm kiếm
                                          getDSXDaNhan(selectedFromDate, selectedToDate, id ?? "", KhoXeId ?? "", DongXeId ?? "", maNhanVienController.text);
                                          setState(() {
                                            _loading = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        'Tổng số xe đã thực hiện: ${_dn?.length.toString() ?? ''}',
                                        style: const TextStyle(
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
            ),
          ),
        ],
      ),
    );
  }
}
