import 'package:flutter/material.dart';

import '../config/config.dart';

Widget customTitle(String text) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      color: AppConfig.textButton,
      fontFamily: 'Roboto',
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  );
}
