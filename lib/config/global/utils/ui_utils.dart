import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UiUtils {
  static showDownloadedMediaToast(
      String mediaType, FToast fToast) =>
      fToast.showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('$mediaType Downloaded Successfully',
            style: const TextStyle(color: Colors.white, fontFamily: 'pm'),
          ),
        ),
      );
}