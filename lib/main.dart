import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/application/login/bloc/login_bloc.dart';
import 'package:habit_tracker/application/register/bloc/register_bloc.dart';
import 'package:habit_tracker/view/home.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() {

  sqfliteFfiInit();

  // Menghubungkan FFI sebagai factory
  databaseFactory = databaseFactoryFfi;

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
        BlocProvider<RegisterBloc>(create: (context) => RegisterBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(
        onHabitUpdated: () {},
      ), // Tambahan callback yang dibutuhkan
    );
  }
}
