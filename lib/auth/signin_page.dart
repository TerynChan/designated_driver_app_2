import 'package:designated_driver_app_2/auth/signup_page.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/pages/driver_home_page.dart';
import 'package:designated_driver_app_2/pages/home_page.dart';
import 'package:designated_driver_app_2/widgets/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SigninPage extends StatefulWidget {
    
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  ValidateSignInForm(){

    SignInUserNow() async {
      showDialog(
        context: context, 
        builder: (BuildContext context)=> LoadingScreen()
      );

      try{
          final User? firebaseUser = (
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: emailTextEditingController.text.trim(), 
              password: passwordTextEditingController.text.trim(),       
              ).catchError((onError){
                  Navigator.pop(context);
                  associateMethods.showSnackBarMsg(onError.toString(), context);
                })
          ).user;

          if (firebaseUser != null){
            DatabaseReference ref = FirebaseDatabase.instance.ref().child('users').child(firebaseUser.uid);
            await ref.once().then((dataSnapshot){
              if(dataSnapshot.snapshot.value != null){
                
                userName = (dataSnapshot.snapshot.value as Map)["name"];
                userPhone = (dataSnapshot.snapshot.value as Map)["phone"];
                isDriver = (dataSnapshot.snapshot.value as Map)["isDriver"];

                associateMethods.showSnackBarMsg("logged in successfully", context);
                Navigator.push(
                  context, MaterialPageRoute(builder: (c) => (isDriver == true) ? DriverHomePage() : const HomePage())); // Redirect user or driver to homepage
                 
                            
              }
              else{
                 Navigator.pop(context); //removing loading screen view 
                FirebaseAuth.instance.signOut();
                associateMethods.showSnackBarMsg("user not found in records", context);
              }
            });
          }
          
      }

      on FirebaseAuthException catch(e){
          FirebaseAuth.instance.signOut();
          Navigator.pop(context);
          associateMethods.showSnackBarMsg(e.toString(), context);
      }
    }


    if(!emailTextEditingController.text.contains("@")){
      associateMethods.showSnackBarMsg("email is not valid", context);
    }

    else if(passwordTextEditingController.text.trim().length < 5 ){
      associateMethods.showSnackBarMsg("password must be 5 characters or more", context);
    }
    
    else{
      SignInUserNow();
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

            Image.asset("assets/signin.webp", 
              width: MediaQuery.of(context).size.width * .6,
            ),

            const SizedBox(height: 20),
            
            Text("Welcome !", 
             style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold,),
            ),
            
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [

                  TextField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
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
                    // Handle sign in logic here
                    ValidateSignInForm();
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green
                    ), child: const Text("Sign in", style: TextStyle( color: Colors.white),),
                  ),

        
                  const SizedBox(height: 20),

                  TextButton(onPressed: () {
                    // Handle new user logic here
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage()));
                  }, child: const Text("Don't have an account? sign up here"),),
                  
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