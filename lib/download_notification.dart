

import 'package:flutter/material.dart';

class DownloadFinished extends Notification {
  bool needToRefresh;
  DownloadFinished(this.needToRefresh);
}