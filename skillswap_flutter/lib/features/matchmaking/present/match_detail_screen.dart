import 'package:flutter/material.dart';

class TutorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> tutor;

  const TutorDetailScreen({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    final skills = (tutor['skills'] ?? [])
        .map((s) => "${s['name']} (${s['proficiency'] ?? 0}%)")
        .join(', ');

    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      appBar: AppBar(
        title: Text(tutor['name'] ?? "Tutor Details"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurpleAccent.shade100,
                    child: const Icon(Icons.person, color: Colors.white, size: 60),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  tutor['name'] ?? "Unknown Tutor",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                ),
                const SizedBox(height: 8),
                Text(
                  tutor['email'] ?? "No email provided",
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                const Text("Skills:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
                const SizedBox(height: 6),
                Text(skills.isNotEmpty ? skills : "No skills listed",
                    style: const TextStyle(fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 20),
                const Text("Bio:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent)),
                const SizedBox(height: 6),
                Text(
                  tutor['bio']?.isNotEmpty == true
                      ? tutor['bio']
                      : "This tutor hasn’t added a bio yet.",
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
