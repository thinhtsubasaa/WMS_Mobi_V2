import 'dart:convert';

import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/models/dsxdanhan.dart';
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

class _BodyDSXScreenState extends State<BodyDSXScreen>
    with TickerProviderStateMixin, ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();
  String _qrData = '';
  final _qrDataController = TextEditingController();
  bool _loading = false;
  String? id = "004cbc8d-1a72-42cf-cbf6-08dc9bff5b38";
  String? KhoXeId;
  List<NhaMayModel>? _nhamayList;
  List<NhaMayModel>? get nhamayList => _nhamayList;
  List<DS_DaNhanModel>? _dn;
  List<DS_DaNhanModel>? get dn => _dn;
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
    // getDSXDaNhan(id ?? "", selectedDate);

    getData();
    selectedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    getDSXDaNhanALL(selectedDate, maNhanVienController.text).then((_) {
      // Sau khi tải dữ liệu "ALL", tiếp tục với dữ liệu theo ID
      if (id == "004cbc8d-1a72-42cf-cbf6-08dc9bff5b38") {
        // Đã tải "ALL" rồi nên không cần gọi lại
      } else {
        getDSXDaNhan(selectedDate, id, maNhanVienController.text);
      }
    });
    // getDSXDaNhan(selectedDate, id);
    // setState(() {
    //   if (id == "004cbc8d-1a72-42cf-cbf6-08dc9bff5b38") {
    //     getDSXDaNhanALL(selectedDate);
    //   }
    // });
  }

  // void getDSXDaNhan(String? id, String? ngay) async {
  //   _dn = [];
  //   try {
  //     final http.Response response = await requestHelper.getData(
  //         'KhoThanhPham/GetDanhSachXeDaNhanAll?LoaiXe_Id=$id&Ngay=$ngay');
  //     if (response.statusCode == 200) {
  //       var decodedData = jsonDecode(response.body);
  //       print("data: " + decodedData);
  //       if (decodedData != null) {
  //         _dn = (decodedData as List)
  //             .map((item) => DS_DaNhanModel.fromJson(item))
  //             .toList();

  //         // Gọi setState để cập nhật giao diện
  //         setState(() {
  //           _loading = false;
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     _hasError = true;
  //     _errorCode = e.toString();
  //   }
  // }
  void getData() async {
    try {
      final http.Response response = await requestHelper.getData('NhaMay');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);

        _nhamayList = (decodedData as List)
            .map((item) => NhaMayModel.fromJson(item))
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

  Future<void> getDSXDaNhanALL(String? ngay, String? keyword) async {
    _dn = [];
    print("Date: $ngay");
    try {
      final http.Response response = await requestHelper.getData(
          'KhoThanhPham/GetDanhSachXeDaNhanAllNM?Ngay=$ngay&keyword=$keyword');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("dataALL: " +
            decodedData.toString()); // In dữ liệu nhận được từ API để kiểm tra
        if (decodedData != null) {
          _dn = (decodedData as List)
              .map((item) => DS_DaNhanModel.fromJson(item))
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

  Future<void> getDSXDaNhan(String? ngay, String? id, String? keyword) async {
    _dn = [];
    print("Date: $ngay");
    try {
      final http.Response response = await requestHelper.getData(
          'KhoThanhPham/GetDanhSachXeDaNhanAll?Ngay=$ngay&NhaMay_Id=$id&keyword=$keyword');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data: " +
            decodedData.toString()); // In dữ liệu nhận được từ API để kiểm tra
        if (decodedData != null) {
          _dn = (decodedData as List)
              .map((item) => DS_DaNhanModel.fromJson(item))
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
      await getDSXDaNhanALL(selectedDate, maNhanVienController.text);
      if (id != "004cbc8d-1a72-42cf-cbf6-08dc9bff5b38") {
        await getDSXDaNhan(selectedDate, id, maNhanVienController.text);
      }
      setState(() {
        _loading = false;
      });
      // getDSXDaNhan(selectedDate, id);
      // getDSXDaNhanALL(selectedDate);
    }
  }

  Widget _buildTableOptions(BuildContext context) {
    int index = 0; // Biến đếm số thứ tự
    const String defaultDate = "1970-01-01 ";

    // Sắp xếp danh sách _dn theo giờ nhận mới nhất
    _dn?.sort((a, b) {
      try {
        DateTime aTime = DateFormat("yyyy-MM-dd HH:mm")
            .parse(defaultDate + (a.gioNhan ?? "00:00"));
        DateTime bTime = DateFormat("yyyy-MM-dd HH:mm")
            .parse(defaultDate + (b.gioNhan ?? "00:00"));
        return bTime.compareTo(aTime); // Sắp xếp giảm dần
      } catch (e) {
        // Xử lý lỗi khi không thể phân tích cú pháp chuỗi thời gian
        return 0;
      }
    });
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width * 2.2,
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
                      child:
                          _buildTableCell('Giờ nhận', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Nhà Máy', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Số Khung', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child:
                          _buildTableCell('Loại Xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Màu xe', textColor: Colors.white),
                    ),
                    Container(
                      color: Colors.red,
                      child: _buildTableCell('Người nhận',
                          textColor: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height:
                  MediaQuery.of(context).size.height * 1.2, // Chiều cao cố định
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  columnWidths: {
                    0: FlexColumnWidth(0.15),
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
                              _buildTableCell(item.gioNhan ?? ""),
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
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Danh sách xe đã nhận',
                                      style: TextStyle(
                                        fontFamily: 'Comfortaa',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _selectDate(context),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 6),
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
                                            SizedBox(width: 8),
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
                                          getDSXDaNhanALL(selectedDate,
                                              maNhanVienController.text);
                                          if (id !=
                                              "004cbc8d-1a72-42cf-cbf6-08dc9bff5b38") {
                                            getDSXDaNhan(selectedDate, id,
                                                maNhanVienController.text);
                                          }
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
                                            "Nhà máy",
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
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                items: _nhamayList?.map((item) {
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
                                                          item.tenNhaMay ?? "",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            fontFamily:
                                                                'Comfortaa',
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
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
                                                  });
                                                  if (newValue != null) {
                                                    if (id ==
                                                        "004cbc8d-1a72-42cf-cbf6-08dc9bff5b38") {
                                                      getDSXDaNhanALL(
                                                          selectedDate,
                                                          maNhanVienController
                                                              .text);
                                                    } else {
                                                      getDSXDaNhan(
                                                          selectedDate,
                                                          newValue,
                                                          maNhanVienController
                                                              .text);
                                                      print("object : ${id}");
                                                    }
                                                  }
                                                },
                                                buttonStyleData:
                                                    const ButtonStyleData(
                                                  padding: EdgeInsets.symmetric(
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
                                                  searchInnerWidgetHeight: 50,
                                                  searchInnerWidget: Container(
                                                    height: 50,
                                                    padding:
                                                        const EdgeInsets.only(
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
                                                        hintText: 'Tìm nhà máy',
                                                        hintStyle:
                                                            const TextStyle(
                                                                fontSize: 12),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
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
                                                      return _nhamayList?.any((baiXe) =>
                                                              baiXe.id ==
                                                                  itemId &&
                                                              baiXe.tenNhaMay
                                                                      ?.toLowerCase()
                                                                      .contains(
                                                                          searchValue
                                                                              .toLowerCase()) ==
                                                                  true) ??
                                                          false;
                                                    } else {
                                                      return false;
                                                    }
                                                  },
                                                ),
                                                onMenuStateChange: (isOpen) {
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
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        'Tổng số xe đã thực hiện: ${_dn?.length.toString() ?? ''}',
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
