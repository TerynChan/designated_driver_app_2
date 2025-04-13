import 'package:designated_driver_app_2/auth/signup_page.dart';
import 'package:flutter/material.dart';

class SigninPage extends StatefulWidget {
    
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  
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
            
            Text("Sign Up as new User", 
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
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green
                    ), child: const Text("Sign in", style: TextStyle( color: Colors.white),),
                  ),
                  
                  const SizedBox(height: 20),

                  TextButton(onPressed: () {
                    // Handle forgot password logic here
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