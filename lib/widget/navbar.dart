import 'package:flutter/material.dart';
import 'package:habit_tracker/view/add_habit.dart';
import 'package:habit_tracker/view/all_habits.dart';
import 'package:habit_tracker/view/home.dart';

class Navbar extends StatefulWidget {
  final int currentIndex;
  const Navbar({super.key, this.currentIndex = 0});

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;

    _pages = [
      AddHabitScreen(),
      AllHabitsScreen(),
      HomeScreen(
        onHabitUpdated: () {
          // Optional: log or refresh logic
        },
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Habit'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
