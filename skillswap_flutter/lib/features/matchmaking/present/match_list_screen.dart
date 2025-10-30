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
    final navyBlack = const Color(0xFF0B0C10);
    final ashGray = const Color(0xFFB0B0B0);
    final cream = const Color(0xFFF5E8C7);
    final cardDark = const Color(0xFF1C1E22);

    return Scaffold(
      backgroundColor: navyBlack,
      appBar: AppBar(
        backgroundColor: cardDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Find Your Tutor",
          style: TextStyle(
            color: cream,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: IconThemeData(color: cream),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.white12, width: 1.2),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: Colors.black26, fontSize: 16),
                onSubmitted: (_) => _searchTutors(),
                decoration: InputDecoration(
                  hintText: "Search by skill or tutor name...",
                  hintStyle: TextStyle(color: ashGray, fontSize: 15),
                  prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: () => _controller.clear(),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

        
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.cyanAccent),
                ),
              ),

            if (_error.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    _error,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

         
            if (!_isLoading && _tutors.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
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
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          border: Border.all(color: Colors.white12, width: 1),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                            child: const Icon(Icons.person,
                                color: Colors.cyanAccent, size: 28),
                          ),
                          title: Text(
                            tutor['name'] ?? "Unnamed Tutor",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: cream,
                            ),
                          ),
                          subtitle: Text(
                            skills.isNotEmpty ? skills : "No skills listed",
                            style: TextStyle(
                              color: ashGray,
                              fontSize: 13.5,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.cyanAccent),
                        ),
                      ),
                    );
                  },
                ),
              ),

         
            if (!_isLoading && _tutors.isEmpty && _error.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "Search for tutors by typing above 🔍",
                    style: TextStyle(
                      color: ashGray,
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
