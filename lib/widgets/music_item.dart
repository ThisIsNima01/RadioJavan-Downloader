import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skeletons/skeletons.dart';

import '../config/global/utils/utils.dart';
import '../models/music.dart';

class MusicItem extends StatefulWidget {
  Music music;

  MusicItem({super.key, required this.primaryColor, required this.music});

  final Color primaryColor;

  @override
  State<MusicItem> createState() => _MusicItemState();
}

class _MusicItemState extends State<MusicItem> {
  String progressText = '0';
  double progressPercent = 0;
  bool isDownloaded = false;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();

    Utils.checkIfFileExistsAlready(widget.music).then((result) {
      setState(() {
        if (result) {
          isDownloaded = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                color: widget.primaryColor,
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
                        width: 74,
                        height: 74,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => SkeletonAvatar(),
                        imageUrl: widget.music.photo! ?? '',
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
                          widget.music.song ?? 'f',
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 16, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          widget.music.artist! ?? '',
                          maxLines: 1,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!isDownloaded && !isDownloading) ...{
                    GestureDetector(
                        onTap: () async {
                          await Permission.storage.request().isGranted;
                          await Permission.videos.request().isGranted;

                          setState(() {
                            isDownloading = true;
                          });
                          await Utils.downloadMusic(widget.music,
                              (count, total) {
                            setState(() {
                              progressText =
                                  ((count / total) * 100).toStringAsFixed(0);
                              progressPercent = (count / total);
                            });

                            if (count == total) {
                              setState(() {
                                isDownloaded = true;
                              });
                            }
                          });
                          setState(() {
                            isDownloading = false;
                          });
                        },
                        child: Icon(Icons.download))
                  },
                  if (isDownloading) ...{
                    CircularPercentIndicator(
                      radius: 20,
                      lineWidth: 5,
                      progressColor: Colors.red,
                      backgroundColor: Colors.red.withOpacity(0.3),
                      percent: progressPercent,
                      center: Text('${progressText}%',style: TextStyle(fontSize: 12),),
                    )
                  },
                  if (isDownloaded) ...{
                    GestureDetector(
                      child: const Icon(Icons.play_arrow),
                      onTap: () async {
                        if (await Permission.audio.request().isGranted) {
                          await OpenFile.open(
                              '/storage/emulated/0/Music/rj/${widget.music.artist} - ${widget.music.song}${Utils.getMediaFormat(widget.music)}');
                        }
                      },
                    )
                  },
                  const SizedBox(
                    width: 8,
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 22,
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 34,
              height: 34,
              child: Icon(widget.music.type == 'video'
                  ? Icons.photo_camera_outlined
                  : Icons.music_note),
            ),
          ),
        ),
      ],
    );
  }
}
