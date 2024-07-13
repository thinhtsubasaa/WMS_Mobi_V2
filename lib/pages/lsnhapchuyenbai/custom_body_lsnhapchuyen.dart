import 'dart:convert';

import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/lsxnhapbai.dart';
import 'package:Thilogi/models/lsxnhapchuyenbai.dart';
import 'package:Thilogi/services/request_helper.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/loading.dart';
import 'package:http/http.dart' as http;

class CustomBodyLSNhapChuyen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(child: BodyLSNhapChuyenScreen());
  }
}

class BodyLSNhapChuyenScreen extends StatefulWidget {
  const BodyLSNhapChuyenScreen({Key? key}) : super(key: key);

  @override
  _BodyLSNhapChuyenScreenState createState() => _BodyLSNhapChuyenScreenState();
}

class _BodyLSNhapChuyenScreenState extends State<BodyLSNhapChuyenScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  String? id;
  String? KhoXeId;

  List<LSX_NhapChuyenBaiModel>? _dn;
  List<LSX_NhapChuyenBaiModel>? get dn => _dn;
  List<LSX_NhapBaiModel>? _cx;
  List<LSX_NhapBaiModel>? get cx => _cx;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? selectedDate;
  String? _errorCode;
  String? get errorCode => _errorCode;
  final TextEditingController textEditingController = TextEditingController();
  final TextEditingController maNhanVienController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    getLSNhap(selectedDate, maNhanVienController.text);
    getLSNhapBai(selectedDate, maNhanVienController.text);
    getTotalNumberOfXe();
  }

  Future<void> getLSNhap(String? ngay, String? keyword) async {
    _dn = [];
    try {
      final http.Response response = await requestHelper.getData(
          'KhoThanhPham/GetDanhSachXeDieuChuyenAll?Ngay=$ngay&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("dataChuyen: " +
            decodedData.toString()); // In dữ liệu nhận được từ API để kiểm tra
        if (decodedData != null) {
          _dn = (decodedData as List)
              .map((item) => LSX_NhapChuyenBaiModel.fromJson(item))
              .toList();
          setState(() {
            _loading =
                false; // Đã nhận được dữ liệu, không còn trong quá trình loading nữa
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  Future<void> getLSNhapBai(String? ngay, String? keyword) async {
    _cx = [];
    try {
      final http.Response response = await requestHelper.getData(
          'KhoThanhPham/GetDanhSachXeNhapBaiAll?Ngay=$ngay&keyword=$keyword');
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("dataNhap: " +
            decodedData.toString()); // In dữ liệu nhận được từ API để kiểm tra
        if (decodedData != null) {
          _cx = (decodedData as List)
              .map((item) => LSX_NhapBaiModel.fromJson(item))
              .toList();
          setState(() {
            _loading =
                false; // Đã nhận được dữ liệu, không còn trong quá trình loading nữa
          });
        }
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedDate = DateFormat('dd/MM/yyyy').format(picked);
        // Gọi API với ngày đã chọn
        _loading = false;
      });
      print("Selected Date: $selectedDate");
      await getLSNhap(selectedDate, maNhanVienController.text);
      await getLSNhapBai(selectedDate, maNhanVienController.text);
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự
    const String defaultDate = "1970-01-01 ";

    // Sắp xếp danh sách _dn theo giờ nhận mới nhất
    var combinedList = [
      ...?_dn?.map((e) => {'type': 'dn', 'data': e}),
      ...?_cx?.map((e) => {'type': 'cx', 'data': e})
    ];
    combinedList.sort((a, b) {
      try {
        var aData = a['data'];
        var bData = b['data'];
        DateTime aTime = DateFormat("yyyy-MM-dd HH:mm").parse(defaultDate +
            ((aData is LSX_NhapChuyenBaiModel
                    ? aData.gioNhan
                    : (aData as LSX_NhapBaiModel).gioNhan) ??
                "00:00"));
        DateTime bTime = DateFormat("yyyy-MM-dd HH:mm").parse(defaultDate +
            ((bData is LSX_NhapChuyenBaiModel
                    ? bData.gioNhan
                    : (bData as LSX_NhapBaiModel).gioNhan) ??
                "00:00"));
        return bTime.compareTo(aTime); // Sắp xếp giảm dần
      } catch (e) {
        // Xử lý lỗi khi không thể phân tích cú pháp chuỗi thời gian
        return 0;
      }
    });
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 2,
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
              columnWidths: {
                0: FlexColumnWidth(0.15),
                1: FlexColumnWidth(0.3),
                2: FlexColumnWidth(0.3),
                3: FlexColumnWidth(0.3),
                4: FlexColumnWidth(0.3),
              },
              children: [
                TableRow(
                  children: [
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Giờ nhận', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Số Khung', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Nơi đi', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Nơi đến', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người nhập bãi',
                          textColor: Colors.white),
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
                    0: FlexColumnWidth(0.15),
                    1: FlexColumnWidth(0.3),
                    2: FlexColumnWidth(0.3),
                    3: FlexColumnWidth(0.3),
                    4: FlexColumnWidth(0.3),
                  },
                  children: [
                    ...combinedList.map((item) {
                          var data = item['data'];
                          index++; // Tăng số thứ tự sau mỗi lần lặp

                          return TableRow(
                            children: [
                              // _buildTableCell(index.toString()), // Số thứ tự
                              _buildTableCell(data is LSX_NhapChuyenBaiModel
                                  ? data.gioNhan ?? ""
                                  : (data as LSX_NhapBaiModel).gioNhan ?? ""),
                              _buildTableCell(data is LSX_NhapChuyenBaiModel
                                  ? data.soKhung ?? ""
                                  : (data as LSX_NhapBaiModel).soKhung ?? ""),
                              _buildTableCell(data is LSX_NhapChuyenBaiModel
                                  ? data.noiDi ?? ""
                                  : ""),
                              _buildTableCell(data is LSX_NhapChuyenBaiModel
                                  ? data.noiDen ?? ""
                                  : (data as LSX_NhapBaiModel).noiDen ?? ""),

                              _buildTableCell(data is LSX_NhapChuyenBaiModel
                                  ? data.nguoiNhapBai ?? ""
                                  : (data as LSX_NhapBaiModel).nguoiNhapBai ??
                                      ""),
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

  int getTotalNumberOfXe() {
    return (_dn?.length ?? 0) + (_cx?.length ?? 0);
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
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Danh sách nhập chuyển bãi',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _selectDate(context),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 6),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.calendar_today,
                                                color: Colors.blue),
                                            SizedBox(width: 4),
                                            Text(
                                              selectedDate ?? 'Chọn ngày',
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                const Divider(
                                    height: 1, color: Color(0xFFA71C20)),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height < 600
                                          ? 10.h
                                          : 7.h,
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
                                        child: Center(
                                          child: Text(
                                            "Tìm kiếm",
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
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                          .size
                                                          .height <
                                                      600
                                                  ? 0
                                                  : 5),
                                          child: TextField(
                                            controller: maNhanVienController,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              hintText:
                                                  'Nhập mã nhân viên hoặc tên đầy đủ',
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 15),
                                            ),
                                            style: const TextStyle(
                                              fontFamily: 'Comfortaa',
                                              fontSize: 14,
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
                                          getLSNhap(selectedDate,
                                              maNhanVienController.text);
                                          getLSNhapBai(selectedDate,
                                              maNhanVienController.text);
                                          setState(() {
                                            _loading = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        'Tổng số xe đã thực hiện: ${getTotalNumberOfXe()}',
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
            ),
          ),
        ],
      ),
    );
  }
}
