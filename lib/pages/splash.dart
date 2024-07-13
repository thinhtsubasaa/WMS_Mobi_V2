import 'dart:async';
import 'package:Thilogi/blocs/menu_roles.dart';
import 'package:Thilogi/config/config.dart';
import 'package:Thilogi/pages/Home.dart';
import 'package:Thilogi/pages/qlkho/QLKhoXe.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/blocs/user_bloc.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../blocs/app_bloc.dart';
import '../utils/next_screen.dart';
import 'package:new_version/new_version.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String DonVi_Id = '99108b55-1baa-46d0-ae06-f2a6fb3a41c8';
  String PhanMem_Id = 'cd9961bf-f656-4382-8354-803c16090314';
  @override
  void initState() {
    super.initState();

    _afterSplash();
    _checkVersion();
  }

  void _checkVersion() async {
    final newVersion = NewVersion(
      iOSId: "com.thilogi.vn.logistics",
      androidId: "com.thilogi.vn.logistics",
    );
    final status = await newVersion.getVersionStatus();
    if (status!.localVersion != status.storeVersion) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: "CẬP NHẬT",
        dismissButtonText: "Bỏ qua",
        dialogText: "Ứng dụng đã có phiên bản mới, vui lòng cập nhật " +
            "${status.localVersion}" +
            " to " +
            "${status.storeVersion}",
        dismissAction: () {
          SystemNavigator.pop();
        },
        updateButtonText: "Cập nhật",
      );
    }

    print("DEVICE : " + status.localVersion);
    print("STORE : " + status.storeVersion);
  }

  Future _afterSplash() async {
    final UserBloc ub = context.read<UserBloc>();
    final AppBloc _ab = context.read<AppBloc>();

    Future.delayed(const Duration(seconds: 3)).then((value) async {
      _ab.getApiUrl();
      if (ub.isSignedIn) {
        await ub.getUserData();
        _ab.getData();
        _goToHomePage();
        _checkVersion();
        print(("API: ${_ab.apiUrl}"));
      } else {
        _goToLoginPage();
        _checkVersion();
        print(("API: ${_ab.apiUrl}"));
      }
    });
  }

  void _goToHomePage() {
    nextScreenReplace(context, QLKhoXePage());
  }

  void _goToLoginPage() {
    nextScreenReplace(context, MyHomePage());
  }

  // @override
  // void initState() {
  //   _afterSplash();
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppConfig.appBarImagePath,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'HỆ THỐNG QUẢN LÝ DOANH NGHIỆP (BMS)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.0, color: AppConfig.textInput),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// void _checkVersion() async {
//   final newVersion = NewVersion(
//     iOSId: "com.thilogi.vn.logistics",
//     androidId: "com.thilogi.vn.logistics",
//   );
//   final status = await newVersion.getVersionStatus();
//   if (status != null) {
//     if (_isVersionLower(status.localVersion, status.storeVersion)) {
//       newVersion.showUpdateDialog(
//         context: context,
//         versionStatus: status,
//         dialogTitle: "CẬP NHẬT",
//         dismissButtonText: "Bỏ qua",
//         dialogText: "Ứng dụng đã có phiên bản mới, vui lòng cập nhật " +
//             "${status.localVersion}" +
//             " lên " +
//             "${status.storeVersion}",
//         dismissAction: () {
//           SystemNavigator.pop();
//         },
//         updateButtonText: "Cập nhật",
//       );
//     }
//   }
// }

// bool _isVersionLower(String localVersion, String storeVersion) {
//   final localParts = localVersion.split('.').map(int.parse).toList();
//   final storeParts = storeVersion.split('.').map(int.parse).toList();

//   for (int i = 0; i < localParts.length; i++) {
//     if (localParts[i] < storeParts[i]) return true;
//     if (localParts[i] > storeParts[i]) return false;
//   }

//   // If we get here, all parts are equal
//   return false;
// }