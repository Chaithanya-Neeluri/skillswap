import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/skill_chip.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/skill_chip.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/social_icon_button.dart';
import '../../../core/theme/app_text_styles.dart';
import 'login_screen.dart';
import '../data/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _handleSignup() async {
  setState(() => isLoading = true);

  final url = Uri.parse("http://localhost:3000/api/create-user"); // if testing on emulator use 10.0.2.2 instead of localhost
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "userId": DateTime.now().millisecondsSinceEpoch.toString(),
      "name": nameController.text.trim(),
      "email": emailController.text.trim(),
      "skills": [],
      "bio": "",
      "availability": [],
    }),
  );

  setState(() => isLoading = false);

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ ${data['message']}")),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  } else {
    final data = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ ${data['message']}")),
    );
  }
}


  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF764BA2), Color(0xFF667EEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // 🌟 App Icon or Illustration
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),

                // 🏷️ Title
                Text(
                  "Create Account 🚀",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Join the Skill Exchange Community",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),

                // 🧊 Frosted Glass Signup Card
                Container(
                  width: size.width * 0.9,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 👤 Full Name Field
                      CustomTextField(
                        label: "Full Name",
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),

                      // 📧 Email Field
                      CustomTextField(
                        label: "Email",
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // 🔒 Password Field
                      CustomTextField(
                        label: "Password",
                        controller: passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 30),

     

                      // 🎯 Sign Up Button
                      GestureDetector(
                        onTap: isLoading ? null : () async {
  final res = await AuthService.signup(
    name: nameController.text,
    email: emailController.text,
    password: passwordController.text,
  );

  if (res["success"]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Signup successful ✅")),
    );
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res["message"])),
    );
  }
},
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 55,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF43E97B),
                                Color(0xFF38F9D7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  "Sign Up",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔗 Login Link
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        ),
                        child: Text(
                          "Already have an account? Log In",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                  
Text(
  "Or continue with",
  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
),

const SizedBox(height: 16),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    SocialIconButton(
      assetPath: 'assets/icons/google.png',
      onTap: () {
        // TODO: Implement Google login logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Login Clicked")),
        );
      },
    ),
    SocialIconButton(
      assetPath: 'assets/icons/facebook.png',
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Facebook Login Clicked")),
        );
      },
    ),
    SocialIconButton(
      assetPath: 'assets/icons/github.png',
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("GitHub Login Clicked")),
        );
      },
    ),
  ],
),
SizedBox(height: 20,),

                // 📜 Footer
                Text(
                  "By signing up, you agree to our Terms & Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
