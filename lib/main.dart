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
import 'package:rj_downloader/widgets/music_item.dart';

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
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 10,
                            child: Container(
                              decoration: BoxDecoration(),
                              padding: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                              child: TextField(
                                controller: textEditingController,
                                decoration: const InputDecoration(
                                  enabledBorder: InputBorder.none,
                                     focusedBorder: InputBorder.none,
                                    hintStyle: TextStyle(fontSize: 14),
                                    hintText:
                                        'Enter Music Or Artist Name'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
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
                          },
                          child: Text('Search'),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: !isLoading,
                    child: Expanded(
                      child: ListView.builder(
                        itemCount: musicListProvider.musicList.length,
                        itemBuilder: (context, index) => MusicItem(
                          primaryColor: primaryColor,
                          music: musicListProvider.musicList[index],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isLoading,
                    child: const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
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
