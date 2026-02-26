import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() => runApp(const GlobalEliteApp());

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
  String _timeString = "";

  final Map<String, Map<String, String>> _words = {
    'en': {'t': 'Elite Planner', 'h': 'Add Business Goal...', 'e': 'Focus on your vision', 'l': 'English'},
    'ar': {'t': 'مخطط النخبة', 'h': 'أضف هدفاً تجارياً...', 'e': 'ركز على رؤیتك', 'l': 'العربية'},
    'fa': {'t': 'برنامه‌ریز نخبگان', 'h': 'هدف بیزینسی جدید...', 'e': 'روی رؤیای خود تمرکز کنید', 'l': 'فارسی'},
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
    // آپدیت ساعت زنده امارات در هدر برنامه
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getCurrentTime());
  }

  void _getCurrentTime() {
    if (mounted) {
      setState(() => _timeString = DateFormat('HH:mm:ss').format(DateTime.now()));
    }
  }

  _loadTasks() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _tasks = p.getStringList('elite_v10') ?? []);
  }

  _saveTasks() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('elite_v10', _tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_words[widget.lang]!['t']!, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
            Text("UAE TIME: $_timeString", style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: _words[widget.lang]!['h'],
                  prefixIcon: const Icon(Icons.bolt, color: Color(0xFFFFD700)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFFFFD700), size: 30),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() => _tasks.insert(0, "${_controller.text} • ${DateFormat('jm').format(DateTime.now())}"));
                        _controller.clear();
                        _saveTasks();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? Center(child: Text(_words[widget.lang]!['e']!, style: const TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (c, i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: const Border(left: BorderSide(color: Color(0xFFFFD700), width: 4)),
                      ),
                      child: ListTile(
                        title: Text(_tasks[i], style: const TextStyle(fontWeight: FontWeight.w500)),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
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
