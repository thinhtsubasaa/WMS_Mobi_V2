import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe.dart';
import 'package:Thilogi/services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/blocs/chucnang.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe3.dart';
import 'package:Thilogi/utils/next_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/snackbar.dart';

// ignore: use_key_in_widget_constructors, must_be_immutable
class PopUp extends StatefulWidget {
  String soKhung;
  String soMay;
  String tenMau;
  String tenSanPham;
  String ngayXuatKhoView;
  String tenTaiXe;
  String ghiChu;
  String tenKho;
  List phuKien;
  final TextEditingController ghiChuController = TextEditingController();
  PopUp(
      {required this.soKhung,
      required this.soMay,
      required this.tenMau,
      required this.tenSanPham,
      required this.ngayXuatKhoView,
      required this.tenTaiXe,
      required this.ghiChu,
      required this.tenKho,
      required this.phuKien});

  @override
  _PopUpState createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {
  late TextEditingController ghiChuController;
  @override
  void initState() {
    super.initState();
    ghiChuController = TextEditingController(text: widget.ghiChu);
  }

  @override
  void dispose() {
    ghiChuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Container(
        alignment: Alignment.bottomCenter,
        constraints: BoxConstraints(
          maxHeight: screenHeight < 600
              ? screenHeight * 0.85
              : screenHeight *
                  0.9, // Đặt chiều cao tối đa của popup là 90% của chiều cao màn hình

          // Đặt chiều cao tối đa của popup là 90% của chiều cao màn hình
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white.withOpacity(0.9),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputFields(),
                    _buildCarDetails(context),
                  ],
                ),
              ),
            ),
            _buildButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 10.h,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: Colors.red,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 50),
          const Text(
            'NHẬN XE',
            style: TextStyle(
              fontFamily: 'Myriad Pro',
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông Tin Xác Nhận',
            style: TextStyle(
              fontFamily: 'Comfortaa',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(height: 1, color: Color(0xFFA71C20)),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomInputBox(
                text: "Ngày nhận",
                ngayXuatKhoView: widget.ngayXuatKhoView,
              ),
              const SizedBox(height: 4),
              CustomInputBox(
                text: "Nơi nhận xe",
                tenKho: widget.tenKho,
              ),
              const SizedBox(height: 4),
              CustomInputBox(
                text: "Người nhận",
                tenTaiXe: widget.tenTaiXe,
              ),
              const SizedBox(height: 4),
              CustomInputBox(
                text: "Ghi chú",
                // ghiChu: ghiChu,
                ghiChuController: ghiChuController,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarDetails(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        widget.tenSanPham,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'Coda Caption',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    showInfoXe(
                      'Số khung (VIN):',
                      widget.soKhung,
                    ),
                    showInfoXe(
                      'Màu:',
                      widget.tenMau,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    showInfoXe(
                      'Nhà máy',
                      widget.tenKho,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFCCCCCC)),
            ],
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    String? toaDo;
    final ChucnangBloc _cv = ChucnangBloc();
    final RoundedLoadingButtonController _btnController =
        RoundedLoadingButtonController();
    return Container(
      child: Column(
        children: [
          // RoundedLoadingButton(
          //   width: MediaQuery.of(context).size.width * 1,
          //   color: Color(0xFF00B528),
          //   child: Text('KIỂM TRA OPTION THEO XE',
          //       style: TextStyle(
          //         fontFamily: 'Comfortaa',
          //         color: Colors.white,
          //         fontWeight: FontWeight.w700,
          //         fontSize: 17,
          //       )),
          //   controller: _btnController,
          //   onPressed: () {
          //     nextScreen(
          //       context,
          //       NhanXe3Page(
          //         soKhung: soKhung,
          //         tenMau: tenMau,
          //         tenSanPham: tenSanPham,
          //         phuKien: phuKien,
          //       ),
          //     );
          //     _btnController.reset();
          //   },
          // ),
          ElevatedButton(
            onPressed: () {
              nextScreen(
                context,
                NhanXe3Page(
                  soKhung: widget.soKhung,
                  tenMau: widget.tenMau,
                  tenSanPham: widget.tenSanPham,
                  phuKien: widget.phuKien,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B528),
              fixedSize: Size(MediaQuery.of(context).size.width * 1.0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'KIỂM TRA OPTION THEO XE',
                    style: TextStyle(
                      fontFamily: 'Comfortaa',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppConfig.textButton,
                    ),
                  ),
                ),
                Expanded(child: Container()),
                const Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: Icon(
                    Icons.edit,
                    color: AppConfig.textButton,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 7),
          RoundedLoadingButton(
            width: MediaQuery.of(context).size.width * 1.0,
            borderRadius: 5,
            elevation: 0,
            color: Color(0xFFE96327),
            child: Text('XÁC NHẬN',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  color: AppConfig.textButton,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                )),
            controller: _btnController,
            onPressed: () {
              // _cv.getData(context, _btnController, soKhung, toaDo ?? "");
              QuickAlert.show(
                  context: context,
                  type: QuickAlertType.confirm,
                  text: 'Bạn có muốn nhận xe không?',
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
                    _cv.getData(
                        context, _btnController, widget.soKhung, toaDo ?? "");
                  });
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class CustomInputBox extends StatelessWidget {
  final String text;
  final String? ngayXuatKhoView;
  final String? tenKho;
  final String? tenTaiXe;
  final String? ghiChu;
  final TextEditingController? ghiChuController;

  CustomInputBox({
    required this.text,
    this.ngayXuatKhoView,
    this.tenKho,
    this.tenTaiXe,
    this.ghiChu,
    this.ghiChuController,
  });

  @override
  Widget build(BuildContext context) {
    String displayText = '';
    Widget? inputWidget;

    // Chọn dữ liệu phù hợp để hiển thị
    switch (text) {
      // case 'Ngày nhận':
      //   displayText = ngayXuatKhoView ?? '';
      //   break;
      // case 'Nơi nhận xe':
      //   displayText = tenKho ?? '';
      //   break;
      // case 'Người nhận':
      //   displayText = tenTaiXe ?? '';
      //   break;
      case 'Ngày nhận':
        inputWidget = _buildDisplayBox(ngayXuatKhoView ?? '');
        break;
      case 'Nơi nhận xe':
        inputWidget = _buildDisplayBox(tenKho ?? '');
        break;
      case 'Người nhận':
        inputWidget = _buildDisplayBox(tenTaiXe ?? '');
        break;
      case 'Ghi chú':
        // displayText = ghiChuController?.text ?? "";
        inputWidget = _buildEditableBox(ghiChuController);
        break;
      default:
        break;
    }

    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: const Color(0xFF818180),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
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
                  text,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'Comfortaa',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Center(
                child: inputWidget,
              ),
            ),
            // child: Container(
            //   color: Colors.white,
            //   child: Center(
            //     child: Text(
            //       displayText,
            //       textAlign: TextAlign.left,
            //       style: const TextStyle(
            //         fontFamily: 'Comfortaa',
            //         fontSize: 12,
            //         fontWeight: FontWeight.w400,
            //         color: Color(0xFF000000),
            //       ),
            //     ),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}

Widget _buildDisplayBox(String displayText) {
  return Text(
    displayText,
    textAlign: TextAlign.left,
    style: const TextStyle(
      fontFamily: 'Comfortaa',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF000000),
    ),
  );
}

Widget _buildEditableBox(TextEditingController? controller) {
  return TextFormField(
    controller: controller,
    decoration: const InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
    ),
    style: const TextStyle(
      fontFamily: 'Comfortaa',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF000000),
    ),
  );
}

Widget showInfoXe(String title, String value) {
  return Container(
    padding: EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF818180),
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Comfortaa',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppConfig.primaryColor,
          ),
        )
      ],
    ),
  );
}
