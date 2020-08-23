import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/playlist_&_album_detail.dart';
import '../components/mini_player.dart';
import '../models/album.dart';
import '../components/bottom_actions_bar.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';

class AlbumDetailScreen extends StatelessWidget {
  static const routeName = "/album-detail";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final album = ModalRoute.of(context).settings.arguments as Album;
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar:
          Consumer<SongProvider>(builder: (context, songProvider, _) {
        return AnimatedContainer(
          child: BottomActionsBar(
            scaffoldKey: _scaffoldKey,
            deleteFunction: songProvider.deleteSongs,
          ),
          duration: Duration(milliseconds: 400),
          curve: Curves.easeIn,
          height: songProvider.showBottonBar ? 59 : 0,
        );
      }),
      body: Stack(
        fit: StackFit.expand,
        children: [
          PlaylistAndAlbumDetail(
            album: album,
          ),
          Positioned(
            bottom: 10,
            left: 3,
            right: 3,
            child: Consumer<AudioPlayer>(
              builder: (context, value, child) => value.miniPlayerPresent
                  ? MiniPlayer(mediaQuery: mediaQuery)
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}