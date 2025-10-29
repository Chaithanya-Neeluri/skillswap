import 'package:flutter/material.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
// import '../../profile_dashboard/data/skill_repository.dart';
import '../../matchmaking/data/match_repository.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  // You can use MatchRepository to search users or SkillRepository, depending on backend
  final MatchRepository _matchRepo = MatchRepository();

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      // For demo, MatchRepository.getMatchesBySkill used as a search by skill or name.
      final matches = await _matchRepo.getMatchesBySkill(q.trim());
      _results = matches.map((m) => {
        'otherUid': m.id,
        'otherName': m.name,
        'bio': m.bio,
        'skill': m.skill,
      }).toList();
    } catch (e) {
      _results = [];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a new chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(label: 'Search by skill or name', controller: _searchCtrl),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Search',
              isLoading: _loading,
              onPressed: () => _search(_searchCtrl.text),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('No results yet'))
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, i) {
                        final r = _results[i];
                        return ListTile(
                          leading: CircleAvatar(child: Text((r['otherName'] ?? 'U').toString()[0].toUpperCase())),
                          title: Text(r['otherName'] ?? ''),
                          subtitle: Text(r['skill'] ?? r['bio'] ?? ''),
                          onTap: () {
                            // create conversation and open chat
                            Navigator.pushNamed(context, '/chatRoom', arguments: {
                              'otherUid': r['otherUid'],
                              'otherName': r['otherName'],
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
