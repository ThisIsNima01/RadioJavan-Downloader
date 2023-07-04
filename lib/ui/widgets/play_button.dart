import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_file/open_file.dart';

import '../../config/global/utils/utils.dart';
import '../../data/models/media.dart';

class PlayButton extends StatelessWidget {
  final Media media;
  final String mediaType;

  const PlayButton({Key? key, required this.media, required this.mediaType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        OpenFile.open(
            '/storage/emulated/0/Music/rj/${Utils.getDirectoryNameByMediaFormat(mediaType)}/${media.artist} - ${media.song}$mediaType');
      },
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              mediaType == '.mp3' ? Iconsax.music : Iconsax.video,
              size: 32,
            ),
            const Text(
              'Play',
              style: TextStyle(
                  fontFamily: 'pb', fontSize: 12, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
