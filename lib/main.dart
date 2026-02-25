import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() => runApp(const GlobalElitePlanner());

class GlobalElitePlanner extends StatefulWidget {
  const GlobalElitePlanner({super.key});

  @override
  State<GlobalElitePlanner> createState() => _GlobalElitePlannerState();
}

class _GlobalElitePlannerState extends State<GlobalElitePlanner> {
  String _currentLang = 'en'; // زبان اول انگلیسی مطابق درخواست شما

  void _changeLanguage(String lang) {
    setState(() => _currentLang = lang);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: const Color(0xFF0A0A0B),
        fontFamily: 'sans-serif',
      ),
      home: Directionality(
        textDirection: _currentLang == 'en' ? TextDirection.ltr : TextDirection.rtl,
        child: PlannerScreen(lang: _currentLang, onLangChange: _changeLanguage),
      ),
    );
  }
}

class PlannerScreen extends StatefulWidget {
  final String lang;
  final Function(String) onLangChange;
  const PlannerScreen({super.key, required this.lang, required this.onLangChange});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _tasks = [];
  late String _timeString;
  late Timer _timer;

  final Map<String, Map<String, String>> _labels = {
    'en': {'title': 'Elite Planner', 'hint': 'Next Goal...', 'empty': 'No tasks for today', 'time': 'Local Time'},
    'ar': {'title': 'مخطط النخبة', 'hint': 'الهدف القادم...', 'empty': 'لا توجد مهام اليوم', 'time': 'الوقت المحلي'},
    'fa': {'title': 'برنامه‌ریز نخبگان', 'hint': 'هدف بعدی...', 'empty': 'برنامه‌ای نداری', 'time': 'زمان محلی'},
  };

  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    _loadData();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = _formatDateTime(now);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _tasks = prefs.getStringList('elite_tasks_v5') ?? []);
  }

  _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('elite_tasks_v5', _tasks);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
            Text(_labels[widget.lang]!['title']!, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
            Text('${_labels[widget.lang]!['time']}: $_timeString', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate, color: Color(0xFFFFD700)),
            onSelected: widget.onLangChange,
            itemBuilder: (context) => [
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
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: _labels[widget.lang]!['hint'],
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFFFFD700), size: 30),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() => _tasks.insert(0, "${_controller.text} | ${DateFormat('MMM d').format(DateTime.now())}"));
                        _controller.clear();
                        _saveData();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? Center(child: Text(_labels[widget.lang]!['empty']!, style: const TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.01)]),
                        borderRadius: BorderRadius.circular(15),
                        border: const Border(left: BorderSide(color: Color(0xFFFFD700), width: 4)),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_tasks[index], style: const TextStyle(color: Colors.white, fontSize: 16)),
                        trailing: IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                          onPressed: () {
                            setState(() => _tasks.removeAt(index));
                            _saveData();
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
