import 'package:flutter/material.dart';

class AddGroupMessageScreen extends StatelessWidget {
  static const routeName = 'addGroupMessageScreen';

  const AddGroupMessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un groupe de messages'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Formulaire d\'ajout de groupe de messages'),

          ],
        ),
      ),
    );
  }
}
