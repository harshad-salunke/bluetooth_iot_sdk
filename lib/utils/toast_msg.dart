import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

toastMessage(String? message) {
  Fluttertoast.showToast(
      msg: message!,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      webPosition: 'center',
      textColor: Colors.white,
      fontSize: 16.0);
}
