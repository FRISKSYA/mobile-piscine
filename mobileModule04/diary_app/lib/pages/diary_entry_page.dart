import 'package:flutter/material.dart';
import 'package:diary_app/main.dart';
import 'package:diary_app/pages/diary_list_page.dart';

class DiaryEntryPage extends StatefulWidget {
  final Map<String, dynamic>? entry;

  const DiaryEntryPage({super.key, this.entry});

  @override
  State<DiaryEntryPage> createState() => _DiaryEntryPageState();
}

class _DiaryEntryPageState extends State<DiaryEntryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String _selectedFeeling = 'happy';
  bool _isSaving = false;

  bool get _isCreateMode => widget.entry == null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: _isCreateMode ? '' : widget.entry!['title'] as String? ?? '',
    );
    _contentController = TextEditingController(
      text: _isCreateMode ? '' : widget.entry!['content'] as String? ?? '',
    );
    if (!_isCreateMode) {
      _selectedFeeling =
          widget.entry!['feeling'] as String? ?? 'happy';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) {
          context.showSnackBar('Session expired. Please sign in again.',
              isError: true);
        }
        return;
      }
      await supabase.from('diary_entries').insert({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'feeling': _selectedFeeling,
        'date': DateTime.now().toUtc().toIso8601String(),
        'user_id': user.id,
        'user_email': user.email ?? '',
      });
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Failed to save entry', isError: true);
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCreateMode) {
      return _buildViewMode();
    }
    return _buildCreateMode();
  }

  Widget _buildViewMode() {
    final entry = widget.entry!;
    final feeling = entry['feeling'] as String? ?? '';
    final emoji = feelingEmojis[feeling] ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Diary Entry')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            entry['date'] as String? ?? '',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            entry['title'] as String? ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '$emoji $feeling',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 24),
          Text(
            entry['content'] as String? ?? '',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateMode() {
    return Scaffold(
      appBar: AppBar(title: const Text('New Entry')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedFeeling,
              decoration: const InputDecoration(labelText: 'Feeling'),
              items: feelingEmojis.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text('${e.value} ${e.key}'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedFeeling = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter some content';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: Text(_isSaving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
