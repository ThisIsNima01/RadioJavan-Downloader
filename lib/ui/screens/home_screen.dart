import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/ui/widgets/music_item.dart';

import '../../config/services/remote/api_service.dart';
import '../../data/models/media.dart';
import '../../data/providers/music_list_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController textEditingController = TextEditingController();
  bool isLoading = false;
  FocusNode searchFocusNode = FocusNode();


  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MusicListProvider(),
      child: Consumer<MusicListProvider>(
        builder: (context, MusicListProvider musicListProvider, child) =>
            Scaffold(
          appBar: AppBar(
              backgroundColor: Utils.primaryColor,
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
                                    ? Utils.primaryColor
                                    : Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            child: TextField(
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
                          setState(() {
                            isLoading = true;
                          });

                          musicListProvider.musicList =
                              await ApiService.getMusicFromServer(
                                  textEditingController.text);

                          setState(() {
                            isLoading = false;
                          });
                        },
                        child: Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            color: Utils.primaryColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: isLoading
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
                const SizedBox(
                  height: 20,
                ),
                if (musicListProvider.musicList.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 24,
                      ),
                      Text(
                        'Your Music Search',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Divider(color: Colors.black87, height: 1),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: musicListProvider.musicList.length,
                        itemBuilder: (context, index) {
                          return MusicItem(
                            media: musicListProvider.musicList[index],
                          );
                        }),
                  )
                ],
                Visibility(
                  visible: isLoading,
                  child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Getting Music List...',
                          style: TextStyle(fontSize: 18, fontFamily: 'pb'),
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
