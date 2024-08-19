import 'package:Thilogi/pages/huydongcont/custom_body_huydongcont.dart';
import 'package:Thilogi/widgets/custom_appbar.dart';
import 'package:Thilogi/widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:Thilogi/config/config.dart';

import 'package:sizer/sizer.dart';
import '../../widgets/custom_bottom.dart';
import '../../widgets/custom_card.dart';

class HuyDongContPage extends StatelessWidget {
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
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: CustomBodyHuyDongCont(),
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
          'HỦY ĐÓNG CONT',
        ),
      ),
    );
  }
}
