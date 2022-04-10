import 'package:flutter/material.dart';
import 'profile.dart';

class NavDrawer extends StatelessWidget {
  //final String? name;
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.only(top: 20),
        children: <Widget>[
           // DrawerHeader(
           // child: Text(
           //   'Welcome',
             // style: TextStyle(color: Colors.purpleAccent, fontSize: 25),
           // ),
            /*decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/cover.jpg'))),*/
          //),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Home'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Profile'),
            onTap:()=> Navigator.push(context,
                        MaterialPageRoute(builder: (context) => profileScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.border_color),
            title: const Text('Feedback'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}