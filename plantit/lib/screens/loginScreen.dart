import 'package:flutter/material.dart';
import 'package:plantit/main.dart';
import 'package:plantit/screens/resetPssword.dart';
import '../reusable/reusableWidget.dart';
import '../reusable/reusableFuncs.dart';
import 'dart:convert';
import 'rootScreen.dart';
import 'package:http/http.dart' as http;

/// this is the LoginScreen screen - log in to the app

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffbfd9cc), Color(0xff8ccaaf), Color(0xff59bf96), Color.fromARGB(255, 7, 163, 111)]
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.10, 20, 0),
            child: Column(
              children: <Widget>[
                titleWidget("Sign In"),
                const SizedBox(height: 20),
                logoWidget("assets/images/logo.png", 240, 240),
                const Text("PlantIt", style: TextStyle(fontSize: 50, fontFamily: "IndieFlower",color: Colors.white),),
                reusableTextField("Enter Email", Icons.email_outlined, false, emailTextController),
                const SizedBox(height: 20),
                reusableTextField("Enter Password", Icons.lock_outline, true, passwordTextController),
                const SizedBox(height: 5),
                forgotPassword(context),
                senToServerButton(context, "LOG IN",  (){signIn(context);}),
                loginSignupOption(context, false, "New to PlantIt ? ", "Sign Up", () {
                  emailTextController.clear();
                  passwordTextController.clear();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // fetch all the plants in db
  Future<List<dynamic>> fetchPlants() async {
    final response = await http.get(Uri.parse('$serverUrl/plants'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON response
      return jsonDecode(response.body);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load plants');
    }
  }



  //the sign in function
  void signIn(BuildContext context) async {
    //check that all fields are not empty
    if(emailTextController.text == "" || passwordTextController.text == "" ) {
      showSnackbar(context, "Please fill all fields.");
      return;
    }
    //send data to server in order to login
    String theEmail;
    var db = await fetchPlants();
    await http.post(
        Uri.parse("$serverUrl/login" ),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "email" : emailTextController.text.toLowerCase(),
          "password" : passwordTextController.text,
        })).then((value) => {
      if(value.statusCode == 200) {

        theEmail = emailTextController.text.toLowerCase(),
        emailTextController.clear(),
        passwordTextController.clear(),
        // If the server did return a 200 response,
        //then move to home screen
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => RootScreen(userEmail: theEmail, plantDb: db,))),
      } else {
        // If the server did not return a 200 response,
        // then show snackbar.
        showSnackbar(context, "Email or password are incorrect.")
      }
    });
  }

  Widget forgotPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () {
          emailTextController.clear();
          passwordTextController.clear();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ResetPassword()));
        },
      ),
    );
  }
}

