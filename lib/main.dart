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
  Color _selectedColor = const Color(0xFFFFD700); // طلایی پیش‌فرض

  // لیست متون راهنما بر اساس زبان و رنگ اولویت
  final Map<String, Map<int, String>> _dynamicHints = {
    'en': {
      0xFFFFD700: 'Urgent Business Goal...',
      0x448AFF: 'Daily Routine Task...',
      0xFF9E9E9E: 'New Creative Idea...',
    },
    'ar': {
      0xFFFFD700: 'هدف تجاري عاجل...',
      0x448AFF: 'مهمة روتينية يومية...',
      0xFF9E9E9E: 'فكرة إبداعية جديدة...',
    },
    'fa': {
      0xFFFFD700: 'هدف فوری بیزینسی...',
      0x448AFF: 'کارهای روتین روزانه...',
      0xFF9E9E9E: 'ایده خلاقانه جدید...',
    },
  };

  final Map<String, String> _titles = {
    'en': 'Global Elite Planner',
    'ar': 'مخطط النخبة العالمي',
    'fa': 'برنامه‌ریز هوشمند جهانی',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _tasks = prefs.getStringList('tasks_v6_final') ?? []);
  }

  _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks_v6_final', _tasks);
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
            Text(_titles[widget.lang]!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold)),
            Text("$timeStr - ${now.day}/${now.month}/${now.year}", style: const TextStyle(color: Colors.white60, fontSize: 11)),
          ],
        ),
        backgroundColor: Colors.transparent,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _colorNode(const Color(0xFFFFD700)),
                _colorNode(Colors.blueAccent),
                _colorNode(Colors.grey),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _selectedColor.withOpacity(0.4)),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  // هوشمندسازی متن راهنما بر اساس رنگ و زبان
                  hintText: _dynamicHints[widget.lang]![_selectedColor.value],
                  filled: true,
                  fillColor: Colors.white10,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add_circle, color: _selectedColor, size: 30),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() => _tasks.insert(0, "${_controller.text}|$timeStr|${_selectedColor.value}"));
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
                var p = _tasks[index].split('|');
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border(left: BorderSide(color: Color(int.parse(p[2])), width: 4)),
                  ),
                  child: ListTile(
                    title: Text(p[0]),
                    subtitle: Text(p[1], style: const TextStyle(fontSize: 10, color: Colors.white38)),
                    trailing: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorNode(Color c) {
    bool isSel = _selectedColor == c;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = c),
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: c, shape: BoxShape.circle,
          border: Border.all(color: isSel ? Colors.white : Colors.transparent, width: 2),
          boxShadow: [if (isSel) BoxShadow(color: c.withOpacity(0.6), blurRadius: 12)],
        ),
      ),
    );
  }
}
