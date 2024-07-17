import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyMessageDetailScreen extends StatelessWidget {
  static const routeName = 'my_message_detail_screen';

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String groupId = args['groupId'];
    final String groupName = args['groupName'];
    final String groupDescription = args['groupDescription'];

    // Utilisez groupId, groupName, groupDescription comme nécessaire dans cet écran

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du groupe'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Group ID: $groupId'),
            Text('Group Name: $groupName'),
            Text('Group Description: $groupDescription'),
            // Ajoutez d'autres widgets pour afficher les détails du groupe
          ],
        ),
      ),
    );
  }
}
