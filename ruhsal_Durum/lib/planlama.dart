import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ruhsal_durum/planlistpage.dart';

class PlanlamaPage extends StatefulWidget {
  final String userId;
  const PlanlamaPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<PlanlamaPage> createState() => _PlanlamaPageState();
}

class _PlanlamaPageState extends State<PlanlamaPage> {
  final List<String> days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
  Set<String> selectedMeditationDays = {};
  Set<String> selectedBreathingDays = {};
  List<TextEditingController> taskControllers = [TextEditingController()];

  void addTaskField() {
    if (taskControllers.length < 10) {
      setState(() {
        taskControllers.add(TextEditingController());
      });
    }
  }

  void removeTaskField(int index) {
    setState(() {
      taskControllers.removeAt(index);
    });
  }

  Future<void> savePlan() async {
    DateTime now = DateTime.now();
    String monthName = DateFormat('MMMM', 'tr_TR').format(now);
    int weekOfMonth = ((now.day - 1) ~/ 7) + 1;

    String uniqueId = "$monthName-$weekOfMonth-${DateTime.now().millisecondsSinceEpoch}";

    List<String> tasks = taskControllers.map((c) => c.text).where((t) => t.trim().isNotEmpty).toList();

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .collection("plans")
          .doc(uniqueId)
          .set({
        "month": monthName,
        "week": weekOfMonth,
        "meditationDays": selectedMeditationDays.toList(),
        "breathingDays": selectedBreathingDays.toList(),
        "tasks": tasks,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Plan başarıyla kaydedildi!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PlanlamaMainPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Plan Oluştur"), backgroundColor: Colors.green[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Meditasyon Günleri", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 6,
              children: days.map((day) {
                bool selected = selectedMeditationDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: selected,
                  selectedColor: Colors.green[300],
                  onSelected: (bool sel) {
                    setState(() {
                      if (sel) selectedMeditationDays.add(day);
                      else selectedMeditationDays.remove(day);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text("Nefes Egzersizi Günleri", style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 6,
              children: days.map((day) {
                bool selected = selectedBreathingDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: selected,
                  selectedColor: Colors.teal[300],
                  onSelected: (bool sel) {
                    setState(() {
                      if (sel) selectedBreathingDays.add(day);
                      else selectedBreathingDays.remove(day);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text("Günlük Görevler", style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: List.generate(taskControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: taskControllers[index],
                          decoration: InputDecoration(
                            labelText: "Görev ${index + 1}",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      if (taskControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.red),
                          onPressed: () => removeTaskField(index),
                        ),
                    ],
                  ),
                );
              }),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: addTaskField,
                tooltip: "Yeni görev ekle",
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: savePlan,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                child: const Text("Planı Kaydet"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
