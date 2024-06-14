import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:translator/translator.dart';

import '../providers/contact_list.dart';
import '../services/push_notifications.dart';
import '../widgets/chatscreen/contact_message_blob.dart';
import '../widgets/chatscreen/emoji_picker.dart';
import '../widgets/chatscreen/user_message_blob.dart';

class ChatScreen extends StatelessWidget {
  static const routeName = '/chat';

  final _chatBodyOffsetHeight = StreamController<double>.broadcast();

  @override
  Widget build(BuildContext context) {
    final passedArgs =
    ModalRoute.of(context)!.settings.arguments as Map<String, Object>;
    final String chatID = passedArgs['chatID'] as String;
    final DocumentSnapshot contactDetails =
    passedArgs['contactDetails'] as DocumentSnapshot;
    final ContactList _contactList = ContactList();
    return WillPopScope(
      onWillPop: () {
        _chatBodyOffsetHeight.close(); // Dispose the StreamController
        _contactList.displayLastMessage(contactDetails.id);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.blueGrey[900]),
          title: Text(
            contactDetails['username'],
            style: TextStyle(color: Colors.blueGrey[900]),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.call_outlined,
                color: Colors.blueGrey[900],
              ),
              onPressed: () {},
            )
          ],
        ),
        backgroundColor: Colors.blueGrey[900],
        body: Stack(
          children: [
            ChatBody(
              chatID: chatID,
              contactDetails: contactDetails,
              chatBodyOffsetHeight: _chatBodyOffsetHeight,
            ),
            ChatInput(
              chatID: chatID,
              contactDetails: contactDetails,
              chatBodyOffsetHeight: _chatBodyOffsetHeight,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBody extends StatelessWidget {
  final String chatID;
  final DocumentSnapshot contactDetails;
  final StreamController<double> chatBodyOffsetHeight;

  const ChatBody({
    Key? key,
    required this.chatID,
    required this.contactDetails,
    required this.chatBodyOffsetHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ContactList _contactList = ContactList();

    return StreamBuilder(
      stream: chatBodyOffsetHeight.stream,
      builder: (context, snapshot) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          height: size.height - 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatID)
                      .collection(chatID)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isNotEmpty) {
                      String lastMessage =
                      snapshot.data!.docs[0]['content'] as String;
                      String dispMessage = lastMessage.length > 50
                          ? lastMessage.replaceRange(50, lastMessage.length, '...')
                          : lastMessage;
                      dispMessage =
                      snapshot.data!.docs[0]['fromID'] == contactDetails.id
                          ? dispMessage
                          : 'YOU: ' + dispMessage;
                      _contactList.updateLastMessage(
                          contactDetails.id, dispMessage);
                    }

                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.only(bottom: 10),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        QueryDocumentSnapshot doc = snapshot.data!.docs[index];
                        if (doc['fromID'] == contactDetails.id) {
                          return ContactMessageBlob(
                            messageDetails: doc,
                            contactDetails: contactDetails,
                          );
                        } else {
                          return UserMessageBlob(messageDetails: doc);
                        }
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: snapshot.data ?? 0),
            ],
          ),
        );
      },
    );
  }
}

class ChatInput extends StatefulWidget {
  final String chatID;
  final DocumentSnapshot contactDetails;
  final StreamController<double> chatBodyOffsetHeight;

  const ChatInput({
    Key? key,
    required this.chatID,
    required this.contactDetails,
    required this.chatBodyOffsetHeight,
  }) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();
  final GoogleTranslator translator = GoogleTranslator(); // Initialize the translator

  late DocumentSnapshot _userDetails;

  bool _isKeyboardVisible = false;
  bool _isEmojiBoardVisible = false;

