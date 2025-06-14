import 'package:flutter/material.dart';
import 'package:habit_tracker/view/add_habit.dart';
import 'package:habit_tracker/view/home.dart';
import 'package:habit_tracker/application/register/view/register.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/application/login/bloc/login_bloc.dart';
import 'package:habit_tracker/application/login/bloc/login_event.dart';
import 'package:habit_tracker/application/login/bloc/login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool passwordVisible = false;

  // --- Skema Warna Konsisten ---
  static const Color backgroundColor = Color(0xFF1a1a2e);
  static const Color cardColor = Color(
    0xFF1f1f3a,
  ); // Used for input fields background
  static const Color textColor = Color(
    0xFFe0e0e0,
  ); // Light gray for general text
  static const Color primaryColor = Color(0xFF6c5ce7); // Purple accent color

  @override
  void initState() {
    super.initState();
    passwordVisible = false; // Default password hidden as per common UI
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Background gelap
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          0,
        ), // AppBar tidak terlihat, fokus pada body
        child: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0.0,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 24.0,
          ), // Padding horizontal lebih besar
          child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) async {
              if (state is LoginLoading) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                      ),
                );
              } else if (state is LoginSuccess) {
                Navigator.of(context).pop();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AddHabitScreen()),
                );
              } else if (state is LoginFailure) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Center(
                      child: Text(
                        state.error,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                  ),
                );
              }
            },
            child: Column(
              children: <Widget>[
                // Logo/Nama Aplikasi
                const SizedBox(height: 40), // Ruang atas
                Text(
                  "GAMEVAULT", // Nama aplikasi
                  style: TextStyle(
                    fontSize: 48.0,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 2, // Memberikan sedikit jarak antar huruf
                  ),
                ),
                const SizedBox(height: 60.0), // Jarak ke form
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, // Padding vertikal lebih besar
                          horizontal: 20.0,
                        ),
                        filled: true,
                        fillColor: cardColor, // Background field
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ), // Rounded corners
                          borderSide: BorderSide.none, // Tanpa border
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: primaryColor.withOpacity(0.5),
                            width: 1,
                          ), // Border tipis
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 2,
                          ), // Border lebih tebal saat fokus
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0, // Jarak antar field
                ),
                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Implementasi Forgot Password
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Forgot Password functionality not implemented yet.',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: password,
                      obscureText:
                          !passwordVisible, // Dibalik karena passwordVisible akan true jika terlihat
                      style: const TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 20.0,
                        ),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: primaryColor.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility, // Ikon dibalik
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40.0, // Jarak ke tombol Login
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                      ), // Padding vertikal lebih besar
                      elevation: 5,
                    ),
                    onPressed: () {
                      final emailText = email.text.trim();
                      final passwordText = password.text.trim();

                      if (emailText.isNotEmpty && passwordText.isNotEmpty) {
                        context.read<LoginBloc>().add(
                          LoginRequested(
                            email: emailText,
                            password: passwordText,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email and password cannot be empty'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "LOGIN", // Teks tombol kapital
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1, // Sedikit jarak antar huruf
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?", // Ubah teks
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Register(),
                          ),
                        );
                      },
                      child: Text(
                        "Register Now", // Ubah teks
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
