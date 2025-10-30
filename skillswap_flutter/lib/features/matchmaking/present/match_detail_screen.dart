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
      backgroundColor: const Color(0xFF0B0C10), // navy black
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2833), // ash gray
        elevation: 0,
        title: Text(
          tutor['name'] ?? "Tutor Details",
          style: const TextStyle(
            color: Color(0xFFF2E7C9), // cream text
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFF2E7C9)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2833),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
   
                Center(
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xFF45A29E).withOpacity(0.3),
                    child: const Icon(Icons.person,
                        color: Color(0xFFF2E7C9), size: 60),
                  ),
                ),
                const SizedBox(height: 20),

              
                Text(
                  tutor['name'] ?? "Unknown Tutor",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF2E7C9),
                  ),
                ),
                const SizedBox(height: 6),

                
                Text(
                  tutor['email'] ?? "No email provided",
                  style: const TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),

             
                Container(
                  height: 1,
                  color: Colors.white12,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),

           
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Skills",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF45A29E),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    skills.isNotEmpty ? skills : "No skills listed",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFF2E7C9),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Bio",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF45A29E),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    tutor['bio']?.isNotEmpty == true
                        ? tutor['bio']
                        : "This tutor hasn’t added a bio yet.",
                    style: const TextStyle(
                      color: Color(0xFFF2E7C9),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF45A29E),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Feature coming soon!"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.message, color: Colors.white),
                  label: const Text(
                    "Chat with Tutor",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
