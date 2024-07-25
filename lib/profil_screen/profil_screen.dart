import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_flutter_firebase/profil_screen/edit_profil_form.dart';

import '../blocs/profil_bloc.dart';
import '../models/user.dart';
import '../repository/app_repository.dart';

class ProfilScreen extends StatelessWidget {
  static const routeName = 'profilScreen';

  static Future<void> navigateTo(BuildContext context,String email){
    return Navigator.of(context).pushNamed(
      routeName,
      arguments: email,
    );
  }

  final String email;

  const ProfilScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? currentEmail = currentUser?.email;

    final repository = RepositoryProvider.of<AppRepository>(context);

    return BlocProvider(
      create: (_) => UserBloc(repository)..add(LoadUserProfile(userEmail: email)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          actions: [
            if (currentEmail == email)
              BlocBuilder<UserBloc, ProfilState>(
                builder: (context, state) {
                  return IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return EditProfilForm(user:  state.user!);
                        },
                      );
                    },
                  );
                },
              ),
          ],
        ),
        body: BlocBuilder<UserBloc, ProfilState>(
          builder: (context, state) {
            if (state.status == ProfilStatus.getUserProfile) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == ProfilStatus.successUserProfile) {
              return _buildUserProfile(context, state.user!);
            } else if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            } else {
              return const Center(child: Text('Error loading profile'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, AppUser user) {
    return Container(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Pseudo'),
            subtitle: Text(user.pseudo),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Name'),
            subtitle: Text(user.firstName),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Description'),
            subtitle: Text(user.description),
          ),
        ],

      ),
    );
  }
}
