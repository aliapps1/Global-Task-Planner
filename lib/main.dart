import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const GlobalPlannerApp());

class GlobalPlannerApp extends StatefulWidget {
  const GlobalPlannerApp({super.key});

  @override
  State<GlobalPlannerApp> createState() => _GlobalPlannerAppState();
}

class _GlobalPlannerAppState extends State<GlobalPlannerApp> {
  String _currentLang = 'en';

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Global Elite Planner',
      'hint': 'What is your next goal?',
      'empty': 'Your schedule is clear',
    },
    'ar': {
      'title': 'مخطط النخبة العالمي',
      'hint': 'ما هو هدفك القادم؟',
      'empty': 'جدولك خالي حالياً',
    },
    'fa': {
      'title': 'برنامه‌ریز هوشمند جهانی',
      'hint': 'هدف بعدی شما چیست؟',
      'empty': 'لیست برنامه‌های شما خالی است',
    },
  };

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
      ),
      home: Directionality(
        textDirection: _currentLang == 'en' ? TextDirection.ltr : TextDirection.rtl,
        child: PlannerScreen(
          lang: _currentLang,
          values: _localizedValues[_currentLang]!,
          onLangChange: _changeLanguage,
        ),
      ),
    );
  }
}

class PlannerScreen extends StatefulWidget {
  final String lang;
  final Map<String, String> values;
  final Function(String) onLangChange;

  const PlannerScreen({super.key, required this.lang, required this.values, required this.onLangChange});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _tasks = prefs.getStringList('tasks_v3') ?? []);
  }

  _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks_v3', _tasks);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
    final dateStr = "${now.day}/${now.month}/${now.year}";

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.values['title']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold)),
            Text("$timeStr - $dateStr", style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Color(0xFFFFD700)),
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
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.values['hint'],
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFFFFD700), size: 30),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() => _tasks.insert(0, "${_controller.text} [$timeStr]"));
                        _controller.clear();
                        _saveData();
                      }
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  // اضافه کردن نوار طلایی کنار هر تسک برای حس لوکس بودن
                  border: const Border(left: BorderSide(color: Color(0xFFFFD700), width: 3)),
                ),
                child: ListTile(
                  title: Text(_tasks[index], style: const TextStyle(color: Colors.white, fontSize: 15)),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 22),
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