  @override
  void initState() {
    super.initState();
    KeyboardVisibilityController().onChange.listen((bool isKeyboardVisible) {
      _isKeyboardVisible = isKeyboardVisible;
      _isKeyboardVisible
          ? widget.chatBodyOffsetHeight.add(45.0)
          : widget.chatBodyOffsetHeight.add(0.0);
      if (_isKeyboardVisible && mounted) {
        setState(() {
          _isEmojiBoardVisible = false;
        });
      }
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((userDocument) => _userDetails = userDocument);
  }

  Future<void> _showLanguageDialog() async {
    String? selectedLanguage = await showDialog<String>(
      context: context,
      builder: (context) {
        return LanguageSelectionDialog();
      },
    );

    if (selectedLanguage != null && selectedLanguage.isNotEmpty) {
      _translateAndSendMessage(selectedLanguage);
    }
  }

  void _translateAndSendMessage(String targetLanguage) async {
    String originalMessage = _inputController.text.trim();
    if (originalMessage.isEmpty) return;

    var translation = await translator.translate(originalMessage, to: targetLanguage);
    String translatedMessage = translation.text;

    _sendMessage(translatedMessage);
  }

  void _sendMessage(String message) {
    String _enteredMessage = message.trim();
    if (_enteredMessage.isEmpty) return;
    _inputController.clear();

    final timeStamp = Timestamp.now();
    final myUserID = FirebaseAuth.instance.currentUser!.uid;
    var newMessage = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatID)
        .collection(widget.chatID)
        .doc(timeStamp.millisecondsSinceEpoch.toString());

    newMessage.set({
      'type': 0,
      'fromID': myUserID,
      'toID': widget.contactDetails.id,
      'content': _enteredMessage,
      'timestamp': timeStamp,
    });

    String notificationMessage = _enteredMessage.length > 50
        ? _enteredMessage.replaceRange(50, _enteredMessage.length, '...')
        : _enteredMessage;
    PushNotifications.sendNotification(
        title: _userDetails['username'] as String,
        message: notificationMessage,
        chatID: widget.chatID,
        userID: myUserID,
        notificationToken: widget.contactDetails['notificationtoken'] as String);
  }

  void _toggleEmojiKeyboard() async {
    if (_isKeyboardVisible) {
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
      await Future.delayed(Duration(milliseconds: 100));
    } else if (_isEmojiBoardVisible) {
      _focusNode.unfocus();
      _focusNode.requestFocus();
    }
    setState(() {
      _isEmojiBoardVisible = !_isEmojiBoardVisible;
    });
    _isEmojiBoardVisible
        ? widget.chatBodyOffsetHeight.add(270.0)
        : widget.chatBodyOffsetHeight.add(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
    Card(
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    IconButton(
    icon: Icon(_isEmojiBoardVisible
    ? Icons.keyboard_outlined
        : Icons.emoji_emotions_outlined),
    onPressed: _toggleEmojiKeyboard,
    ),
    Expanded(
    child: TextField(
    controller: _inputController,
    focusNode: _focusNode,
    decoration: InputDecoration(
    border: InputBorder.none,
    hintText: 'Type a message...',
    ),
    ),
    ),
    IconButton(
    icon:                Icon(Icons.translate),
      onPressed: _showLanguageDialog, // Show the language selection dialog
    ),
      IconButton(
        icon: Icon(Icons.send_outlined),
        onPressed: () => _sendMessage(_inputController.text),
      ),
    ],
    ),
    ),
          SizedBox(
            height: 5,
          ),
          Offstage(
            child: Text("d"),
            offstage: !_isEmojiBoardVisible,
          )
        ],
    );
  }
}

class LanguageSelectionDialog extends StatefulWidget {
  @override
  _LanguageSelectionDialogState createState() =>
      _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _languages = [
    {'name': 'Spanish', 'code': 'es'},
    {'name': 'French', 'code': 'fr'},
    {'name': 'German', 'code': 'de'},
    {'name': 'Italian', 'code': 'it'},
    {'name': 'Portuguese', 'code': 'pt'},
    {'name': 'Russian', 'code': 'ru'},
    {'name': 'Chinese', 'code': 'zh'},
    {'name': 'Japanese', 'code': 'ja'},
    {'name': 'Korean', 'code': 'ko'},
    {'name': 'Hindi', 'code': 'hi'},
    {'name': 'Arabic', 'code': 'ar'},
    {'name': 'Bengali', 'code': 'bn'},
    {'name': 'Greek', 'code': 'el'},
    {'name': 'Hebrew', 'code': 'he'},
    {'name': 'Indonesian', 'code': 'id'},
    {'name': 'Malay', 'code': 'ms'},
    {'name': 'Turkish', 'code': 'tr'},
    {'name': 'Vietnamese', 'code': 'vi'},
    {'name': 'Urdu', 'code': 'ur'},
    {'name': 'English', 'code': 'en'},
    // Add more languages here as needed
  ];
  List<Map<String, String>> _filteredLanguages = [];

  @override
  void initState() {
    super.initState();
    _filteredLanguages = _languages;
    _searchController.addListener(_filterLanguages);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLanguages);
    _searchController.dispose();
    super.dispose();
  }

  void _filterLanguages() {
    setState(() {
      _filteredLanguages = _languages
          .where((language) =>
          language['name']!
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Language'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: ListBody(
                children: _filteredLanguages.map((language) {
                  return ListTile(
                    title: Text(language['name']!),
                    onTap: () {
                      Navigator.of(context).pop(language['code']);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

