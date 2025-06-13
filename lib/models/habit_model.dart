// lib/models/habit_model.dart

class Habit {
  int? id;
  String title;
  String subtitle;
  List<String> days; // e.g., ['Mon', 'Tue', 'Wed']
  int color; // Menyimpan warna sebagai integer (e.g., 0xFFE57373)
  bool isCompleted;

  Habit({
    this.id,
    required this.title,
    required this.subtitle,
    required this.days,
    required this.color,
    this.isCompleted = false,
  });

  // Konversi dari Map (data dari DB) ke objek Habit
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      // Konversi string 'Mon,Tue,Wed' menjadi List<String>
      days: (map['days'] as String).split(','),
      color: map['color'],
      // SQLite tidak punya tipe bool, jadi kita simpan sebagai 0 atau 1
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // Konversi dari objek Habit ke Map (untuk disimpan ke DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      // Konversi List<String> menjadi string tunggal 'Mon,Tue,Wed'
      'days': days.join(','),
      'color': color,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}
