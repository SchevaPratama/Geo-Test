import 'package:flutter/material.dart';
import 'package:geolocator_app/pages/homepage.dart';
import 'package:geolocator_app/pages/signin.dart';
import 'package:geolocator_app/services/authservice.dart';
import 'package:geolocator_app/services/databaseservices.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  AuthService authService = AuthService();
  DatabaseService databaseService = DatabaseService();
  TextEditingController usernameTexteditingController =
      new TextEditingController();
  TextEditingController emailTexteditingController =
      new TextEditingController();

  TextEditingController passwordTexteditingController =
      new TextEditingController();

  signMeUp(String role) {
    if (formKey.currentState!.validate()) {
      print(role);
      setState(() {
        isLoading = true;
      });

      authService.SignUpWithEmailAndPassword(
        emailTexteditingController.text,
        passwordTexteditingController.text,
        usernameTexteditingController.text,
        role,
      ).then((val) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: isLoading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 50,
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              validator: (val) {
                                return val!.isEmpty || val.length < 2
                                    ? "Please Enter Username Correctly"
                                    : null;
                              },
                              controller: usernameTexteditingController,
                              style: TextStyle(
                                color: Color(0xFF023e8a),
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                  hintText: 'Username',
                                  hintStyle:
                                      TextStyle(color: Color(0xFF023e8a)),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF023e8a)),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Color(0xFF023e8a),
                                  ))),
                            ),
                            TextFormField(
                              validator: (val) {
                                return RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(val!)
                                    ? null
                                    : "Enter correct email";
                              },
                              controller: emailTexteditingController,
                              style: TextStyle(
                                color: Color(0xFF023e8a),
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle:
                                      TextStyle(color: Color(0xFF023e8a)),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF023e8a)),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Color(0xFF023e8a),
                                  ))),
                            ),
                            TextFormField(
                              validator: (val) {
                                return val!.length < 6
                                    ? "Enter Password 6+ characters"
                                    : null;
                              },
                              obscureText: true,
                              controller: passwordTexteditingController,
                              style: TextStyle(
                                color: Color(0xFF023e8a),
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle:
                                      TextStyle(color: Color(0xFF023e8a)),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF023e8a)),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Color(0xFF023e8a),
                                  ))),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          signMeUp('master');
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xff007EF4),
                                  const Color(0xff2A75BC)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30)),
                          child: Text(
                            "Sign Up As Master",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onTap: () {
                          signMeUp('attendance');
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xff007EF4),
                                  const Color(0xff2A75BC)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30)),
                          child: Text(
                            "Sign Up As Attendance",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Already have account?",
                            style: TextStyle(
                              color: Color(0xFF023e8a),
                              fontSize: 16,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignIn()));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "Sign in now",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
