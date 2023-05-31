import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_file/open_file.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rj_downloader/music_screen.dart';
import 'package:skeletons/skeletons.dart';

import '../config/global/utils/utils.dart';
import '../models/music.dart';

class MusicItem extends StatefulWidget {
  Music music;
  List<Music> mediaList;

  MusicItem(
      {super.key,
      required this.music,
      required this.mediaList,});


  @override
  State<MusicItem> createState() => _MusicItemState();
}

class _MusicItemState extends State<MusicItem> {

  @override
  void initState() {
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
            builder: (context) => MusicScreen(music: widget.music,mediaList: widget.mediaList),
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
                          width: 74,
                          height: 74,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SkeletonAvatar(),
                          imageUrl: widget.music.photo,
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
                            widget.music.artist,
                            maxLines: 1,
                            style: TextStyle(fontSize: 12),
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
          for (var music in widget.mediaList) ... [
            if (music.type == 'mp3') ... {
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
                    child: Icon(Iconsax.music),
                  ),
                ),
              ),
            },

            if (music.type == 'video') ... {
              Positioned(
                right: 66,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: 34,
                    height: 34,
                    child: Icon(Iconsax.video),
                  ),
                ),
              ),
            },
          ],

        ],
      ),
    );
  }
}
