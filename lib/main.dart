// lib/main.dart

import 'package:flutter/material.dart';
import 'package:habit_tracker/view/add_habit.dart';
import 'package:habit_tracker/view/all_habits.dart';
import 'package:habit_tracker/view/home.dart';



void main() {
  // Memastikan Flutter binding sudah siap sebelum menjalankan kode
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  // Key untuk mengakses state tidak lagi diperlukan.
  // final GlobalKey<_AllHabitsScreenState> _allHabitsKey =
  //     GlobalKey<_AllHabitsScreenState>(); // <-- DIHAPUS

  @override
  void initState() {
    super.initState();
    // Inisialisasi widget list di sini.
    _widgetOptions = <Widget>[
      HomeScreen(onHabitUpdated: _refreshScreens),
      const AllHabitsScreen(),
    ];
  }

  // Fungsi refresh yang disederhanakan.
  // Cukup panggil setState untuk membangun ulang widget tree dengan data baru.
  void _refreshScreens() {
    setState(() {
      // Dengan membuat instance baru dari screen, kita memaksa mereka
      // untuk mengambil data terbaru dari database saat di-render ulang.
      _widgetOptions = <Widget>[
        HomeScreen(onHabitUpdated: _refreshScreens),
        const AllHabitsScreen(),
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddHabit() async {
    // Navigasi ke halaman AddHabitScreen dan tunggu sampai selesai (pop).
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddHabitScreen()));
    // Setelah kembali, panggil fungsi refresh.
    _refreshScreens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan widget yang sesuai dari list berdasarkan index.
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddHabit,
        tooltip: 'Create New',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'All Habits',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
    );
  }
}
