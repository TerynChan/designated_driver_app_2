import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/pages/home_page.dart';
import 'package:designated_driver_app_2/widgets/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController usernameTextEditingController = TextEditingController();

  //form validation and signup method
  validateSignupForm(){

    //declaration of signuser function with firebase 
    signUserNow() async {

      //loading screen while signing up
      showDialog(context: context, builder: (BuildContext context)=> LoadingScreen());
        try{
          final User? firebaseUser = (
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: emailTextEditingController.text.trim(), 
              password: passwordTextEditingController.text.trim()
              ).catchError((onError){
                  Navigator.pop(context);
                  associateMethods.showSnackBarMsg(onError.toString(), context);
                })
          ).user;

          Map userDataMap = {
            "name" : usernameTextEditingController.text.trim(),
            "email" : emailTextEditingController.text.trim(),
            "phone" : phoneTextEditingController.text.trim(),
          };

          FirebaseDatabase.instance.ref().child('users').child(firebaseUser!.uid).set(userDataMap);
          Navigator.pop(context);
          associateMethods.showSnackBarMsg("account created successfully", context);
          Navigator.push(context, MaterialPageRoute(builder: (c)=> const HomePage())); //redirect user to homepage
        }
        on FirebaseAuthException catch(e){
          FirebaseAuth.instance.signOut();
          Navigator.pop(context);
          associateMethods.showSnackBarMsg(e.toString(), context);
        }
      }

    //form validation logic
    if (usernameTextEditingController.text.trim().length <3) {
          associateMethods.showSnackBarMsg('name must be atleast three characters', context);
    }

    else if (!emailTextEditingController.text.trim().contains("@")) {
          associateMethods.showSnackBarMsg('please enter a valid email ', context);
    }

    else if (!emailTextEditingController.text.trim().contains("@")) {
          associateMethods.showSnackBarMsg('please enter a valid email ', context);
    }

    else if (phoneTextEditingController.text.trim().length < 7) {
          associateMethods.showSnackBarMsg('please enter a valid phone number ', context);
    }

    else{
      signUserNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
            const SizedBox(height: 100),

            Image.asset("assets/signup.webp", 
              width: MediaQuery.of(context).size.width * .6,
            ),

            const SizedBox(height: 20),

            Text("Sign Up as new User", 
            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold,),),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [

                  TextField(
                    controller: usernameTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "username",
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      hintText: "Enter your username",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "email",
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      hintText: "Enter your email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: phoneTextEditingController,
                    decoration: InputDecoration(
                      labelText: "Phone",
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      hintText: "enter your phone number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      hintText: "Enter your password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  ElevatedButton(onPressed: () {
                    // signup logic using firebase
                    validateSignupForm();
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green
                    ), child: const Text("Sign Up", style: TextStyle(color: Colors.white),),
                  ),
                  
                  const SizedBox(height: 20),

                  TextButton(onPressed: () {
                    // Handle forgot password logic here
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SigninPage()));
                  }, child: const Text("Already have an account? sign in here"),),
                  
                ],
              ),
            )
          ],
          ),
        ),
      ),
    );
  }
}