import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projet_flutter_firebase/repository/app_repository.dart';
import '../models/user.dart';
import 'user_list_tile_widget.dart';

class UserContactsFutureBuilder extends StatefulWidget {
  final AppRepository appRepository;
  final String currentUserId;
  final List<String> contacts;

  const UserContactsFutureBuilder({
    super.key,
    required this.appRepository,
    required this.currentUserId,
    required this.contacts,
  });

  @override
  _UserContactsFutureBuilderState createState() => _UserContactsFutureBuilderState();
}

class _UserContactsFutureBuilderState extends State<UserContactsFutureBuilder> {
  late Future<List<String>> _blockedContactsFuture;
  final Set<String> _selectedUsers = {};
  final Map<String, String> _selectedUsersNames = {}; // To store selected users' names

  @override
  void initState() {
    super.initState();
    _blockedContactsFuture = widget.appRepository.getBlockedContacts(widget.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<String>>(
            future: _blockedContactsFuture,
            builder: (context, blockedSnapshot) {
              if (blockedSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (blockedSnapshot.hasError) {
                return Center(child: Text('Erreur: ${blockedSnapshot.error}'));
              } else if (blockedSnapshot.hasData) {
                final blockedContacts = blockedSnapshot.data!;
                return FutureBuilder<List<AppUser>>(
                  future: widget.appRepository.getAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final users = snapshot.data!.where((user) => user.email != FirebaseAuth.instance.currentUser?.email).toList();
                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _buildUserListTileWidget(context, user, blockedContacts);
                        },
                      );
                    } else {
                      return const Center(child: Text('Aucun utilisateur trouvé'));
                    }
                  },
                );
              } else {
                return const Center(child: Text('Erreur lors de la récupération des utilisateurs bloqués.'));
              }
            },
          ),
        ),
        if (_selectedUsers.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _createGroupMessage,
              child: const Text('Créer une conversation'),
            ),
          ),
      ],
    );
  }

  Widget _buildUserListTileWidget(BuildContext context, AppUser user, List<String> blockedContacts) {
    final isFriend = widget.contacts.contains(user.id); // Changed to use id
    final isBlocked = blockedContacts.contains(user.id); // Changed to use id
    final isSelected = _selectedUsers.contains(user.email); // Changed to use email

    return UserListTileWidget(
      pseudo: user.pseudo,
      email: user.email,
      isFriend: isFriend,
      isBlocked: isBlocked,
      isSelected: isSelected,
      onSelectedChanged: (bool? selected) {
        setState(() {
          if (selected == true) {
            _selectedUsers.add(user.email); // Changed to use email
            _selectedUsersNames[user.email] = user.pseudo; // Store the user's name
          } else {
            _selectedUsers.remove(user.email); // Changed to use email
            _selectedUsersNames.remove(user.email); // Remove the user's name
          }
        });
      },
      onAddPressed: () async {
        if (!isFriend) {
          try {
            await widget.appRepository.addContact(widget.currentUserId, user.id); // Changed to use id
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact ajouté avec succès.')));
            widget.contacts.add(user.id); // Changed to use id
            setState(() {}); // To rebuild the widget with the new state
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de l\'ajout du contact.')));
          }
        }
      },
      onBlockPressed: () async {
        if (isBlocked) {
          try {
            await widget.appRepository.unblockUser(widget.currentUserId, user.id); // Changed to use id
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact débloqué avec succès.')));
            blockedContacts.remove(user.id); // Changed to use id
            setState(() {}); // To rebuild the widget with the new state
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors du déblocage du contact.')));
          }
        } else if (isFriend) {
          try {
            await widget.appRepository.blockUser(widget.currentUserId, user.id); // Changed to use id
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact bloqué avec succès.')));
            blockedContacts.add(user.id); // Changed to use email
            setState(() {}); // To rebuild the widget with the new state
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors du blocage du contact.')));
          }
        }
      },
    );
  }

  Future<void> _createGroupMessage() async {
    if (_selectedUsers.isNotEmpty) {
      final selectedEmails = _selectedUsers.toList();
      selectedEmails.add(FirebaseAuth.instance.currentUser!.email!); // Add the current user's email

      // Check if it's a private conversation (2 participants)
      if (selectedEmails.length == 2) {
        final user1Email = selectedEmails[0];
        final user2Email = selectedEmails[1];
        final conversationExists = await widget.appRepository.privateConversationExists(user1Email, user2Email);
        if (conversationExists) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Une conversation privée existe déjà entre ces utilisateurs.')));
          return;
        }
      }

      // Create group name from selected users' names
      final groupName = _selectedUsersNames.values.join(', ');
      await widget.appRepository.createGroupMessage(groupName, selectedEmails);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conversation créée avec succès.')));

      Navigator.pop(context);
    }
  }
}