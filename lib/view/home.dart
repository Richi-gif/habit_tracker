// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:habit_tracker/database/habit_helper.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/models/habit_model.dart';


class HomeScreen extends StatefulWidget {
  final VoidCallback onHabitUpdated;
  const HomeScreen({super.key, required this.onHabitUpdated});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Habit>> _habitsFuture;

  @override
  void initState() {
    super.initState();
    _refreshHabits();
  }

  void _refreshHabits() {
    // Mendapatkan nama hari ini dalam 3 huruf (e.g., 'Mon', 'Tue')
    final String currentDay = DateFormat('E').format(DateTime.now());
    setState(() {
      _habitsFuture = DatabaseHelper.instance.readHabitsByDay(currentDay);
    });
  }

  void _toggleHabit(Habit habit) async {
    habit.isCompleted = !habit.isCompleted;
    await DatabaseHelper.instance.update(habit);
    _refreshHabits();
    widget.onHabitUpdated(); // Memberi sinyal ke parent untuk refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              // Opsi untuk mereset semua status harian
              await DatabaseHelper.instance.resetAllCompletion();
              _refreshHabits();
              widget.onHabitUpdated();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All habits have been reset for the day!'),
                ),
              );
            },
            tooltip: 'Reset Daily Status',
          ),
        ],
      ),
      body: FutureBuilder<List<Habit>>(
        future: _habitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No habits for today. Go create one!'),
            );
          }

          final habits = snapshot.data!;
          final pendingHabits = habits.where((h) => !h.isCompleted).toList();
          final completedHabits = habits.where((h) => h.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHabitSection('Pending habits', pendingHabits),
              if (completedHabits.isNotEmpty) const SizedBox(height: 24),
              if (completedHabits.isNotEmpty)
                _buildHabitSection('Completed habits', completedHabits),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHabitSection(String title, List<Habit> habits) {
    if (habits.isEmpty) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...habits.map((habit) => _buildHabitItem(habit)),
      ],
    );
  }

  Widget _buildHabitItem(Habit habit) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Color(habit.color).withOpacity(0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(habit.color)),
      ),
      child: ListTile(
        leading: Checkbox(
          value: habit.isCompleted,
          onChanged: (bool? value) => _toggleHabit(habit),
          activeColor: Color(habit.color),
          shape: const CircleBorder(),
        ),
        title: Text(
          habit.title,
          style: TextStyle(
            decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(habit.subtitle),
      ),
    );
  }
}
