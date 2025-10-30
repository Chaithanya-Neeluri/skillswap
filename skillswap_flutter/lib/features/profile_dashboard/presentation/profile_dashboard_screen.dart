import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/auth/data/auth_service.dart';
import '../data/profile_service.dart';
import '../../../features/auth/present/login_screen.dart';

class ProfileDashboardScreen extends StatefulWidget {
  const ProfileDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDashboardScreen> createState() => _ProfileDashboardScreenState();
}

class _ProfileDashboardScreenState extends State<ProfileDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  List<dynamic> skills = [];
  Map<String, dynamic>? userData;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final response = await AuthService.getProfile();
    if (response["success"]) {
      setState(() {
        userData = response["user"];
        skills = userData?["skills"] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _showAddSkillDialog() async {
    final TextEditingController skillController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2833),
        title: const Text(
          "Add a New Skill",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFFF2E7C9)),
        ),
        content: TextField(
          controller: skillController,
          style: const TextStyle(color: Color.fromARGB(255, 56, 55, 55)),
          decoration: const InputDecoration(
            labelText: "Enter Skill Name",
            labelStyle: TextStyle(color: Color.fromARGB(255, 78, 77, 77)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF45A29E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFF2E7C9)),
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Color(0xFFB0B0B0))),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF45A29E),
            ),
            onPressed: () async {
              final skillName = skillController.text.trim();
              if (skillName.isEmpty) return;
              Navigator.pop(context);
              _generateQuiz(skillName);
            },
            child: const Text("Next", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _generateQuiz(String skillName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF45A29E))),
    );

    try {
      final quiz = await ApiService.generateQuiz(skillName);
      Navigator.pop(context);
      _showQuizDialog(skillName, quiz);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating quiz: $e")),
      );
    }
  }

  Future<void> _showQuizDialog(String skillName, List<dynamic> quiz) async {
    int score = 0;
    await showDialog(
      context: context,
      builder: (context) {
        int currentQuestion = 0;
        String? selectedAnswer;

        return StatefulBuilder(builder: (context, setState) {
          final question = quiz[currentQuestion];
          return AlertDialog(
            backgroundColor: const Color(0xFF1F2833),
            title: Text(
              "Quiz: ${skillName.toUpperCase()}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFF2E7C9)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(question["question"],
                    style: const TextStyle(color: Color(0xFFF2E7C9))),
                const SizedBox(height: 10),
                ...List.generate(question["options"].length, (i) {
                  final option = question["options"][i];
                  return RadioListTile<String>(
                    activeColor: const Color(0xFF45A29E),
                    title: Text(option, style: const TextStyle(color: Color(0xFFF2E7C9))),
                    value: option,
                    groupValue: selectedAnswer,
                    onChanged: (val) {
                      setState(() => selectedAnswer = val);
                    },
                  );
                }),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF45A29E)),
                onPressed: () async {
                  if (selectedAnswer != null &&
                      selectedAnswer!.trim().startsWith(question["answer"])) {
                    score += question["complexity"] == "high"
                        ? 3
                        : question["complexity"] == "medium"
                            ? 2
                            : 1;
                  }

                  if (currentQuestion < quiz.length - 1) {
                    setState(() {
                      currentQuestion++;
                      selectedAnswer = null;
                    });
                  } else {
                    final proficiency = (score / (quiz.length * 3)) * 100;
                    await _saveSkill(skillName, proficiency);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                    currentQuestion < quiz.length - 1 ? "Next" : "Submit",
                    style: const TextStyle(color: Colors.white)),
              )
            ],
          );
        });
      },
    );
  }

  Future<void> _saveSkill(String skillName, double proficiency) async {
    try {
      final response = await ApiService.updateProficiency(skillName, proficiency);
      if (response["success"] == true) {
        setState(() {
          final index = skills.indexWhere(
              (s) => s["name"].toLowerCase() == skillName.toLowerCase());
          if (index != -1) {
            skills[index]["proficiency"] = proficiency;
          } else {
            skills.add({"name": skillName, "proficiency": proficiency});
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "✅ ${response["message"]} (${proficiency.toStringAsFixed(1)}%)")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error saving skill: $e")),
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2833),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF45A29E),
            child: Text(
              userData!["name"][0].toUpperCase(),
              style: const TextStyle(fontSize: 32, color: Color(0xFFF2E7C9)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userData!["name"],
                    style: const TextStyle(
                        fontSize: 22,
                        color: Color(0xFFF2E7C9),
                        fontWeight: FontWeight.bold)),
                Text(userData!["email"],
                    style: const TextStyle(
                        color: Color(0xFFB0B0B0), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(String skill, double proficiency) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2833),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF45A29E).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.star, color: Color(0xFF45A29E)),
        title: Text(skill,
            style: const TextStyle(color: Color(0xFFF2E7C9), fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: proficiency / 100,
              color: const Color(0xFF45A29E),
              backgroundColor: Colors.white24,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 4),
            Text(
              "${proficiency.toStringAsFixed(1)}% proficiency",
              style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0C10),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF45A29E))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Profile Dashboard",
            style: TextStyle(
                color: Color(0xFFF2E7C9), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFF2E7C9)),
            tooltip: "Logout",
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1F2833),
                  title: const Text("Confirm Logout",
                      style: TextStyle(color: Color(0xFFF2E7C9))),
                  content: const Text("Are you sure you want to logout?",
                      style: TextStyle(color: Color(0xFFF2E7C9))),
                  actions: [
                    TextButton(
                      child: const Text("Cancel",
                          style: TextStyle(color: Color(0xFFB0B0B0))),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF45A29E),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = 1 + (_controller.value * 0.1);
            return Transform.scale(
              scale: scale,
              child: FloatingActionButton(
                onPressed: _showAddSkillDialog,
                backgroundColor: const Color(0xFF45A29E),
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Your Skills",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFFF2E7C9),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    if (skills.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Text("No skills added yet. Tap '+' to add one!",
                              style:
                                  TextStyle(color: Color(0xFFB0B0B0))),
                        ),
                      )
                    else
                      Column(
                        children: skills
                            .map((s) => _buildSkillCard(
                                  s["name"],
                                  s["proficiency"].toDouble(),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
