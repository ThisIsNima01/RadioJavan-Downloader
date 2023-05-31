import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_file/open_file.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/music_state_provider.dart';
import 'models/music.dart';

class MusicScreen extends StatefulWidget {
  Music music;
  List<Music> mediaList;

  MusicScreen({Key? key, required this.music, required this.mediaList})
      : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  Color primaryColor = Color(0xffE21221);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Download Music'),backgroundColor: primaryColor,),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Card(
              elevation: 8,
              color: Colors.transparent,
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(widget.music.photo),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              for (var music in widget.mediaList) ...[
                ChangeNotifierProvider(
                  create: (context) => MusicStateProvider(),
                  builder: (context, child) => Consumer<MusicStateProvider>(
                    builder: (context, value, child) =>
                        OptionGenerator(music: music),
                  ),
                )
              ],
            ],
          )
        ],
      ),
    );
  }
}

class OptionGenerator extends StatefulWidget {
  Music music;

  OptionGenerator({Key? key, required this.music}) : super(key: key);

  @override
  State<OptionGenerator> createState() => _OptionGeneratorState();
}

class _OptionGeneratorState extends State<OptionGenerator> {
  late MusicStateProvider musicState;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      musicState = Provider.of<MusicStateProvider>(context, listen: false);
    });
    Utils.checkIfFileExistsAlready(widget.music).then((result) {
      setState(() {
        if (result) {
          musicState.isDownloaded = true;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (musicState.isDownloaded) ...{
          PlayButton(
            music: widget.music,
          )
        },
        if (!musicState.isDownloaded && !musicState.isDownloading) ... {
          DownloadButton(music: widget.music,provider: musicState),
        },
        if (musicState.isDownloading) ...{
          CircularPercentIndicator(
            radius: 20,
            lineWidth: 5,
            progressColor: Colors.red,
            backgroundColor: Colors.red.withOpacity(0.3),
            percent: musicState.progressPercent,
            center: Text('${musicState.progressText}%'),
          ),
        },
      ],
    );
  }
}

class PlayButton extends StatelessWidget {
  Music music;

  PlayButton({Key? key, required this.music}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await Permission.audio.request().isGranted) {
          await OpenFile.open(
              '/storage/emulated/0/Music/rj/${music.artist} - ${music.song}${Utils.getMediaFormat(music)}');
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(14)),
        child: Center(
          child: Row(
            children: [
              Icon(music.type == 'video' ? Iconsax.video : Iconsax.music,
                  color: Colors.white, size: 20),
              SizedBox(
                width: 8,
              ),
              Text(
                'Play ${music.type}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DownloadButton extends StatelessWidget {
  Music music;
  MusicStateProvider provider;

  DownloadButton({
    Key? key,
    required this.music,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Permission.storage.request().isGranted;
        await Permission.videos.request().isGranted;
        provider.isDownloading = true;
        // setState(() {
        //   isDownloading = true;
        // });
        await Utils.downloadMusic(music, (count, total) {
          provider.progressText = ((count / total) * 100).toStringAsFixed(0);
          provider.progressPercent = (count / total);
          // setState(() {
          //   progressText = ((count / total) * 100).toStringAsFixed(0);
          //   progressPercent = (count / total);
          // });

          if (count == total) {
            // setState(() {
            //   isDownloaded = true;
            // });
            provider.isDownloaded = true;
            provider.isDownloading = false;
          }
        });
        // setState(() {
        //   isDownloading = false;
        // });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(14)),
        child: Center(
          child: Row(
            children: [
              Icon(Iconsax.document_download, color: Colors.white, size: 20),
              SizedBox(
                width: 8,
              ),
              Text(
                'Download ${music.type}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
