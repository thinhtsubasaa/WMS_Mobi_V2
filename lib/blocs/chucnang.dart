import 'dart:convert';

import 'package:Thilogi/blocs/app_bloc.dart';
import 'package:Thilogi/pages/nhanxe/NhanXe.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:Thilogi/models/scan.dart';
import 'package:Thilogi/services/request_helper.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:geolocator_platform_interface/src/enums/location_accuracy.dart'
    as GeoLocationAccuracy;

import '../utils/next_screen.dart';

class ChucnangBloc extends ChangeNotifier {
  static RequestHelper requestHelper = RequestHelper();

  ScanModel? _scan;
  ScanModel? get scan => _scan;

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

  Future<void> getData(
      BuildContext context,
      RoundedLoadingButtonController controller,
      String soKhung,
      String toaDo,
      String? ghiChu) async {
    _isLoading = true;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Yêu cầu quyền truy cập vị trí
      await Geolocator.requestPermission();
    }
    // Lấy vị trí hiện tại
    Position? currentPosition;

    try {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: GeoLocationAccuracy.LocationAccuracy.low,
      );
      double lat = currentPosition.latitude;
      double long = currentPosition.longitude;
      toaDo = "${lat},${long}";

      final http.Response response = await requestHelper.getData(
          'GetDataXeThaPham?keyword=$soKhung&ToaDo=$toaDo&GhiChu=$ghiChu');
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        print("data:${decodedData}");

        notifyListeners();
        controller.success();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Thành công',
            text: "Nhận xe thành công",
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              clear(context);
            });
        controller.reset();
      } else {
        String errorMessage = response.body.replaceAll('"', '');
        notifyListeners();
        controller.error();
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Thất bại',
            text: errorMessage,
            confirmBtnText: 'Đồng ý',
            onConfirmBtnTap: () {
              clear(context);
            });
        print("Toa Do : $toaDo");
        controller.reset();
      }
    } catch (e) {
      _hasError = true;
      _isLoading = false;
      _message = e.toString();
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  void clear(context) async {
    final AppBloc ab = Provider.of<AppBloc>(context, listen: false);
    await ab.clearData().then((_) {
      Navigator.pop(context);
      Navigator.pop(context);
      nextScreenReplace(context, NhanXePage());
    });
  }
}
