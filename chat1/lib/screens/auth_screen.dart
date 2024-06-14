import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:multiavatar/multiavatar.dart';
import '../services/push_notifications.dart';
import '../widgets/auth_form.dart';
import '../widgets/color.dart';
import 'home_screen.dart'; // Assuming you have a HomeScreen widget

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
      String email,
      String username,
      String password,
      bool isLogin,
      BuildContext ctx,
      ) async {
    UserCredential? authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String? notificationToken = await PushNotifications.getNotificationsToken();

        await FirebaseFirestore.instance.collection('users').doc(authResult.user!.uid).set({
          'username': username,
          'email': email,
          'imageURL': '',
          'notificationtoken': notificationToken,
        });
      }
    } on FirebaseAuthException catch (err) {
      var message = 'An error occurred. Please check your credentials.';

      if (err.message != null) {
        message = err.message!;
      }
      print('Firebase_Auth - ${err.message}');
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).colorScheme.error,
        ),
      );
    } catch (err) {
      print('Error: $err');
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Theme.of(ctx).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevents the keyboard from resizing the screen
      body: SingleChildScrollView(
        child: Column(
          children: [
            _top(),
            AuthForm(
              submitFunction: _submitAuthForm,
              isLoading: _isLoading,
            ),
            SizedBox(height: keyboardIsOpen ? 100 : 0), // Adds extra space when the keyboard is open
          ],
        ),
      ),
    );
  }
}

Widget _top() {
  return Container(
    height: 280,
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(60),
        bottomRight: Radius.circular(60),
      ),
      color: AppColor.primary,
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 100, // Adjust this value according to your logo size
            width: 100, // Adjust this value according to your logo size
            child: _buildLogo(),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Login",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLogo() {
  return Container(
    padding: EdgeInsets.all(10),
    width: 150,
    height: 150,
    child: CustomImage(
      "https://cdn-icons-png.flaticon.com/512/3820/3820331.png",
      isSVG: false,
      bgColor: AppColor.primary,
      radius: 5,
    ),
  );
}

class CustomImage extends StatelessWidget {
  const CustomImage(
      this.name, {
        this.width = 100,
        this.height = 100,
        this.bgColor,
        this.borderWidth = 0,
        this.borderColor,
        this.trBackground = false,
        this.isSVG = true,
        this.radius = 50,
      });

  final String name;
  final double width;
  final double height;
  final double borderWidth;
  final Color? borderColor;
  final Color? bgColor;
  final bool trBackground;
  final bool isSVG;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return isSVG ? _buildSVG(context) : _buildNetworkImage(context);
  }

  Widget _buildNetworkImage(context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        image: DecorationImage(
          image: NetworkImage(name),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSVG(context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Theme.of(context).cardColor,
          width: borderWidth,
        ),
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.string(
        multiavatar(name, trBackground: trBackground),
      ),
    );
  }
}

class Constants {
  Constants._();
  static const double padding = 20;
  static const double avatarRadius = 45;
}