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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController pseudoController;
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    pseudoController = TextEditingController(text: widget.user.pseudo);
    nameController = TextEditingController(text: widget.user.firstName);
    descriptionController = TextEditingController(text: widget.user.description);
  }

  @override
  void dispose() {
    pseudoController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: pseudoController,
                  decoration: const InputDecoration(labelText: 'Pseudo'),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                // Add more fields here
                ElevatedButton(
                  onPressed: () {
                    context.read<UserBloc>().add(UpdateUserProfile(widget.user.copyWith(
                      firstName: nameController.text,
                      description: descriptionController.text,
                    )));
                    Navigator.of(context).pop();  // Close the bottom sheet after saving
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
