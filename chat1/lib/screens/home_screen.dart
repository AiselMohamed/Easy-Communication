import 'package:chat1/screens/profile_screen.dart';
import 'package:chat1/widgets/color.dart';
import 'package:flutter/material.dart';
import '../widgets/contact_list_widget.dart';
import '../widgets/side_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  bool _isSearching = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: ProfileScreen(),
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        title: Text(
          "Messaging",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white), // Set icon color here
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
              if (_isSearching) {
                _focusNode.requestFocus();
              } else {
                _focusNode.unfocus();
              }
            },
          )
        ],
      ),

      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 70,
            color: Colors.blueGrey[900],
          ),
          Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              color: Colors.white,
            ),
            child: Column(
              children: [
                if (_isSearching) SizedBox(height: 10),
                if (_isSearching)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      focusNode: _focusNode,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                Expanded(
                  child: ContactListWidget(searchQuery: _searchQuery),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
