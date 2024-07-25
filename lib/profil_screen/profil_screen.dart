import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                      // Your onPressed code here
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
              context.read<UserBloc>().add(UpdateUserProfile(user.copyWith(
                firstName: nameController.text,
                email: emailController.text,
              )));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
