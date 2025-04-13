import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController = TextEditingController();
  TextEditingController usernameTextEditingController = TextEditingController();

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
                  
                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      hintText: "confirm your password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(onPressed: () {
                    // Handle sign in logic here
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