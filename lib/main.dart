import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const GlobalPlannerApp());

class GlobalPlannerApp extends StatefulWidget {
  const GlobalPlannerApp({super.key});

  @override
  State<GlobalPlannerApp> createState() => _GlobalPlannerAppState();
}

class _GlobalPlannerAppState extends State<GlobalPlannerApp> {
  // تنظیم انگلیسی به عنوان زبان پیش‌فرض (اولین زبان)
  String _currentLang = 'en';

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Global Task Planner',
      'hint': 'What needs to be done?',
      'empty': 'Your task list is empty',
      'button': 'Add',
      'langName': 'English',
    },
    'ar': {
      'title': 'مخطط المهام العالمي',
      'hint': 'ما الذي يجب فعله؟',
      'empty': 'قائمة المهام فارغة',
      'button': 'إضافة',
      'langName': 'العربية',
    },
    'fa': {
      'title': 'برنامه‌ریز جهانی کارهای من',
      'hint': 'چه کاری باید انجام شود؟',
      'empty': 'لیست کارهای شما خالی است',
      'button': 'افزودن',
      'langName': 'فارسی',
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
        primaryColor: const Color(0xFFFFD700), // طلایی برای حس لوکس بودن (Luxury View)
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        fontFamily: 'sans-serif',
      ),
      // تنظیم جهت صفحه بر اساس زبان انتخابی
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
    setState(() => _tasks = prefs.getStringList('global_tasks_v2') ?? []);
  }

  _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('global_tasks_v2', _tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.values['title']!, 
          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 10,
        actions: [
          // لیست انتخاب زبان با اولویت درخواستی شما
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: widget.values['hint'],
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_task, color: Color(0xFFFFD700)),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      setState(() => _tasks.insert(0, _controller.text.trim()));
                      _controller.clear();
                      _saveData();
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? Center(child: Text(widget.values['empty']!, style: const TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        title: Text(_tasks[index], style: const TextStyle(color: Colors.white, fontSize: 16)),
                        leading: const Icon(Icons.circle, color: Color(0xFFFFD700), size: 12),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
