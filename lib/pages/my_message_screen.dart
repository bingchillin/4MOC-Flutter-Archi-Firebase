import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_flutter_firebase/pages/my_message_detail_screeen.dart';

class MyMessageScreen extends StatefulWidget {
  static const routeName = 'myMessageScreen';

  final String groupId;
  final String groupName;
  final String groupDescription;

  const MyMessageScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
  }) : super(key: key);

  @override
  _MyMessageScreenState createState() => _MyMessageScreenState();
}

class _MyMessageScreenState extends State<MyMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<String> getPseudo(String idPerson) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('person')
        .where('email', isEqualTo: idPerson)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['pseudo'] ?? 'Inconnu';
    }
    return 'Inconnu';
  }

  void sendMessage(String textMessage, String idPerson) async {
    if (textMessage.trim().isEmpty) return;

    User? currentUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('discuss_message').add({
      'date_creation': Timestamp.now(),
      'id_groupmessage': widget.groupId,
      'id_person': currentUser?.email ?? 'Unknown',
      'text_message': textMessage,
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.groupName),
            Text(
              widget.groupDescription,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              Navigator.of(context).pushNamed(
                'my_message_detail_screen',
                arguments: {
                  'groupId': widget.groupId,
                  'groupName': widget.groupName,
                  'groupDescription': widget.groupDescription,
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('discuss_message')
                  .orderBy('date_creation', descending: true) // Ordre inversé
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('Aucun message trouvé pour ce groupe'));
                }

                List<DocumentSnapshot> filteredDocs =
                snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data =
                  doc.data() as Map<String, dynamic>;
                  String docGroupId = data['id_groupmessage'];
                  return docGroupId == widget.groupId;
                }).toList();

                return ListView.builder(
                  controller: scrollController,
                  reverse: true,
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                    filteredDocs[index].data() as Map<String, dynamic>;
                    String messageText = data['text_message'] ?? 'Message vide';
                    String idPerson = data['id_person'];
                    Timestamp timestamp = data['date_creation'] as Timestamp;
                    DateTime dateTime = timestamp.toDate();

                    return FutureBuilder<String>(
                      future: getPseudo(idPerson),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator());
                        }
                        if (asyncSnapshot.hasError) {
                          return Center(
                              child: Text('Erreur : ${asyncSnapshot.error}'));
                        }
                        String pseudo = asyncSnapshot.data ?? 'Inconnu';
                        bool isCurrentUser =
                            idPerson == currentUser?.email;

                        return Align(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.green
                                  : Colors.blueGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCurrentUser ? 'Moi' : pseudo,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  messageText,
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute}',
                                  style: const TextStyle(
                                      color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                20, 8, 8, 16), // Ajout de padding supplémentaire en haut
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Entrez votre message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      MyMessageDetailScreen.routeName,
                      arguments: {
                        'groupId': widget.groupId,
                        'groupName': widget.groupName,
                        'groupDescription': widget.groupDescription,
                      },
                    );
                  },
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
