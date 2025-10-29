import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../features/auth/data/auth_service.dart';
import '../data/profile_service.dart';

class ProfileDashboardScreen extends StatefulWidget {
  const ProfileDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ProfileDashboardScreen> createState() => _ProfileDashboardScreenState();
}

class _ProfileDashboardScreenState extends State<ProfileDashboardScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  List<dynamic> skills = [];
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
        backgroundColor: Colors.white,
        title: const Text(
          "Add a New Skill",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: skillController,
          decoration: const InputDecoration(
            labelText: "Enter Skill Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
            onPressed: () async {
              final skillName = skillController.text.trim();
              if (skillName.isEmpty) return;
              Navigator.pop(context);
              _generateQuiz(skillName);
            },
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  Future<void> _generateQuiz(String skillName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
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
            backgroundColor: Colors.white,
            title: Text(
              "Quiz: ${skillName.toUpperCase()}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(question["question"]),
                const SizedBox(height: 10),
                ...List.generate(question["options"].length, (i) {
                  final option = question["options"][i];
                  return RadioListTile<String>(
                    title: Text(option),
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
              if (currentQuestion < quiz.length - 1)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent),
                  onPressed: () {
                   if (selectedAnswer != null && 
    selectedAnswer!.trim().startsWith(question["answer"])) {
  score += question["complexity"] == "high"
      ? 3
      : question["complexity"] == "medium"
          ? 2
          : 1;
}

                    setState(() {
                      currentQuestion++;
                      selectedAnswer = null;
                    });
                  },
                  child: const Text("Next"),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent),
                  onPressed: () async {
                   if (selectedAnswer != null && 
    selectedAnswer!.trim().startsWith(question["answer"])) {
  score += question["complexity"] == "high"
      ? 3
      : question["complexity"] == "medium"
          ? 2
          : 1;
}

                    final proficiency = (score / (quiz.length * 3)) * 100;
                    await _saveSkill(skillName, proficiency);
                    Navigator.pop(context);
                  },
                  child: const Text("Submit"),
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
        // update local list if the skill already exists or add it
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ ${response["message"]}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Error saving skill: $e")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 + (_controller.value * 0.1);
          return Transform.scale(
            scale: scale,
            child: FloatingActionButton(
              onPressed: _showAddSkillDialog,
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.add, size: 30),
            ),
          );
        },
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Your Skills",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (skills.isEmpty)
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 40),
                              child: const Text(
                                "No skills added yet. Tap '+' to add one!",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: skills.map((s) {
                              return _buildSkillCard(
                                s["name"],
                                s["proficiency"].toDouble(),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Hero(
            tag: "profile-avatar",
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.deepPurpleAccent,
              child: Text(
                userData!["name"][0].toUpperCase(),
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userData!["name"],
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                userData!["email"],
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
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
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.star, color: Colors.amber),
        title: Text(
          skill,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: proficiency / 100,
              color: Colors.deepPurpleAccent,
              backgroundColor: Colors.white24,
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 4),
            Text(
              "${proficiency.toStringAsFixed(1)}% proficiency",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
