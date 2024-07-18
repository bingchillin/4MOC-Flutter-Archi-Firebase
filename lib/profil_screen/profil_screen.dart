import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/user_bloc.dart';

class ProfilScreen extends StatelessWidget {
  static const routeName = 'profilScreen';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UserBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          actions: [
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.read<UserBloc>().add(ToggleEditMode());
                  },
                );
              },
            ),
          ],
        ),
        body: const UserProfilWidget(),
      ),
    );
  }
}

class UserProfilWidget extends StatelessWidget {
  const UserProfilWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final bool isEditing = state is UserEditMode;
        return ListView(
          children: <Widget>[
            Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.account_circle_rounded)),
                  title: isEditing
                      ? TextField(controller: TextEditingController(text: 'Kenny'))
                      : const Text('Nom'),
                  subtitle: isEditing
                      ? TextField(controller: TextEditingController(text: 'Kenny'))
                      : const Text('Kenny'),
                ),
                ListTile(
                  leading: const CircleAvatar(radius: 0),
                  subtitle: isEditing
                      ? TextField(controller: TextEditingController(text: "Description Bien longue zeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebi"))
                      : const Text("Description Bien longue zeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebi"),
                ),
              ],
            ),
            const Divider(height: 0),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.info)),
              title: isEditing
                  ? TextField(controller: TextEditingController(text: 'Infos'))
                  : const Text('Infos'),
              subtitle: isEditing
                  ? TextField(controller: TextEditingController(text: 'Longer supporting text to demonstrate how the text wraps and how the leading and trailing widgets are centered vertically with the text.'))
                  : const Text('Longer supporting text to demonstrate how the text wraps and how the leading and trailing widgets are centered vertically with the text.'),
            ),
            const Divider(height: 0),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.email)),
              title: isEditing
                  ? TextField(controller: TextEditingController(text: 'mail'))
                  : const Text('mail'),
              subtitle: isEditing
                  ? TextField(controller: TextEditingController(text: "a@a.com"))
                  : const Text("a@a.com"),
              isThreeLine: true,
            ),
          ],
        );
      },
    );
  }
}