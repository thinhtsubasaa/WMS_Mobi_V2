import 'package:Thilogi/pages/dsx_danhan/custom_body_dsx.dart';
import 'package:Thilogi/pages/lsnhanxe/custom_body_lsdanhan.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_title.dart';

class LSDaNhanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: customAppBar(context),
      body: Column(
        children: [
          CustomCard(),
          Expanded(
            child: Container(
              width: 100.w,
              // decoration: const BoxDecoration(
              //     // image: DecorationImage(
              //     //   image: AssetImage(AppConfig.backgroundImagePath),
              //     //   fit: BoxFit.cover,
              //     // ),
              //     ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: CustomBodyLSDaNhan(),
            ),
          ),
          BottomContent(),
        ],
      ),
    );
  }
}

class BottomContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 11,
      padding: EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppConfig.bottom,
      ),
      child: Center(
        child: customTitle(
          'LỊCH SỬ XE ĐÃ NHẬN',
        ),
      ),
    );
  }
}
