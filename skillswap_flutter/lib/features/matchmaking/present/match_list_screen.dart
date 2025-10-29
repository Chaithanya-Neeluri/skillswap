import 'package:flutter/material.dart';
import '../data/match_service.dart';
import 'match_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _tutors = [];
  String _error = '';

  Future<void> _searchTutors() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a skill or tutor name")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final tutors = await ApiService.searchTutors(query);
      setState(() {
        _tutors = tutors;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f8fa),
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text("Find Your Tutor", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _searchTutors(),
                decoration: InputDecoration(
                  hintText: "Search by skill or tutor name...",
                  prefixIcon: const Icon(Icons.search, color: Colors.deepPurpleAccent),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _controller.clear(),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🌀 Loading
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
                ),
              ),

            // ⚠️ Error
            if (_error.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            // 👩‍🏫 Tutors List
            if (!_isLoading && _tutors.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _tutors.length,
                  itemBuilder: (context, index) {
                    final tutor = _tutors[index];
                    final skills = (tutor['skills'] ?? [])
                        .map((s) => s['name'])
                        .join(', ');
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TutorDetailScreen(tutor: tutor),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurpleAccent.shade100,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(
                            tutor['name'] ?? "Unnamed Tutor",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            skills.isNotEmpty ? skills : "No skills listed",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (!_isLoading && _tutors.isEmpty && _error.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "Search for tutors by typing above 🔍",
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
