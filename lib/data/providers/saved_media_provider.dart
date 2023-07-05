import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../models/media.dart';

class SavedMediaProvider extends ChangeNotifier {
  final Box<Media> mediaBox = Hive.box<Media>('MediaBox');

  List<Media> get mediaList {
    return mediaBox.values.toList();
  }
}
