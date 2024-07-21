import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../blocs/profil_bloc.dart';
import '../models/user.dart';
import '../repository/app_repository.dart';

class ProfilScreen extends StatelessWidget {
  static const routeName = 'profilScreen';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = RepositoryProvider.of<AppRepository>(context);

    return BlocProvider(
      create: (_) => UserBloc(repository)..add(LoadCurrentUserProfile()),
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
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserProfileLoaded) {
              return _buildUserProfile(context, state.user);
            } else if (state is UserEditMode) {
              return _buildEditProfileForm(context, (state as UserProfileLoaded).user);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, AppUser user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Name: ${user.firstName}'),
          Text('Email: ${user.email}'),
          // Add more user information here
        ],
      ),
    );
  }

  Widget _buildEditProfileForm(BuildContext context, AppUser user) {
    final nameController = TextEditingController(text: user.firstName);
    final emailController = TextEditingController(text: user.email);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          // Add more fields here
          ElevatedButton(
            onPressed: () {
              // Handle profile update
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
