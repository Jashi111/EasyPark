import 'package:easypark/view/SUPhome.dart';
import 'package:easypark/view/UserReg.dart';
import 'package:flutter/material.dart';
import 'package:easypark/view/home_screen.dart';
//import 'package:easypark/view/parkingSpotView_NOTUSE.dart';

final formKey = GlobalKey<FormState>();

class AuthController {
  final Map<String, Map<String, String>> users = {
    "user@gmail.com": {"password": "User", "role": "User"},
    "admin@gmail.com": {"password": "Admin", "role": "Supervisor"},
  };

  // Method to authenticate user using hardcoded credentials
  Future<bool> authenticateUser(String email, String password) async {
    if (users.containsKey(email) && users[email]?['password'] == password) {
      return true;
    }
    return false;
  }

  // Method to get user role from hardcoded credentials
  Future<String?> getUserRole(String email) async {
    if (users.containsKey(email)) {
      return users[email]?['role'];
    }
    return null;
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        body: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _header(),
              _inputField(context),
              _forgotPassword(),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      children: [
        Text(
          "Welcome",
          style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          "Enter your credentials to login",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _inputField(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              return null;
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Email",
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Password",
              hintStyle: const TextStyle(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              String email = _emailController.text.trim();
              String password = _passwordController.text.trim();

              bool isAuthenticated =
              await _authController.authenticateUser(email, password);
              if (isAuthenticated) {
                String? userRole =
                await _authController.getUserRole(email);
                if (userRole == 'User') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                } else if (userRole == 'Supervisor') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SupHomePage()),
                  );
                }
              } else {
                // Handle authentication failure
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Authentication Failed"),
                      content: const Text("Invalid email or password"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("OK"),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _forgotPassword() {
    return TextButton(onPressed: () {}, child: const Text("Forgot password?"));
  }

  Widget _signup(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white),
        ),
        TextButton(
          onPressed: () {
            // Navigate to the signup page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserReg()),
            );
          },
          child: const Text("Create Account"),
        ),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Login(),
  ));
}
