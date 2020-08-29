/*
 * Author: Gerald Addo-Tetteh
 * Stereo Beats Music Player for Android mobile devices.
 * Addo Develop
 * Email: addodevelop@gmail.com
 * Separated Positioned List (Component)
*/

/*
  This widget builds a list of all the songs on the device.
*/

// imports

// package imports
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:provider/provider.dart';

// lib file imports
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import 'build_check_box.dart';

import 'box_image.dart';
import 'all_songs_popup.dart';

class SeparatedPositionedList extends StatelessWidget {
  const SeparatedPositionedList({
    Key key,
    @required this.itemScrollController,
    @required this.mediaQuery,
    @required this.scaffoldKey,
  }) : super(key: key);

  final ItemScrollController itemScrollController;
  final MediaQueryData mediaQuery;
  final GlobalKey<ScaffoldState> scaffoldKey;
  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    final audioProvider = Provider.of<AudioPlayer>(context, listen: false);
    final songs = songProvider.songs;
    // returns empty widget if no songs are available
    return songs != null && songs.length != 0
        ? _buildSongList(songProvider, songs, audioProvider)
        : DefaultUtil.empty("No songs found...");
  }

  // this method builds the list of songs(all songs on device)
  GestureDetector _buildSongList(SongProvider songProvider,
      List<SongItem> songs, AudioPlayer audioProvider) {
    return GestureDetector(
      onTap: () {
        songProvider.changeBottomBar(false);
        songProvider.setQueueToNull();
      },
      child: ScrollablePositionedList.separated(
        itemCount: songs.length,
        addAutomaticKeepAlives: true,
        itemScrollController: itemScrollController,
        separatorBuilder: (context, index) => index != songs.length - 1
            ? Divider(
                indent: mediaQuery.size.width * (1 / 4),
              )
            : "",
        itemBuilder: (context, index) {
          return Material(
            color: ColorUtil.white,
            child: InkWell(
              onTap: () {
                audioProvider.setShuffle(false);
                audioProvider.play(songs, index);
              },
              onLongPress: () => songProvider.changeBottomBar(true),
              /*
                This gesture detector is set to null when the bottom
                actions bar is shown to remove its functionality. 
              */
              child: GestureDetector(
                onTap: songProvider.showBottonBar
                    ? () {
                        songProvider.changeBottomBar(false);
                        songProvider.setQueueToNull();
                      }
                    : null,
                child: ListTile(
                  leading: BoxImage(
                    path: songs[index].artPath,
                  ),
                  title: Text(
                    DefaultUtil.checkNotNull(songs[index].title)
                        ? songs[index].title
                        : DefaultUtil.unknown,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    DefaultUtil.checkNotNull(songs[index].artist)
                        ? songs[index].artist
                        : DefaultUtil.unknown,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: songProvider.showBottonBar
                      ? BuildCheckBox(path: songs[index].path)
                      : AllSongsPopUp(
                          index: index,
                          song: songs[index],
                          songs: songs,
                          scaffoldKey: scaffoldKey,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
