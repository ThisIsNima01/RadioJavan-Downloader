import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/just_audio_cache.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/config/global/constants/app_constants.dart';
import 'package:rj_downloader/config/services/local/audio_player_config.dart';
import 'package:rj_downloader/ui/widgets/music_item.dart';
import 'package:skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/services/remote/api_service.dart';
import '../../data/providers/music_list_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController textEditingController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    audioPlayer.setLoopMode(AudioPlayerConfig.getIsLoop() ?? false ? LoopMode.all : LoopMode.off);

    searchFocusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  List popUpChoices = [
    CustomPopupMenu(title: 'Clear Cache', icon: Iconsax.trash),
    CustomPopupMenu(title: 'Developer Github', icon: Iconsax.user),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MusicListProvider(),
      child: Consumer<MusicListProvider>(
        builder: (context, MusicListProvider musicListProvider, child) =>
            Scaffold(
          appBar: AppBar(
              backgroundColor: AppConstants.primaryColor,
              actions: [
                PopupMenuButton(
                  onSelected: (value) async {
                    var selectedItem = value as CustomPopupMenu;
                    if (selectedItem.title == 'Developer Github') {
                      await launchUrl(Uri.parse(AppConstants.myGithubLink),
                          mode: LaunchMode.externalApplication);
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Clear All Cache',
                            style: TextStyle(color: AppConstants.primaryColor),
                          ),
                          content: const Text(
                              'Do You Really Want To Clear All Media Cache ?'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                AudioPlayer().clearCache();
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                    fontFamily: 'pm',
                                    color: AppConstants.primaryColor),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('No',
                                  style: TextStyle(
                                      fontFamily: 'pm', color: Colors.black)),
                            )
                          ],
                        ),
                      );
                    }
                  },
                  icon: const Icon(Iconsax.menu),
                  itemBuilder: (context) => popUpChoices
                      .map(
                        (choice) => PopupMenuItem(
                          value: choice,
                          child: Row(
                            children: [
                              Text(
                                choice.title,
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const Spacer(),
                              Icon(
                                choice.icon,
                                color: AppConstants.primaryColor,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                      )
                      .toList(),
                )
              ],
              title: const Text(
                'Radio Javan Downloader',
                style: TextStyle(fontSize: 18, fontFamily: 'pm'),
              )),
          backgroundColor: const Color(0xffEEEEEE),
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 10,
                          child: AnimatedContainer(
                            height: 54,
                            duration: const Duration(milliseconds: 500),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: searchFocusNode.hasFocus
                                    ? AppConstants.primaryColor
                                    : Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            child: TextField(
                              onSubmitted: (value) async{
                                if (textEditingController.text.isEmpty) {
                                  return;
                                }

                                searchFocusNode.unfocus();
                                musicListProvider.musicList = [];
                                musicListProvider.isLoading = true;

                                musicListProvider.musicList =
                                    await ApiService.getMusicFromServer(
                                    textEditingController.text);

                                musicListProvider.isLoading = false;
                              },
                              focusNode: searchFocusNode,
                              controller: textEditingController,
                              decoration: const InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 14),
                                  hintText: 'Enter music or artist name'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (textEditingController.text.isEmpty) {
                            return;
                          }

                          searchFocusNode.unfocus();
                          musicListProvider.musicList = [];
                          musicListProvider.isLoading = true;

                          musicListProvider.musicList =
                              await ApiService.getMusicFromServer(
                                  textEditingController.text);

                          musicListProvider.isLoading = false;
                        },
                        child: Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: musicListProvider.isLoading
                              ? const Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Iconsax.search_normal,
                                  color: Colors.white,
                                  size: 26,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (musicListProvider.musicList.isNotEmpty) ...[
                  Expanded(
                    child: FlipInX(
                      duration: const Duration(milliseconds: 1500),
                      child: ListView.builder(
                          itemCount: musicListProvider.musicList.length,
                          itemBuilder: (context, index) {
                            return MusicItem(
                              audioPlayer: audioPlayer,
                              media: musicListProvider.musicList[index],
                            );
                          }),
                    ),
                  )
                ],
                Visibility(
                  visible: musicListProvider.isLoading,
                  child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SkeletonListView(
                            scrollable: false,
                            itemCount: 9,
                            itemBuilder: (p0, p1) {
                              return const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  // height: 100,
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              );
                            },
                            // item: const SkeletonAvatar(),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomPopupMenu {
  CustomPopupMenu({required this.title, required this.icon});

  String title;
  IconData icon;
}
