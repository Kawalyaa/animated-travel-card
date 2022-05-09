import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Styles {
  static const double hzScreenPadding = 18;

  static final TextStyle baseTitle = TextStyle(
      fontSize: 11, fontFamily: 'DMSerifDisplay', package: dotenv.env['Pkg']);
  static final TextStyle baseBody = TextStyle(
      fontSize: 11, fontFamily: 'OpenSans', package: dotenv.env['Pkg']);

  static final TextStyle appHeader = baseTitle.copyWith(
      color: const Color(0xFF0e0e0e), fontSize: 36, height: 1);

  static final TextStyle cardTitle = baseTitle.copyWith(
      height: 1, color: const Color(0xFF1a1a1a), fontSize: 25);
  static final TextStyle cardSubtitle = baseBody.copyWith(
      color: const Color(0xFF666666), height: 1.5, fontSize: 12);
  static final TextStyle cardAction = baseBody.copyWith(
      color: const Color(0xFFa6998b),
      fontSize: 10,
      height: 1,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1);

  static final TextStyle hotelsTitleSection = baseBody.copyWith(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      height: 2);
  static final TextStyle hotelTitle = baseBody.copyWith(
      color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600);
  static final TextStyle hotelPrice =
      baseBody.copyWith(color: const Color(0xff4d4d4d), fontSize: 13);
  static final TextStyle hotelScore =
      baseBody.copyWith(color: const Color(0xff0e0e0e));
  static final TextStyle hotelData = baseBody.copyWith(color: Colors.grey[700]);
}
