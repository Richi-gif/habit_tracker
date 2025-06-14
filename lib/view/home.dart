import 'package:flutter/material.dart';
import 'package:habit_tracker/database/habit_helper.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/models/habit_model.dart';

/// HomeScreen displays the user's habits, categorized into pending and completed.
/// It interacts with a database helper to fetch and update habit data.
/// It also provides a callback to notify its parent widget (MainScreen) about updates.
class HomeScreen extends StatefulWidget {
  final VoidCallback onHabitUpdated; // Callback to notify parent of updates
  const HomeScreen({super.key, required this.onHabitUpdated});

  @override
  State<HomeScreen> createState() => HomeScreenState(); // Changed to public for GlobalKey
}

/// HomeScreenState manages the state for HomeScreen.
/// It fetches habit data, handles habit completion toggling, and refreshes the display.
class HomeScreenState extends State<HomeScreen> {
  // Made class public
  late Future<List<Habit>>
  _habitsFuture; // Future to hold asynchronous habit data

  @override
  void initState() {
    super.initState();
    _refreshHabits(); // Initial fetch of habits when the screen is initialized
  }

  /// _refreshHabits fetches habits for the current day from the database.
  /// It updates the _habitsFuture, triggering a rebuild of the FutureBuilder.
  /// Made public so MainScreen can call it via GlobalKey.
  void _refreshHabits() {
    // Get the current day's name (e.g., 'Mon', 'Tue')
    final String currentDay = DateFormat('E').format(DateTime.now());
    setState(() {
      // Update the future, which causes FutureBuilder to re-evaluate
      _habitsFuture = DatabaseHelper.instance.readHabitsByDay(currentDay);
    });
  }

  /// _toggleHabit updates the completion status of a given habit in the database.
  /// After updating, it refreshes the habits displayed and notifies the parent widget.
  void _toggleHabit(Habit habit) async {
    habit.isCompleted = !habit.isCompleted; // Toggle completion status
    await DatabaseHelper.instance.update(habit); // Update in the database
    _refreshHabits(); // Refresh the displayed habits
    widget
        .onHabitUpdated(); // Notify parent (MainScreen) to potentially update other parts of the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Habits'), // Title of the app bar
        actions: [
          // IconButton to reset all daily habit completion statuses
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              await DatabaseHelper.instance
                  .resetAllCompletion(); // Reset all habits
              _refreshHabits(); // Refresh the display
              widget.onHabitUpdated(); // Notify parent
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All habits have been reset for the day!'),
                ),
              );
            },
            tooltip: 'Reset Daily Status', // Tooltip for accessibility
          ),
        ],
      ),
      body: FutureBuilder<List<Habit>>(
        future: _habitsFuture, // The future to wait for
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while data is being fetched
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display an error message if something went wrong
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // If no habits are found for today, display a message
            return const Center(
              child: Text('No habits for today. Go create one!'),
            );
          }

          final habits = snapshot.data!;
          // Separate habits into pending and completed for display
          final pendingHabits = habits.where((h) => !h.isCompleted).toList();
          final completedHabits = habits.where((h) => h.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Build section for pending habits
              _buildHabitSection('Pending Habits', pendingHabits),
              // Add spacing if there are completed habits to show
              if (completedHabits.isNotEmpty) const SizedBox(height: 24),
              // Build section for completed habits if any
              if (completedHabits.isNotEmpty)
                _buildHabitSection('Completed Habits', completedHabits),
            ],
          );
        },
      ),
    );
  }

  /// _buildHabitSection creates a titled section for a list of habits.
  /// It only renders if the habits list is not empty.
  Widget _buildHabitSection(String title, List<Habit> habits) {
    if (habits.isEmpty) return Container(); // Don't render if no habits

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Map each habit to a _buildHabitItem widget
        ...habits.map((habit) => _buildHabitItem(habit)),
      ],
    );
  }

  /// _buildHabitItem creates a card-based UI element for a single habit.
  /// It uses themed colors based on the habit's color property.
  Widget _buildHabitItem(Habit habit) {
    return Card(
      // Margin and color derived from habit data.
      // Opacity is applied to the background color.
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Color(habit.color).withOpacity(0.2),
      elevation: 0, // No shadow for a flatter design
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
        side: BorderSide(color: Color(habit.color)), // Border color from habit
      ),
      child: ListTile(
        leading: Checkbox(
          value: habit.isCompleted, // Checkbox state based on habit completion
          onChanged: (bool? value) => _toggleHabit(habit), // Toggle on tap
          activeColor: Color(habit.color), // Active color from habit
          shape: const CircleBorder(), // Circular checkbox
        ),
        title: Text(
          habit.title,
          style: TextStyle(
            // Apply strikethrough if habit is completed
            decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(habit.subtitle), // Display habit subtitle
      ),
    );
  }
}
