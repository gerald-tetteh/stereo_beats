import 'package:flutter/material.dart';

import '../utils/default_util.dart';
import '../utils/text_util.dart';
import '../pages/home.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[300],
              Colors.blue[200],
              Colors.blue[200],
              Colors.blue[50],
              Colors.red[50],
              Colors.red[100],
              Colors.red[200],
              Colors.red[300],
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: ListView(
          children: [
            Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
              margin: EdgeInsets.only(
                bottom: 10,
              ),
              height: mediaQuery.size.height * 0.1,
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  alignment: Alignment.centerRight,
                  image: AssetImage("assets/images/app_icon.png"),
                ),
              ),
              child: Container(
                child: DefaultUtil.appName,
                alignment: Alignment.bottomLeft,
              ),
            ),
            CustomListTile(
              text: "Home",
              iconData: Icons.home,
              function: () => Navigator.of(context)
                  .pushReplacementNamed(HomeScreen.routeName),
            ),
            CustomListTile(
              text: "All Songs",
              iconData: Icons.music_note,
              function: () {},
            ),
            CustomListTile(
              text: "Favourites",
              iconData: Icons.favorite,
              function: () {},
            ),
            CustomListTile(
              text: "Playlists",
              iconData: Icons.library_music,
              function: () {},
            ),
            CustomListTile(
              text: "Album",
              iconData: Icons.album,
              function: () {},
            ),
            CustomListTile(
              text: "Artist",
              iconData: Icons.person_outline,
              function: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    Key key,
    @required this.iconData,
    @required this.text,
    @required this.function,
  }) : super(key: key);

  final IconData iconData;
  final String text;
  final Function function;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Icon(
          iconData,
          color: Theme.of(context).primaryColor,
          size: TextUtil.medium,
        ),
        title: Text(
          text,
        ),
        onTap: () {
          Navigator.of(context).pop();
          function();
        },
      ),
    );
  }
}