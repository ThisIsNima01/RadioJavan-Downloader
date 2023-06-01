import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:rj_downloader/media.dart';
import 'package:rj_downloader/music_screen.dart';
import 'package:skeletons/skeletons.dart';

import '../config/global/utils/utils.dart';

class MusicItem extends StatefulWidget {
  Media media;

  MusicItem({
    super.key,
    required this.media,
  });

  @override
  State<MusicItem> createState() => _MusicItemState();
}

class _MusicItemState extends State<MusicItem> {
  bool isAudioDownloaded = false;
  bool isVideoDownloaded = false;

  @override
  void initState() {
    Utils.checkIfFileExistsAlready(widget.media, '.mp3').then((result) {
      setState(() {
        if (result) {
          isAudioDownloaded = true;
        }
      });
    });

    Utils.checkIfFileExistsAlready(widget.media, '.mp4').then((result) {
      setState(() {
        if (result) {
          isVideoDownloaded = true;
        }
      });
    });
    super.initState();
  }

  Color primaryColor = Color(0xffE21221);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                MusicScreen(
                  media: widget.media,
                  onDownloadComplete:() {
                    Utils.checkIfFileExistsAlready(widget.media, '.mp3').then((result) {
                      setState(() {
                        if (result) {
                          isAudioDownloaded = true;
                        }
                      });
                    });

                    Utils.checkIfFileExistsAlready(widget.media, '.mp4').then((result) {
                      setState(() {
                        if (result) {
                          isVideoDownloaded = true;
                        }
                      });
                    });
                  },
                ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            height: 100,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
                side: BorderSide(
                  width: 2,
                  color: primaryColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Card(
                      elevation: 10,
                      color: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SkeletonAvatar(),
                          imageUrl: widget.media.photo,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      width: 160,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            widget.media.song ?? 'f',
                            maxLines: 1,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            widget.media.artist,
                            maxLines: 1,
                            style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Icon(Iconsax.arrow_right),
                    const SizedBox(
                      width: 8,
                    )
                  ],
                ),
              ),
            ),
          ),
          if (widget.media.audioLink != null) ...{
            Positioned(
              right: 24,
              child: Card(
                elevation: 10,
                color: isAudioDownloaded ? Colors.green : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  child: Icon(
                    Iconsax.music,
                    size: 20,
                    color: isAudioDownloaded ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          },
          if (widget.media.videoLink != null) ...{
            Positioned(
              right: 68,
              child: Card(
                elevation: 10,
                color: isVideoDownloaded ? Colors.green : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  child: Icon(
                    Iconsax.video,
                    size: 22,
                    color: isVideoDownloaded ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          },
        ],
      ),
    );
  }
}
