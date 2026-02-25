import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() => runApp(const GlobalPlannerApp());

class GlobalPlannerApp extends StatefulWidget {
  const GlobalPlannerApp({super.key});

  @override
  State<GlobalPlannerApp> createState() => _GlobalPlannerAppState();
}

class _GlobalPlannerAppState extends State<GlobalPlannerApp> {
  // اولویت اول: انگلیسی
  String _currentLang = 'en';

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Global Elite Planner',
      'hint': 'What is your next goal?',
      'empty': 'Your schedule is clear',
      'add': 'Add Task',
    },
    'ar': {
      'title': 'مخطط النخبة العالمي',
      'hint': 'ما هو هدفك القادم؟',
      'empty': 'جدولك خالي حالياً',
      'add': 'إضافة مهمة',
    },
    'fa': {
      'title': 'برنامه‌ریز هوشمند جهانی',
      'hint': 'هدف بعدی شما چیست؟',
      'empty': 'لیست برنامه‌های شما خالی است',
      'add': 'ثبت کار',
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
        fontFamily: _currentLang == 'en' ? 'Roboto' : 'Tahoma',
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
    setState(() => _tasks = prefs.getStringList('global_elite_tasks') ?? []);
  }

  _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('global_elite_tasks', _tasks);
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.values['title']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18)),
            Text(today, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // چیدمان انتخابی شما: انگلیسی، عربی، فارسی
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Color(0xFFFFD700)),
            onSelected: widget.onLangChange,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en', child: Text('🇬🇧 English')),
              const PopupMenuItem(value: 'ar', child: Text('🇦🇪 العربية')),
              const PopupMenuItem(value: 'fa', child: Text('🇮🇷 فارسی')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.values['hint'],
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFFFFD700), size: 30),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() => _tasks.insert(0, _controller.text));
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
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_tasks[index] + index.toString()),
                  onDismissed: (direction) {
                    setState(() => _tasks.removeAt(index));
                    _saveData();
                  },
                  background: Container(color: Colors.redAccent.withOpacity(0.2), child: const Icon(Icons.delete)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.star_border, color: Color(0xFFFFD700)),
                      title: Text(_tasks[index], style: const TextStyle(color: Colors.white)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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
}
