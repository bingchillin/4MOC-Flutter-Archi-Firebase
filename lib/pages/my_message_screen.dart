import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;

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
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  static const int maxSize = 5 * 1024 * 1024; // on peut pas plus de 5 Mo sur le storage firebase

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

  Future<void> sendMessage({String? textMessage, String? imageUrl}) async {
    if (textMessage == null && imageUrl == null) return;

    User? currentUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('discuss_message').add({
      'date_creation': Timestamp.now(),
      'id_groupmessage': widget.groupId,
      'id_person': currentUser?.email ?? 'Unknown',
      'text_message': textMessage ?? '',
      'path_image': imageUrl ?? '',
    });

    messageController.clear();
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File imageFile = File(image.path);
        if (await imageFile.length() > maxSize) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Erreur'),
              content: Text('Le fichier sélectionné est trop volumineux. Veuillez choisir un fichier de moins de 5 Mo.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        } else {
          setState(() {
            _selectedImage = image;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> resizeAndUploadImage() async {
    if (_selectedImage != null) {
      File imageFile = File(_selectedImage!.path);

      img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

      if (image != null) {
        img.Image resizedImage = img.copyResize(image, width: 600);
        File resizedFile = File('${imageFile.parent.path}/resized_${imageFile.uri.pathSegments.last}');
        resizedFile.writeAsBytesSync(img.encodePng(resizedImage));

        await uploadImage(resizedFile);
      }
    }
  }

  Future<void> uploadImage(File imageFile) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
    Reference storageReference = FirebaseStorage.instance.ref().child('chat_images').child(fileName);

    try {
      UploadTask uploadTask = storageReference.putFile(imageFile);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: $progress%');
      });

      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
      String imageUrl = await snapshot.ref.getDownloadURL();
      print('Image URL: $imageUrl');

      await sendMessage(imageUrl: imageUrl, textMessage: messageController.text.trim());
    } catch (e) {
      print('Error uploading image: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text('Une erreur est survenue lors du téléchargement de l\'image.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
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
                  'personId': currentUser?.email
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              groupId: widget.groupId,
              scrollController: scrollController,
              getPseudo: getPseudo,
              currentUserEmail: currentUser?.email,
            ),
          ),
          MessageInput(
            messageController: messageController,
            pickImage: pickImage,
            resizeAndUploadImage: resizeAndUploadImage,
            sendMessage: () => sendMessage(textMessage: messageController.text.trim()),
            selectedImage: _selectedImage,
          ),
        ],
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  final String groupId;
  final ScrollController scrollController;
  final Future<String> Function(String) getPseudo;
  final String? currentUserEmail;

  const MessageList({
    Key? key,
    required this.groupId,
    required this.scrollController,
    required this.getPseudo,
    this.currentUserEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('discuss_message')
          .orderBy('date_creation', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur : ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucun message trouvé pour ce groupe'));
        }

        List<DocumentSnapshot> filteredDocs = snapshot.data!.docs.where((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String docGroupId = data['id_groupmessage'];
          return docGroupId == groupId;
        }).toList();

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data = filteredDocs[index].data() as Map<String, dynamic>;
            String messageText = data['text_message'] ?? 'Message vide';
            String imageUrl = data['path_image'] ?? '';
            String idPerson = data['id_person'];
            Timestamp timestamp = data['date_creation'] as Timestamp;
            DateTime dateTime = timestamp.toDate();

            return FutureBuilder<String>(
              future: getPseudo(idPerson),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (asyncSnapshot.hasError) {
                  return Center(child: Text('Erreur : ${asyncSnapshot.error}'));
                }
                String pseudo = asyncSnapshot.data ?? 'Inconnu';
                bool isCurrentUser = idPerson == currentUserEmail;

                return MessageTile(
                  pseudo: pseudo,
                  messageText: messageText,
                  imageUrl: imageUrl,
                  dateTime: dateTime,
                  isCurrentUser: isCurrentUser,
                );
              },
            );
          },
        );
      },
    );
  }
}

class MessageTile extends StatelessWidget {
  final String pseudo;
  final String messageText;
  final String imageUrl;
  final DateTime dateTime;
  final bool isCurrentUser;

  const MessageTile({
    Key? key,
    required this.pseudo,
    required this.messageText,
    required this.imageUrl,
    required this.dateTime,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.green : Colors.blueGrey,
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
            if (messageText.isNotEmpty)
              Text(
                messageText,
                style: const TextStyle(color: Colors.white),
              ),
            if (imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(
                  imageUrl,
                  errorBuilder: (context, error, stackTrace) {
                    return Text('Erreur de chargement de l\'image');
                  },
                ),
              ),
            SizedBox(height: 4),
            Text(
              '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageInput extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback pickImage;
  final VoidCallback resizeAndUploadImage;
  final VoidCallback sendMessage;
  final XFile? selectedImage;

  const MessageInput({
    Key? key,
    required this.messageController,
    required this.pickImage,
    required this.resizeAndUploadImage,
    required this.sendMessage,
    this.selectedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: pickImage,
          ),
          if (selectedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.file(
                File(selectedImage!.path),
                width: 50,
                height: 50,
              ),
            ),
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
            icon: Icon(Icons.send),
            onPressed: () {
              if (messageController.text.trim().isNotEmpty || selectedImage != null) {
                if (selectedImage != null) {
                  resizeAndUploadImage();
                } else {
                  sendMessage();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
