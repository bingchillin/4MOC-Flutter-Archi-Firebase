import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/profil_bloc.dart';

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
                  title:  const Text('Nom'),
                  subtitle: isEditing
                      ? TextField(controller: TextEditingController(text: 'Kenny'))
                      : const Text('Kenny'),
                ),
                const ListTile(
                  leading: CircleAvatar(radius: 0),
                  subtitle: Text("Description Bien longue zeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeebi"),
                ),
              ],
            ),
            const Divider(height: 0),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.info)),
              title: const Text('Infos'),
              subtitle: isEditing
                  ? TextField(controller: TextEditingController(text: 'Longer supporting text to demonstrate how the text wraps and how the leading and trailing widgets are centered vertically with the text.'))
                  : const Text('Longer supporting text to demonstrate how the text wraps and how the leading and trailing widgets are centered vertically with the text.'),
            ),
          ],
        );
      },
    );
  }
}