import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelapp/ui/resetPassword.dart';
import 'package:travelapp/ui/signup.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import 'customPageRoutes.dart';
import 'login.dart';

class welcomePage extends StatefulWidget {
  const welcomePage({super.key});

  @override
  State<welcomePage> createState() => _welcomePageState();
}

class _welcomePageState extends State<welcomePage> {
  final emailController = TextEditingController();
  bool isEmailEmpty = false;
  List curruntEmails = [];
  bool showError = false;
  var userId = '';
  late userBloc userbloc;
  late StreamSubscription mSub;

  @override
  void initState() {
    super.initState();
    userbloc = BlocProvider.of<userBloc>(context);

    // Listen for Firebase auth changes (for Google Sign-In)
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted) {
        Get.offNamed('/home');
      }
    });

    mSub = userbloc.stream.listen((state) {
      if (state is resetPasswordState &&
          state.resetState[0]['isSend'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("password reset message sent to the email")));
      } else if (state is checkEmailAlreadyExistState) {
        if (state.userState[0]['isFound'] == true) {
          showError = false;
          Navigator.of(context).pushReplacement(customPageRoutes(
              child: login(userData: state.userState[0]['userDetails'])));
        } else {
          setState(() {
            showError = true;
          });
        }
      } else if (state is googleSignInErrorState) {
        // Show dialog with Google Sign-In result
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Google Sign-In Result'),
            content: SingleChildScrollView(
              child: Text(state.errorMessage),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          bool confirmExit = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Exit'),
                content: const Text('Are you sure you want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      // User confirmed exit
                      SystemNavigator.pop();
                    },
                    child: const Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () {
                      // User canceled exit
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('No'),
                  ),
                ],
              );
            },
          );

          return confirmExit;
        },
        child: GestureDetector(
            onTap: () {
              // Dismiss the keyboard when the user taps outside of the text fields
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
                body: SafeArea(
                    child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Container(
                          height: 700.0,
                          // ignore: prefer_const_constructors
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/images/app bac.jpg'),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),

                          // ignore: prefer_const_constructors
                          child: Center(
                              // ignore: sort_child_properties_last
                              child: Container(
                            margin: showError
                                ? const EdgeInsets.only(top: 75.0)
                                : const EdgeInsets.only(top: 110.0),
                            child: Column(
                              // ignore: prefer_const_literals_to_create_immutables
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: showError,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 250,
                                        height: 30,
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                            borderRadius:
                                                BorderRadius.circular(17)),
                                        margin: const EdgeInsets.only(
                                            left: 50.0, bottom: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                                "This email address is not valid!",
                                                style: GoogleFonts.lato(
                                                    // ignore: prefer_const_constructors
                                                    textStyle: TextStyle(
                                                  color: const Color.fromARGB(
                                                      255, 255, 0, 0),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ))),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          left: 100.0, bottom: 0.0),
                                      child: Text("Welcome to",
                                          style: GoogleFonts.lato(
                                              // ignore: prefer_const_constructors
                                              textStyle: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                          ))),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(height: 0),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 30.0, top: 0.0),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 99.0, top: 0.0),
                                        child: Text(
                                          "F travel",
                                          style: GoogleFonts.pacifico(
                                            // ignore: prefer_const_constructors
                                            textStyle: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontSize: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(left: 35.0),
                                      child: Container(
                                        // ignore: prefer_const_constructors
                                        width: 300,
                                        height: 400,
                                        margin:
                                            const EdgeInsets.only(left: 0.0),
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/Rectangle 1.png'),
                                              fit: BoxFit.cover),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            // ignore: prefer_const_literals_to_create_immutables

                                            children: [
                                              Row(
                                                // ignore: prefer_const_literals_to_create_immutables
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 12.0,
                                                            top: 12.0),
                                                    child: SizedBox(
                                                      width: 250,
                                                      height: isEmailEmpty
                                                          ? 60
                                                          : 40,
                                                      child: TextField(
                                                        onTap: () {
                                                          setState(() {
                                                            showError = false;
                                                          });
                                                        },
                                                        decoration:
                                                            InputDecoration(
                                                          filled: true,
                                                          fillColor: const Color
                                                              .fromARGB(255,
                                                              255, 255, 255),
                                                          hintText: 'Email',
                                                          errorText: isEmailEmpty
                                                              ? "Value Can't Be Empty"
                                                              : null,
                                                          border:
                                                              const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide.none,
                                                          ),
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16.0,
                                                                  vertical:
                                                                      12.0),
                                                        ),
                                                        controller:
                                                            emailController,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 12.0,
                                                            top: 12.0),
                                                    child: SizedBox(
                                                      width: 250,
                                                      height: 40,
                                                      child: TextButton(
                                                        onPressed: () async {
                                                          if (emailController
                                                              .text
                                                              .isNotEmpty) {
                                                            BlocProvider.of<
                                                                        userBloc>(
                                                                    context)
                                                                .add(readUserEmailEvent(
                                                                    emailController
                                                                        .text));
                                                          } else {
                                                            setState(() {
                                                              isEmailEmpty =
                                                                  true;
                                                            });
                                                          }
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStateProperty.all<
                                                                      Color>(
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      10,
                                                                      124,
                                                                      132)),
                                                          foregroundColor:
                                                              WidgetStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .white),
                                                        ),
                                                        child: Text(
                                                          'Continue',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 123.0,
                                                              top: 15.0),
                                                      child: Text(
                                                        "Or",
                                                        style:
                                                            GoogleFonts.roboto(
                                                          textStyle:
                                                              const TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      )),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 12.0,
                                                            top: 12.0),
                                                    child: SizedBox(
                                                      width: 250,
                                                      height: 40,
                                                      child: TextButton(
                                                        onPressed: () {
                                                          BlocProvider.of<
                                                                      userBloc>(
                                                                  context)
                                                              .add(
                                                                  signInWithGoogle());
                                                        }, //google signin function--
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStateProperty.all<
                                                                      Color>(
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      231,
                                                                      231,
                                                                      231)),
                                                          foregroundColor:
                                                              WidgetStateProperty.all<
                                                                      Color>(
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      0,
                                                                      0,
                                                                      0)),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 17.0),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                // ignore: prefer_const_literals_to_create_immutables
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            8.0),
                                                                    child: Image
                                                                        .asset(
                                                                      "assets/images/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png",
                                                                      width: 24,
                                                                      height:
                                                                          24,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    "Continue with Google",
                                                                    style: GoogleFonts
                                                                        .roboto(
                                                                      textStyle:
                                                                          const TextStyle(
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12.0),
                                                child: Row(
                                                  // ignore: prefer_const_literals_to_create_immutables
                                                  children: [
                                                    Text(
                                                      "Don't have an account?",
                                                      style: GoogleFonts.roboto(
                                                          color: const Color
                                                              .fromARGB(255,
                                                              255, 255, 255)),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pushReplacement(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            const signup()));
                                                      },
                                                      style: ButtonStyle(
                                                        padding:
                                                            WidgetStateProperty
                                                                .all<EdgeInsets>(
                                                                    EdgeInsets
                                                                        .zero),
                                                      ),
                                                      child: Text(
                                                        "Sign up",
                                                        style: GoogleFonts.roboto(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                27, 199, 211)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 12.0),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    const resetPasswordPage()));
                                                      },
                                                      style: ButtonStyle(
                                                        padding:
                                                            WidgetStateProperty
                                                                .all<EdgeInsets>(
                                                                    EdgeInsets
                                                                        .zero),
                                                      ),
                                                      child: Text(
                                                        "Forgot your password?",
                                                        style:
                                                            GoogleFonts.roboto(
                                                          color: const Color
                                                              .fromARGB(255, 27,
                                                              199, 211),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )),
                        ))))));
  }
}
