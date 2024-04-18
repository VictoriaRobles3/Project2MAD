import 'package:artfolio/homePage.dart';
import 'package:artfolio/profile.dart';
import 'package:artfolio/settings.dart';
import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildMenuItem(
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => ProfilePage(),
        ),
      );
            },
          ),
          _buildMenuItem(
            icon: Icons.bolt,
            title: 'Feed',
            onTap: () {
              Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => HomePage(),
        ),
      );
            },
          ),
          _buildMenuItem(
            icon: Icons.add_circle,
            title: 'Add a new post',
            onTap: () {
              Navigator.pushNamed(context, '/add_post'); //still need to adjust
            },
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => SettingsPage(),
        ),
      );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required Function onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap as void Function(),
    );
  }
}
