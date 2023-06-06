import 'package:flutter/cupertino.dart';

class MusicStateProvider extends ChangeNotifier {
  bool _isDownloading = false;
  bool _isDownloaded = false;

  String _progressText = '0';
  double _progressPercent = 0;

  bool get isDownloading => _isDownloading;

  bool get isDownloaded => _isDownloaded;

  String get progressText => _progressText;

  double get progressPercent => _progressPercent;

  set isDownloaded(bool isDownloaded) {
    _isDownloaded = isDownloaded;
    notifyListeners();
  }

  set isDownloading(bool isDownloading) {
    _isDownloading = isDownloading;
    notifyListeners();
  }

  set progressText(String progressText) {
    _progressText = progressText;
    notifyListeners();
  }

  set progressPercent(double progressPercent) {
    _progressPercent = progressPercent;
    notifyListeners();
  }
}
