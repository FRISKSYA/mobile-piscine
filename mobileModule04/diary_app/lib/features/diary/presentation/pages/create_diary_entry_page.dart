import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/validators.dart';
import '../providers/diary_provider.dart';
import '../widgets/mood_selector.dart';

class CreateDiaryEntryPage extends ConsumerStatefulWidget {
  const CreateDiaryEntryPage({super.key});

  @override
  ConsumerState<CreateDiaryEntryPage> createState() => _CreateDiaryEntryPageState();
}

class _CreateDiaryEntryPageState extends ConsumerState<CreateDiaryEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _submit() {
    if (_formKey.currentState!.validate() && _selectedMood != null) {
      ref.read(diaryNotifierProvider.notifier).createEntry(
        date: _selectedDate,
        title: _titleController.text,
        mood: _selectedMood!,
        content: _contentController.text,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final diaryState = ref.watch(diaryNotifierProvider);
    
    ref.listen<AsyncValue<void>>(diaryNotifierProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          if (previous?.isLoading ?? false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Diary entry created successfully')),
            );
            context.pop();
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Diary Entry'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                ),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: Validators.validateTitle,
            ),
            const SizedBox(height: 16),
            MoodSelector(
              selectedMood: _selectedMood,
              onMoodSelected: (mood) {
                setState(() {
                  _selectedMood = mood;
                });
              },
            ),
            if (_selectedMood == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select a mood',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'What happened today?',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              validator: Validators.validateContent,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: diaryState.isLoading ? null : _submit,
                child: diaryState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}