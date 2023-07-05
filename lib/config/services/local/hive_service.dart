import 'package:hive/hive.dart';
import 'package:rj_downloader/data/models/media.dart';

class HiveService {
  static Box<Media> mediaBox = Hive.box<Media>('MediaBox');

  static addMedia(Media media){
    mediaBox.add(media);
  }

  static bool isMediaAlreadySaved(Media media) {
    return mediaBox.values.toList().where((element) => element.id == media.id).toList().isNotEmpty;
  }

  static Future<void> deleteMedia(Media media) async{
    await media.delete();
  }
}