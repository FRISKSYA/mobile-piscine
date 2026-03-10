import 'package:flutter/material.dart';
import 'package:diary_app/main.dart';
import 'package:diary_app/pages/diary_entry_page.dart';
import 'package:diary_app/pages/login_page.dart';

const feelingEmojis = {
  'happy': '😊',
  'sad': '😢',
  'angry': '😠',
  'surprised': '😲',
  'loving': '❤️',
  'thoughtful': '🤔',
};

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('diary_entries')
          .select()
          .order('date', ascending: false);
      setState(() {
        _entries = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Failed to load entries', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteEntry(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await supabase.from('diary_entries').delete().eq('id', id);
      _fetchEntries();
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Failed to delete entry', isError: true);
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Failed to sign out', isError: true);
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(child: Text('No diary entries yet'))
              : ListView.builder(
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final feeling = entry['feeling'] as String? ?? '';
                    final emoji = feelingEmojis[feeling] ?? '';
                    final title = entry['title'] as String? ?? '';
                    final date = entry['date'] as String? ?? '';

                    return ListTile(
                      leading: Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(title),
                      subtitle: Text(date),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _deleteEntry(entry['id'].toString()),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                DiaryEntryPage(entry: entry),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => const DiaryEntryPage(),
            ),
          );
          if (result == true) {
            _fetchEntries();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
