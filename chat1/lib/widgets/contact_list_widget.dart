import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/contact_list.dart';
import '../screens/chat_screen.dart';

class ContactListWidget extends StatelessWidget {
  final String searchQuery;

  const ContactListWidget({Key? key, required this.searchQuery}) : super(key: key);

  Widget _userAvatar(String imageURL) {
    return Container(
      width: 60, // Adjust the size as needed
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blueGrey, width: 2), // Add border
      ),
      child: ClipOval(
        child: imageURL == null || imageURL.isEmpty
            ? Container(
          color: Colors.white,
          child: Icon(
            Icons.perm_identity_rounded,
            size: 40,
            color: Colors.blueGrey,
          ),
        )
            : Image.network(
          imageURL,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context, ContactInfo contactInfo) async {
    final myUserID = FirebaseAuth.instance.currentUser!.uid;
    final contactUserID = contactInfo.id;
    final chatID = (myUserID.hashCode >= contactUserID.hashCode)
        ? '$myUserID-$contactUserID'
        : '$contactUserID-$myUserID';

    DocumentSnapshot contactDetails = await FirebaseFirestore.instance
        .collection('users')
        .doc(contactUserID)
        .get();

    ContactList().updateUnreadMessage(contactInfo.id, false);
    Navigator.pushNamed(context, ChatScreen.routeName,
        arguments: {'chatID': chatID, 'contactDetails': contactDetails});
  }

  @override
  Widget build(BuildContext context) {
    List<ContactInfo> _contactList =
        Provider.of<ContactList>(context).contactList;

    // Filter contact list based on search query
    List<ContactInfo> _filteredContactList = _contactList.where((contact) {
      return contact.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: _filteredContactList.length,
      padding: EdgeInsets.only(left: 15, right: 15, top: 20),
      itemBuilder: (ctx, index) {
        return ListTile(
          title: Text(
            _filteredContactList[index].name,
            style: TextStyle(fontSize: 20),
          ),
          subtitle: Text(
            _filteredContactList[index].lastMessage,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: _filteredContactList[index].isUnreadMessage
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: _filteredContactList[index].isUnreadMessage
                    ? Colors.black
                    : Colors.grey[600]),
          ),
          leading: _userAvatar(_filteredContactList[index].avatar),
          trailing: Icon(_filteredContactList[index].isUnreadMessage
              ? Icons.mark_chat_unread
              : Icons.chat_outlined),
          onTap: () {
            _navigateToChat(context, _filteredContactList[index]);
          },
        );
      },
    );
  }
}
