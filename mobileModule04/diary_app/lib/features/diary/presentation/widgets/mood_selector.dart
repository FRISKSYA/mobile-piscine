import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String> onMoodSelected;
  
  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppConstants.moods.map((mood) {
            final isSelected = selectedMood == mood;
            return ChoiceChip(
              label: Text(mood),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onMoodSelected(mood);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}