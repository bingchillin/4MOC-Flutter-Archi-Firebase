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
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: const <Widget>[
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.account_circle_rounded)),
            title: Text('Nom'),
            subtitle: Text('Kenny'),
            trailing: Icon(Icons.update),
          ),
          ListTile(
            leading: CircleAvatar(backgroundColor: Colors.white,),
            subtitle: Text("Description Bien longue zeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebi"),
          ),
          Divider(height: 0),
          ListTile(
            leading: CircleAvatar(child: Text('B')),
            title: Text('Headline'),
            subtitle: Text(
                'Longer supporting text to demonstrate how the text wraps and how the leading and trailing widgets are centered vertically with the text.'),
            trailing: Icon(Icons.update),
          ),
          Divider(height: 0),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.phone)),
            title: Text('Telephone'),
            subtitle: Text("+33 6 12 34 56 78"),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}
