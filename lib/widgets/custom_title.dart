import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';

Widget customTitle(String text) {
  return Text(
    text.tr(),
    textAlign: TextAlign.center,
    style: TextStyle(
      color: AppConfig.textButton,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}
