import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/config/global/constants/app_constants.dart';
import 'package:rj_downloader/config/services/local/hive_service.dart';
import 'package:rj_downloader/data/providers/saved_media_provider.dart';
import 'package:rj_downloader/ui/widgets/music_item.dart';

class SavedMediaScreen extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const SavedMediaScreen({super.key, required this.audioPlayer});

  @override
  Widget build(BuildContext context) {
    final savedMediaProvider = Provider.of<SavedMediaProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        title: const Text(
          'Saved Media',
          style: TextStyle(fontFamily: 'pb', fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Card(
          elevation: 0,
          child: savedMediaProvider.mediaList.isNotEmpty
              ? ListView.builder(
                  itemCount: savedMediaProvider.mediaList.length,
                  itemBuilder: (context, index) => Dismissible(
                    onDismissed: (direction) {
                      HiveService.deleteMedia(
                          savedMediaProvider.mediaList[index]);
                      savedMediaProvider.notifyListeners();
                    },
                    key: UniqueKey(),
                    child: MusicItem(
                      media: savedMediaProvider.mediaList[index],
                      audioPlayer: audioPlayer,
                    ),
                  ),
                )
              : const Center(
                  child: Text(
                    'Your list is empty, Try adding some media...',
                    style: TextStyle(fontFamily: 'pb'),
                  ),
                ),
        ),
      ),
    );
  }
}
