// lib/screens/add_habit_screen.dart

import 'package:flutter/material.dart';
import 'package:habit_tracker/database/habit_helper.dart';
import 'package:habit_tracker/models/habit_model.dart';

class AddHabitScreen extends StatefulWidget {
  final Habit?
  habit; // Nullable, jika null berarti 'create', jika ada isinya berarti 'edit'

  const AddHabitScreen({super.key, this.habit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;

  final List<String> _dayOptions = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  final Set<String> _selectedDays = {};

  final List<Color> _colorOptions = [
    Colors.red.shade300,
    Colors.orange.shade300,
    Colors.blue.shade300,
    Colors.green.shade300,
    Colors.purple.shade300,
  ];
  late Color _selectedColor;

  bool get isEditing => widget.habit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    _subtitleController = TextEditingController(
      text: widget.habit?.subtitle ?? '',
    );

    if (isEditing) {
      _selectedDays.addAll(widget.habit!.days);
      _selectedColor = Color(widget.habit!.color);
    } else {
      _selectedColor = _colorOptions.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one day.')),
        );
        return;
      }

      final habit = Habit(
        id: widget.habit?.id,
        title: _titleController.text,
        subtitle: _subtitleController.text,
        days: _selectedDays.toList(),
        color: _selectedColor.value,
        isCompleted: widget.habit?.isCompleted ?? false,
      );

      if (isEditing) {
        await DatabaseHelper.instance.update(habit);
      } else {
        await DatabaseHelper.instance.create(habit);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Habit' : 'New Habit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'I will... (e.g., read an article)',
                ),
                validator:
                    (value) => value!.isEmpty ? 'Title cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: 'After... (e.g., having my dinner)',
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Subtitle cannot be empty' : null,
              ),
              const SizedBox(height: 30),

              const Text(
                'Click on days to remind',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                children:
                    _dayOptions.map((day) {
                      final isSelected = _selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 30),

              const Text(
                'Select label color',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    _colorOptions.map((color) {
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border:
                                _selectedColor == color
                                    ? Border.all(color: Colors.black, width: 3)
                                    : null,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: Text(isEditing ? 'Update Habit' : 'Create new habit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
