import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class Utils {
 static scanNewMedia() async {
    Permission.storage.request();
    OnAudioQuery audioQuery = OnAudioQuery();
    audioQuery.scanMedia('/storage/emulated/0/Music/rj');
    // File file = File('/storage/emulated/0/Download/test.mp3');
    // try {
    //   if (file.existsSync()) {
    //     audioQuery
    //         .scanMedia('/storage/emulated/0/Download'); // Scan the media 'path'
    //   }
    // } catch (e) {
    //   debugPrint('$e');
    // }
  }
}