import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:open_file/open_file.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rj_downloader/config/global/utils/utils.dart';
import 'package:rj_downloader/media.dart';
import 'package:rj_downloader/music_state_provider.dart';
import 'models/music.dart';

class MusicScreen extends StatefulWidget {
  Media media;

  MusicScreen({Key? key, required this.media}) : super(key: key);

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  Color primaryColor = Color(0xffE21221);

  @override
  void initState() {
    print(widget.media.artist);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Music'),
        backgroundColor: primaryColor,
      ),
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
                    image: CachedNetworkImageProvider(widget.media.photo),
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
              ChangeNotifierProvider(
                create: (context) => MusicStateProvider(),
                builder: (context, child) => Consumer<MusicStateProvider>(
                  builder: (context, value, child) => OptionGenerator(
                    musicState: value,
                    media: widget.media,
                    mediaType: '.mp3',
                  ),
                ),
              ),
              if (widget.media.videoLink != null) ...{
                ChangeNotifierProvider(
                  create: (context) => MusicStateProvider(),
                  builder: (context, child) => Consumer<MusicStateProvider>(
                    builder: (context, value, child) => OptionGenerator(
                      musicState: value,
                      media: widget.media,
                      mediaType: '.mp4',
                    ),
                  ),
                ),
              },
            ],
          )
        ],
      ),
    );
  }
}

class OptionGenerator extends StatefulWidget {
  Media media;
  MusicStateProvider musicState;
  String mediaType;

  OptionGenerator(
      {Key? key,
      required this.media,
      required this.musicState,
      required this.mediaType})
      : super(key: key);

  @override
  State<OptionGenerator> createState() => _OptionGeneratorState();
}

class _OptionGeneratorState extends State<OptionGenerator> {
  @override
  void initState() {
    // print('${widget.media.song} ${widget.media.artist} ${widget.music.type}');

    Utils.checkIfFileExistsAlready(widget.media, widget.mediaType)
        .then((result) {
      setState(() {
        if (result) {
          widget.musicState.isDownloaded = true;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.musicState.isDownloaded) ...{
          PlayButton(
            mediaType: widget.mediaType,
            media: widget.media,
          )
        },
        if (!widget.musicState.isDownloaded &&
            !widget.musicState.isDownloading) ...{
          DownloadButton(media: widget.media, provider: widget.musicState,mediaType: widget.mediaType,),
        },
        if (widget.musicState.isDownloading) ...{
          CircularPercentIndicator(
            radius: 20,
            lineWidth: 5,
            progressColor: Colors.red,
            backgroundColor: Colors.red.withOpacity(0.3),
            percent: widget.musicState.progressPercent,
            center: Text('${widget.musicState.progressText}%'),
          ),
        },
      ],
    );
  }
}

class PlayButton extends StatelessWidget {
  Media media;
  String mediaType;

  PlayButton({Key? key, required this.media, required this.mediaType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await Permission.audio.request().isGranted) {
          await OpenFile.open(
              '/storage/emulated/0/Music/rj/${media.artist} - ${media.song}$mediaType');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(14)),
        child: Center(
          child: Row(
            children: [
              Icon(mediaType == '.mp4' ? Iconsax.video : Iconsax.music,
                  color: Colors.white, size: 20),
              SizedBox(
                width: 8,
              ),
              Text(
                'Play ${mediaType == '.mp4' ? 'Video' : 'Music'}',
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
  Media media;
  MusicStateProvider provider;
  String mediaType;

  DownloadButton(
      {Key? key,
      required this.media,
      required this.provider,
      required this.mediaType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Permission.storage.request().isGranted;
        await Permission.videos.request().isGranted;

        provider.isDownloading = true;

        await Utils.downloadMusic(media, (count, total) {
          provider.progressText = ((count / total) * 100).toStringAsFixed(0);
          provider.progressPercent = (count / total);

          if (count == total) {
            provider.isDownloaded = true;
            provider.isDownloading = false;
          }
        }, mediaType);
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
                'Download ${mediaType == '.mp4' ? 'Video' : 'Music'}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
