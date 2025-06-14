// lib/screens/all_habits_screen.dart

import 'package:flutter/material.dart';
import 'package:habit_tracker/database/habit_helper.dart';
import 'package:habit_tracker/view/add_habit.dart';
import '../models/habit_model.dart';


class AllHabitsScreen extends StatefulWidget {
  const AllHabitsScreen({super.key});

  @override
  State<AllHabitsScreen> createState() => _AllHabitsScreenState();
}

class _AllHabitsScreenState extends State<AllHabitsScreen> {
  late Future<List<Habit>> _habitsFuture;
  String _selectedDay = 'All days';
  final List<String> _days = [
    'All days',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    _refreshHabits();
  }

  void _refreshHabits() {
    setState(() {
      if (_selectedDay == 'All days') {
        _habitsFuture = DatabaseHelper.instance.readAllHabits();
      } else {
        _habitsFuture = DatabaseHelper.instance.readHabitsByDay(_selectedDay);
      }
    });
  }

  void _deleteHabit(int id) async {
    await DatabaseHelper.instance.delete(id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Habit deleted successfully')));
    _refreshHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Habits')),
      body: Column(
        children: [
          _buildDayFilter(),
          Expanded(
            child: FutureBuilder<List<Habit>>(
              future: _habitsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No habits found.'));
                }

                final habits = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return Dismissible(
                      key: Key(habit.id.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _deleteHabit(habit.id!),
                      background: Container(
                        color: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        color: Color(habit.color).withOpacity(0.8),
                        child: ListTile(
                          title: Text(
                            habit.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            habit.subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => AddHabitScreen(habit: habit),
                                ),
                              );
                              _refreshHabits(); // Refresh list after editing
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final day = _days[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(day),
              selected: _selectedDay == day,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDay = day;
                  });
                  _refreshHabits();
                }
              },
              selectedColor: Colors.blueAccent,
              labelStyle: TextStyle(
                color: _selectedDay == day ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }
}
