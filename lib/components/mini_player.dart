import 'dart:io';

import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/music_player.dart';
import '../utils/text_util.dart';
import '../pages/play_page.dart';
import '../utils/default_util.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    Key key,
    @required this.mediaQuery,
  }) : super(key: key);

  final MediaQueryData mediaQuery;
  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    return PlayerBuilder.isPlaying(
      player: audioProvider.audioPlayer,
      builder: (context, snapshot) {
        if (audioProvider.audioPlayer.playerState.value != PlayerState.stop) {
          Audio song = audioProvider.playing;
          return GestureDetector(
            onTap: () =>
                Navigator.of(context).pushNamed(PlayMusicScreen.routeName),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Hero(
                              tag: song.path,
                              child: CircleAvatar(
                                backgroundImage: DefaultUtil.checkNotNull(
                                        song.metas.image.path)
                                    ? FileImage(File(song.metas.image.path))
                                    : AssetImage(DefaultUtil.defaultImage),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  left: 10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.metas.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      song.metas.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextUtil.mutedText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                              icon: FaIcon(FontAwesomeIcons.stepBackward),
                              onPressed: () async =>
                                  await audioProvider.previousTrack()),
                          PlayerBuilder.playerState(
                            player: audioProvider.audioPlayer,
                            builder: (context, playerState) => IconButton(
                                icon: (playerState == PlayerState.pause ||
                                        playerState == PlayerState.stop)
                                    ? FaIcon(FontAwesomeIcons.play)
                                    : FaIcon(FontAwesomeIcons.pause),
                                onPressed: () async =>
                                    await audioProvider.playOrPause()),
                          ),
                          IconButton(
                              icon: FaIcon(FontAwesomeIcons.stepForward),
                              onPressed: () async =>
                                  await audioProvider.nextTrack()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Center(child: DefaultUtil.appName),
            ),
          );
        }
      },
    );
  }
}
