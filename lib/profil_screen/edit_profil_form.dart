import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projet_flutter_firebase/models/user.dart';

import '../blocs/profil_bloc.dart';

class EditProfilForm extends StatefulWidget {
  final AppUser user;

  const EditProfilForm({super.key, required this.user});

  @override
  State<EditProfilForm> createState() => _EditProfilFormState();
}

class _EditProfilFormState extends State<EditProfilForm> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.firstName);
    emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              context.read<UserBloc>().add(UpdateUserProfile(widget.user.copyWith(
                firstName: nameController.text,
                email: emailController.text,
              )));
              Navigator.of(context).pop();  // Close the bottom sheet after saving
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
