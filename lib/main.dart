import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(const SmartPlannerApp());

class SmartPlannerApp extends StatelessWidget {
  const SmartPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const PlannerScreen(),
    );
  }
}

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks(); // لود کردن تسک‌ها هنگام شروع
  }

  // لود کردن از حافظه گوشی
  _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = prefs.getStringList('my_tasks') ?? [];
    });
  }

  // ذخیره در حافظه گوشی
  _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('my_tasks', _tasks);
  }

  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add(_controller.text);
        _controller.clear();
      });
      _saveTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Planner'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'What is on your mind?',
                suffixIcon: IconButton(icon: const Icon(Icons.add_circle, color: Colors.blue), onPressed: _addTask),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onSubmitted: (_) => _addTask(),
            ),
          ),
          Expanded(
            child: _tasks.isEmpty 
              ? const Center(child: Text('No tasks yet')) 
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(_tasks[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => _tasks.removeAt(index));
                        _saveTasks();
                      },
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
