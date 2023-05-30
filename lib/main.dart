import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/config/services/remote/api_service.dart';
import 'package:rj_downloader/models/music.dart';
import 'package:rj_downloader/music_list_provider.dart';

void main() async {
  // MediaStore.appFolder = "rj";
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController textEditingController = TextEditingController();
  ApiService apiService = ApiService();
  List<Music>? musicList = [];
  bool isLoading = false;

  Color primaryColor = Color(0xffE21221);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (context) => MusicListProvider(),
        child: Consumer<MusicListProvider>(
          builder: (context, MusicListProvider musicListProvider, child) =>
              Scaffold(
            appBar: AppBar(
                backgroundColor: primaryColor,
                title: Text('Radio Javan Downlaoder')),
            backgroundColor: Color(0xffEEEEEE),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextField(
                        controller: textEditingController,
                        decoration:
                            InputDecoration(hintText: 'Enter Music Name Here')),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });

                      musicListProvider.musicList = await apiService
                          .getMusicFromServer(textEditingController.text);

                      setState(() {
                        isLoading = false;
                      });

                      // https://host2.media-rj.com/media/mp3/mp3-256/83907-373ea3b15d71424.mp3
                      // var key = UniqueKey();

                      // scanNewMedia();
                    },
                    child: Text('Search'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: musicListProvider.musicList.length,
                      itemBuilder: (context, index) => MusicItem(
                        primaryColor: primaryColor,
                        music: musicListProvider.musicList[index],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isLoading,
                    child: const CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Card(
                    elevation: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          color: Colors.red,
                        ),
                        imageUrl: widget.music.photo! ?? '',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!isDownloaded && !isDownloading) ...{
                    GestureDetector(
                        onTap: () async {
                          setState(() {
                            isDownloading = true;
                          });
                          await downloadMusic(widget.music);
                          setState(() {
                            isDownloading = false;
                          });
                        },
                        child: Icon(Icons.download))
                  },
                  if (isDownloading) ...{
                    CircularPercentIndicator(
                      radius: 20,
                      percent: progressPercent,
                      center: Text(progressText),
                    )
                  },

                  if (isDownloaded) ... {
                    Icon(Icons.play_arrow)
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
              child: Icon(widget.music.type == 'video' ? Icons.photo_camera_outlined : Icons.music_note),
            ),
          ),
        ),
      ],
    );
  }

  downloadMusic(Music music) async {
    await ApiService.dio.download(
      music.link!,
      '/storage/emulated/0/Music/rj/${music.artist} - ${music.song}.mp3',
      onReceiveProgress: (count, total) {
        setState(() {
          progressText = ((count / total) * 100).toStringAsFixed(0);
          progressPercent = (count / total);
        });

        if (count == total) {
          setState(() {
            isDownloaded = true;
          });
        }
      },
    );
    Utils.scanNewMedia();
  }
}
