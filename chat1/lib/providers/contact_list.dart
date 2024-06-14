import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'contact_list.g.dart';

@HiveType(typeId: 0)
class ContactInfo extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String name;
  @HiveField(2)
  late String avatar;
  @HiveField(3)
  late String lastMessage;
  @HiveField(4)
  late bool isUnreadMessage;
  @HiveField(5)
  late int lastMesTimestamp;

  ContactInfo.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> userDocument) {
    if (userDocument.exists) {
      id = userDocument.id;
      name = userDocument.data()?.containsKey('username') == true
          ? userDocument['username']
          : '<bad_schema_rbk>';
      avatar = userDocument.data()?.containsKey('imageURL') == true
          ? userDocument['imageURL']
          : '<bad_schema_rbk>';
    }
    lastMessage = '';
    isUnreadMessage = false;
    lastMesTimestamp = 0;
    Hive.openBox<ContactInfo>("contact_list")
        .then((box) => box.put(this.id, this))
        .catchError((error) => print("Error opening Hive box: $error"));
  }

  // default constructor with no parameters (for hive typeAdapter)
  ContactInfo();

  void update(DocumentSnapshot<Map<String, dynamic>> userDocument) {
    if (userDocument.exists) {
      id = userDocument.id;
      name = userDocument.data()?.containsKey('username') == true
          ? userDocument['username']
          : name;
      avatar = userDocument.data()?.containsKey('imageURL') == true
          ? userDocument['imageURL']
          : avatar;
      save();
    }
  }
}

class ContactList extends ChangeNotifier {
  List<ContactInfo> _contacts = [];

  ContactList._() {
    _init();
  }

  static final ContactList _instance = ContactList._();

  factory ContactList() => _instance;

  List<ContactInfo> get contactList => [..._contacts];

  Future<void> _init() async {
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(ContactInfoAdapter());
      var box = await Hive.openBox<ContactInfo>("contact_list");
      _contacts.addAll(box.values);
      _contacts.sort((a, b) => b.lastMesTimestamp.compareTo(a.lastMesTimestamp));
    } catch (error) {
      print("Error initializing Hive: $error");
    }

    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .snapshots()
            .listen((userSnapshot) {
          final currentUserID = FirebaseAuth.instance.currentUser!.uid;
          for (var change in userSnapshot.docChanges) {
            if (change.doc.id == currentUserID) continue;
            int index = _contacts.indexWhere((element) => element.id == change.doc.id);
            if (index == -1) {
              _contacts.add(ContactInfo.fromSnapshot(change.doc));
            } else {
              _contacts[index].update(change.doc);
            }
          }
          notifyListeners();
        });
      }
    });
  }

  void updateLastMessage(String contactID, String message) {
    int index = _contacts.indexWhere((element) => element.id == contactID);
    if (index != -1) {
      ContactInfo contactinfo = _contacts[index];
      if (contactinfo.lastMessage != message) {
        contactinfo.lastMessage = message;
        contactinfo.lastMesTimestamp = DateTime.now().millisecondsSinceEpoch;
        _contacts.removeAt(index);
        _contacts.insert(0, contactinfo);
        // notifyListeners(); // You might want to uncomment this if you're using ChangeNotifierProvider
      }
    }
  }

  void displayLastMessage(String contactID) {
    int index = _contacts.indexWhere((element) => element.id == contactID);
    if (index != -1) {
      ContactInfo contactinfo = _contacts[index];
      contactinfo.save();
      notifyListeners();
    }
  }

  void updateUnreadMessage(String contactID, bool isUnread) {
    int index = _contacts.indexWhere((element) => element.id == contactID);
    if (index != -1) {
      ContactInfo contactinfo = _contacts[index];
      contactinfo.isUnreadMessage = isUnread;
      _contacts[index] = contactinfo;
      contactinfo.save();
    }
  }
}
