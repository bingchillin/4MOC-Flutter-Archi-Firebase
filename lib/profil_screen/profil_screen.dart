import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilScreen extends StatefulWidget {
  static const routeName = 'profilScreen';


  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed(ProfilScreen.routeName);
            },
          ),
        ],
      ),
      body: const UserProfilWidget(),
    );
  }
}

class UserProfilWidget extends StatelessWidget {

  const UserProfilWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          children: const <Widget>[
            Column(
              children: [
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.account_circle_rounded)),
                  title: Text('Nom'),
                  subtitle: Text('Kenny'),
                ),
                ListTile(
                  leading: CircleAvatar(radius: 0,),
                  subtitle: Text("Description Bien longue zeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebi"),
                ),
              ],
            ),
            Divider(height: 0),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.info)),
              title: Text('Infos'),
              subtitle: Text(
                  'Longer supporting text to demonstrate how the text wraps and how the leading and trailing widgets are centered vertically with the text.'),
            ),
            Divider(height: 0),
            ListTile(
              leading: CircleAvatar(child: Icon(Icons.email)),
              title: Text('mail'),
              subtitle: Text("a@a.com"),
              isThreeLine: true,
            ),
          ],
        ),
    );
  }
}