import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';

import '../pages/album_detail_screen.dart';
import '../models/playlist.dart';
import '../models/album.dart';
import '../provider/songItem.dart';
import '../provider/music_player.dart';
import '../utils/text_util.dart';
import '../utils/default_util.dart';
import '../utils/color_util.dart';
import '../pages/playlist_detail_screen.dart';

import 'build_check_box.dart';

enum Purpose { PlayListView, AlbumView }

class PlayListAndAlbum extends StatelessWidget {
  final String title;
  final String subTitle;
  final Map<String, List<SongItem>> albums;
  final Purpose purpose;

  PlayListAndAlbum({
    this.title,
    this.subTitle,
    this.albums,
    this.purpose,
  });

  List<String> albumPaths(Album album) {
    return album.paths.map((song) => song.path).toList();
  }

  String getArtPath(Album album) {
    return album.paths
        .firstWhere(
          (song) => song.artPath != null && song.artPath.length != 0,
          orElse: () => SongItem(artPath: DefaultUtil.defaultImage),
        )
        .artPath;
  }

  void _resetActions(SongProvider songProvider) {
    songProvider.changeBottomBar(false);
    songProvider.setQueueToNull();
    songProvider.setKeysToNull();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final songProvider = Provider.of<SongProvider>(context, listen: false);
    var extraSpace = Consumer<AudioPlayer>(
      builder: (context, value, child) => value.miniPlayerPresent
          ? SizedBox(
              height: 73,
            )
          : Container(),
    );
    if (purpose == Purpose.PlayListView) {
      return PageDefaults(
        title: title,
        subTitle: subTitle,
        extraSpace: extraSpace,
        child: _buildPlayList(mediaQuery, songProvider),
      );
    } else {
      return PageDefaults(
        title: title,
        subTitle: subTitle,
        extraSpace: extraSpace,
        child: _buildAlbumList(mediaQuery, songProvider),
      );
    }
  }

  Widget _buildAlbumList(MediaQueryData mediaQuery, SongProvider songProvider) {
    final albumItems = songProvider.changeToAlbum(albums);
    if (albumItems == null || albumItems.length == 0) {
      return DefaultUtil.empty("No Albums yet..");
    }
    return _listBuilder(
      songProvider: songProvider,
      isPlaylist: false,
      items: albumItems,
      mediaQuery: mediaQuery,
    );
  }

  Widget _buildPlayList(MediaQueryData mediaQuery, SongProvider songProvider) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<PlayList>("playLists").listenable(),
      builder: (context, Box<PlayList> box, child) {
        var playLists = box.values.toList() ?? [];
        if (playLists == null || playLists.length == 0) {
          return DefaultUtil.empty(
              "No playlists yet..", "Click on blue icon (top right)");
        }
        return _listBuilder(
          songProvider: songProvider,
          mediaQuery: mediaQuery,
          items: playLists,
        );
      },
    );
  }

  GestureDetector _listBuilder(
      {SongProvider songProvider,
      MediaQueryData mediaQuery,
      bool isPlaylist = true,
      List<dynamic> items}) {
    final _scrollController = ScrollController();
    return GestureDetector(
      onTap: () {
        songProvider.changeBottomBar(false);
        songProvider.setQueueToNull();
        songProvider.setKeysToNull();
      },
      child: DraggableScrollbar.semicircle(
        controller: _scrollController,
        child: ListView.separated(
          controller: _scrollController,
          separatorBuilder: (context, index) => index != items.length - 1
              ? Divider(
                  indent: mediaQuery.size.width * (1 / 4),
                )
              : "",
          itemCount: items.length,
          itemBuilder: (context, index) {
            String artPath;

            if (items[index].paths != null &&
                items[index].paths.length > 0 &&
                isPlaylist) {
              artPath = songProvider.getArtPath(items[index].paths[0]);
            } else if (!isPlaylist) {
              artPath = getArtPath(items[index]);
            }
            return Material(
              color: ColorUtil.white,
              child: InkWell(
                onTap: () async {
                  await Navigator.of(context).pushNamed(
                      isPlaylist
                          ? PlaylistDetailScreen.routeName
                          : AlbumDetailScreen.routeName,
                      arguments: items[index]);
                  _resetActions(songProvider);
                },
                onLongPress: () => songProvider.changeBottomBar(true),
                child: Consumer<SongProvider>(
                  builder: (context, songProvider1, child) {
                    return GestureDetector(
                      onTap: songProvider1.showBottonBar
                          ? () {
                              songProvider.changeBottomBar(false);
                              songProvider.setQueueToNull();
                              songProvider.setKeysToNull();
                            }
                          : null,
                      child: ListTile(
                        leading: songProvider1.showBottonBar
                            ? isPlaylist
                                ? BuildCheckBox(
                                    paths: items[index].paths ?? [],
                                    playListName: items[index].toString(),
                                  )
                                : BuildCheckBox(
                                    paths: albumPaths(items[index]),
                                  )
                            : null,
                        title: Text(
                          items[index].toString(),
                          style: isPlaylist
                              ? TextUtil.playlistCardTitle
                              : TextUtil.albumTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "Tracks: ${items[index].paths == null ? 0 : items[index].paths.length}",
                        ),
                        trailing: CircleAvatar(
                          backgroundColor: Colors.black,
                          backgroundImage:
                              artPath != null && artPath.length != 0
                                  ? FileImage(File(artPath))
                                  : AssetImage(DefaultUtil.defaultImage),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PageDefaults extends StatelessWidget {
  const PageDefaults({
    Key key,
    @required this.title,
    @required this.subTitle,
    @required this.extraSpace,
    @required this.child,
  }) : super(key: key);

  final String title;
  final String subTitle;
  final Consumer<AudioPlayer> extraSpace;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextUtil.pageHeadingTop,
          ),
          subtitle: Text(subTitle),
          trailing: Icon(Icons.library_music_outlined),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorUtil.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: child,
          ),
        ),
        extraSpace,
      ],
    );
  }
}
