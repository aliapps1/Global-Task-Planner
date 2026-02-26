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
      'hint': 'Next Business Goal...',
      'empty': 'Focus on your vision',
    },
    'ar': {
      'title': 'مخطط النخبة العالمي',
      'hint': 'الهدف التجاري القادم...',
      'empty': 'ركز على رؤيتك',
    },
    'fa': {
      'title': 'برنامه‌ریز هوشمند جهانی',
      'hint': 'هدف بیزینسی بعدی...',
      'empty': 'روی رویای خود تمرکز کنید',
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
  Color _selectedPriorityColor = const Color(0xFFFFD700); // پیش‌فرض طلایی

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _tasks = prefs.getStringList('tasks_v5_priority') ?? []);
  }

  _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks_v5_priority', _tasks);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.values['title']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold)),
            Text("$timeStr - ${now.day}/${now.month}/${now.year}", style: const TextStyle(color: Colors.white60, fontSize: 11)),
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
          // بخش انتخاب اولویت (رنگی)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _priorityCircle(const Color(0xFFFFD700)), // طلایی - High
                _priorityCircle(Colors.blueAccent),      // آبی - Normal
                _priorityCircle(Colors.grey),            // خاکستری - Idea
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _selectedPriorityColor.withOpacity(0.5)),
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
                    icon: Icon(Icons.add_circle, color: _selectedPriorityColor, size: 30),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        // ذخیره کد رنگ به همراه متن
                        setState(() => _tasks.insert(0, "${_controller.text}|$timeStr|${_selectedPriorityColor.value}"));
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
              itemBuilder: (context, index) {
                var parts = _tasks[index].split('|');
                var text = parts[0];
                var time = parts[1];
                var colorVal = int.parse(parts[2]);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border(left: BorderSide(color: Color(colorVal), width: 4)),
                  ),
                  child: ListTile(
                    title: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
                    subtitle: Text(time, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 22),
                      onPressed: () {
                        setState(() => _tasks.removeAt(index));
                        _saveData();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _priorityCircle(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPriorityColor = color),
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedPriorityColor == color ? Colors.white : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (_selectedPriorityColor == color)
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)
          ],
        ),
      ),
    );
  }
}
