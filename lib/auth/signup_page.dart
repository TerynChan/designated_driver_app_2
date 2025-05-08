import 'package:designated_driver_app_2/auth/signin_page.dart';
import 'package:designated_driver_app_2/global.dart';
import 'package:designated_driver_app_2/pages/driver/driver_home_page.dart';
import 'package:designated_driver_app_2/pages/user/home_page.dart';
import 'package:designated_driver_app_2/widgets/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

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
  TextEditingController carModelTextEditingController = TextEditingController();
  TextEditingController carNumberTextEditingController = TextEditingController();
  TextEditingController carColorTextEditingController = TextEditingController();

  bool isDriver = false;
  String? selectedCarType;
  List<String> carTypes = ['HondaFit', 'Funcargo', 'March','Vitz', 'PickUp','Motorcycle']; // Example car types
  String signupImage = "assets/signup.webp"; // Default image for user signup
  String driverSignupImage = "assets/driver_signup.png";

  //form validation and signup method
validateSignupForm() async {
  // Form validation logic
  print("Username: ${usernameTextEditingController.text}");
  print("Email: ${emailTextEditingController.text}");
  print("Phone: ${phoneTextEditingController.text}");
  print("Password: ${passwordTextEditingController.text}");
  print("Signing up as driver: $isDriver");

  if (isDriver) {
    print("Car Type: $selectedCarType");
    print("Car Model: ${carModelTextEditingController.text}");
    print("Car Number: ${carNumberTextEditingController.text}");
    print("Car Color: ${carColorTextEditingController.text}");

    if (selectedCarType == null) {
      associateMethods.showSnackBarMsg('Please select your car type', context);
      return;
    }
    if (carModelTextEditingController.text.trim().isEmpty) {
      associateMethods.showSnackBarMsg('Please enter your car model', context);
      return;
    }
    if (carNumberTextEditingController.text.trim().isEmpty) {
      associateMethods.showSnackBarMsg('Please enter your car number', context);
      return;
    }
    if (carColorTextEditingController.text.trim().isEmpty) {
      associateMethods.showSnackBarMsg('Please enter your car color', context);
      return;
    }
  }

  if (usernameTextEditingController.text.trim().length < 3) {
    associateMethods.showSnackBarMsg('Name must be at least three characters', context);
  } else if (!emailTextEditingController.text.trim().contains("@")) {
    associateMethods.showSnackBarMsg('Please enter a valid email', context);
  } else if (phoneTextEditingController.text.trim().length < 7) {
    associateMethods.showSnackBarMsg('Please enter a valid phone number', context);
  } else {
    // Proceed with signup
    await signUserNow();
  }
}

// Declaration of signUser function with Firebase
signUserNow() async {
  // Loading screen while signing up
  showDialog(
      context: context, builder: (BuildContext context) => const LoadingScreen());
  try {
    final User? firebaseUser = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
      email: emailTextEditingController.text.trim(),
      password: passwordTextEditingController.text.trim(),
    )
            .catchError((onError) {
      Navigator.pop(context);
      associateMethods.showSnackBarMsg(onError.toString(), context);
      throw onError; // Throw the error to satisfy the return type
    }))
        .user;

    if (firebaseUser != null) {
      Map userDataMap = {
        "name": usernameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };

      if (isDriver) {
        userDataMap.addAll({
          "isDriver": true,
          "carType": selectedCarType,
          "carModel": carModelTextEditingController.text.trim(),
          "carNumber": carNumberTextEditingController.text.trim(),
          "carColor": carColorTextEditingController.text.trim(),
        });
      } else {
        userDataMap.addAll({"isDriver": false});
      }

      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(firebaseUser.uid)
          .set(userDataMap);

      Navigator.pop(context);
      associateMethods.showSnackBarMsg("Account created successfully", context);
      Navigator.push(
          context, MaterialPageRoute(builder: (c) => (isDriver == true) ? DriverHomePage() : const HomePage())); // Redirect user or driver to homepage
                         } 
      else {
      // User creation failed (should be caught by catchError)
      Navigator.pop(context);
      associateMethods.showSnackBarMsg(
          "Failed to create account. Please try again.", context);
    }
  } on FirebaseAuthException catch (e) {
    FirebaseAuth.instance.signOut();
    Navigator.pop(context);
    associateMethods.showSnackBarMsg(e.toString(), context);
  } catch (e) {
    Navigator.pop(context);
    associateMethods.showSnackBarMsg(
        "An unexpected error occurred: $e", context);
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
              Image.asset(
                isDriver ? "assets/driver_signup.png" : signupImage,
                width: MediaQuery.of(context).size.width * .6,
              ),
              const SizedBox(height: 20),
              const Text(
                "Choose Sign in Method",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ToggleSwitch(
                minWidth: 90.0,
                initialLabelIndex: isDriver ? 1 : 0,
                cornerRadius: 20.0,
                activeFgColor: Colors.white,
                inactiveBgColor: const Color.fromARGB(255, 180, 173, 173),
                inactiveFgColor: Colors.white,
                totalSwitches: 2,
                labels: const ['User', 'Driver'],
                icons: const [
                  Icons.supervised_user_circle_rounded,
                  Icons.car_rental_rounded
                ],
                activeBgColors: const [
                  [Colors.green],
                  [Colors.blue]
                ],
                onToggle: (index) {
                  setState(() {
                    isDriver = index == 1;
                    print('Switched to driver mode: $isDriver');
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: usernameTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Username",
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
                      controller: phoneTextEditingController,
                      decoration: InputDecoration(
                        labelText: "Phone",
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        hintText: "Enter your phone number",
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
                    if (isDriver) ...[
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Car Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        value: selectedCarType,
                        items: carTypes
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCarType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: carModelTextEditingController,
                        decoration: InputDecoration(
                          labelText: "Car Model",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          hintText: "Enter your car model",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: carNumberTextEditingController,
                        decoration: InputDecoration(
                          labelText: "Car Number",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          hintText: "Enter your car number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: carColorTextEditingController,
                        decoration: InputDecoration(
                          labelText: "Car Color",
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          hintText: "Enter your car color",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        validateSignupForm();
                        
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SigninPage()));
                      },
                      child: const Text("Already have an account? Sign in here"),
                    ),
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
