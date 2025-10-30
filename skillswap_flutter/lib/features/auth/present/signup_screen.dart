import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/social_icon_button.dart';
import '../data/auth_service.dart';
import 'login_screen.dart';

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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    setState(() => isLoading = true);
    final res = await AuthService.signup(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );
    setState(() => isLoading = false);

    if (res["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful ✅")),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cream = const Color(0xFFF5E8C7);
    final ashGray = const Color(0xFFB0B0B0);
    final navyBlack = const Color(0xFF0B0C10);
    final darkCard = const Color(0xFF1C1E22);

    return Scaffold(
      backgroundColor: navyBlack,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // ✨ Animated Background Gradient
            AnimatedContainer(
              duration: const Duration(seconds: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    navyBlack,
                    const Color(0xFF1A1C1E),
                    const Color(0xFF232526),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

        
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
           
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) => Transform.scale(
                      scale: value,
                      child: child,
                    ),
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: darkCard,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_add_alt_1_rounded,
                          color: Colors.white, size: 45),
                    ),
                  ),

                  const SizedBox(height: 25),
                  Text(
                    "Create Your Account",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: cream,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Join the Skill Exchange Community",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: ashGray,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    decoration: BoxDecoration(
                      color: darkCard.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          label: "Full Name",
                          controller: nameController,
                        ),
                        const SizedBox(height: 18),

                        CustomTextField(
                          label: "Email",
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),

                        CustomTextField(
                          label: "Password",
                          controller: passwordController,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),

                   
                        GestureDetector(
                          onTap: isLoading ? null : _handleSignup,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 55,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0083B0), Color(0xFF00B4DB)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          ),
                          child: Text(
                            "Already have an account? Log In",
                            style: GoogleFonts.poppins(
                              color: cream,
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
                    style: GoogleFonts.poppins(
                      color: ashGray,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialIconButton(
                        assetPath: 'assets/icons/google.png',
                        onTap: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Google Login Clicked")),
                        ),
                      ),
                      SocialIconButton(
                        assetPath: 'assets/icons/facebook.png',
                        onTap: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Facebook Login Clicked")),
                        ),
                      ),
                      SocialIconButton(
                        assetPath: 'assets/icons/github.png',
                        onTap: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("GitHub Login Clicked")),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Text(
                    "By signing up, you agree to our Terms & Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: ashGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
