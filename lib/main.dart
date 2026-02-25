import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GlobalEliteApp());
}

class GlobalEliteApp extends StatefulWidget {
  const GlobalEliteApp({super.key});

  @override
  State<GlobalEliteApp> createState() => _GlobalEliteAppState();
}

class _GlobalEliteAppState extends State<GlobalEliteApp> {
  String _lang = 'en'; // اولویت اول: انگلیسی

  void _updateLang(String newLang) => setState(() => _lang = newLang);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: const Color(0xFF0A0A0B),
      ),
      // تنظیم جهت صفحه: انگلیسی (چپ به راست)، بقیه (راست به چپ)
      home: Directionality(
        textDirection: _lang == 'en' ? TextDirection.ltr : TextDirection.rtl,
        child: EliteHomeScreen(lang: _lang, onLangChange: _updateLang),
      ),
    );
  }
}

class EliteHomeScreen extends StatefulWidget {
  final String lang;
  final Function(String) onLangChange;
  const EliteHomeScreen({super.key, required this.lang, required this.onLangChange});

  @override
  State<EliteHomeScreen> createState() => _EliteHomeScreenState();
}

class _EliteHomeScreenState extends State<EliteHomeScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _tasks = [];
  String _localTime = "";

  final Map<String, Map<String, String>> _words = {
    'en': {'t': 'Elite Planner', 'h': 'Next Goal...', 'e': 'No tasks', 'l': 'English'},
    'ar': {'t': 'مخطط النخبة', 'h': 'الهدف القادم...', 'e': 'لا يوجد مهام', 'l': 'العربية'},
    'fa': {'t': 'برنامه‌ریز نخبگان', 'h': 'هدف بعدی...', 'e': 'لیست خالی است', 'l': 'فارسی'},
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _localTime = DateFormat('HH:mm:ss').format(DateTime.now()));
    });
  }

  _loadTasks() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _tasks = p.getStringList('elite_v1') ?? []);
  }

  _saveTasks() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('elite_v1', _tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_words[widget.lang]!['t']!, style: const TextStyle(color: Color(0xFFFFD700))),
            Text("UAE Time: $_localTime", style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Color(0xFFFFD700)),
            onSelected: widget.onLangChange,
            itemBuilder: (c) => [
              const PopupMenuItem(value: 'en', child: Text('1. English')),
              const PopupMenuItem(value: 'ar', child: Text('2. العربية')),
              const PopupMenuItem(value: 'fa', child: Text('3. فارسی')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: _words[widget.lang]!['h'],
                prefixIcon: const Icon(Icons.star, color: Color(0xFFFFD700)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFFFFD700)),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() => _tasks.insert(0, _controller.text));
                      _controller.clear();
                      _saveTasks();
                    }
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? Center(child: Text(_words[widget.lang]!['e']!))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (c, i) => Card(
                      color: Colors.white10,
                      child: ListTile(
                        title: Text(_tasks[i]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () {
                            setState(() => _tasks.removeAt(i));
                            _saveTasks();
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
