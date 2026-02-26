import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const GlobalPlannerApp());

class GlobalPlannerApp extends StatefulWidget {
  const GlobalEliteApp({super.key}); // نام را برای کلاس حفظ کردیم

  @override
  State<GlobalPlannerApp> createState() => _GlobalPlannerAppState();
}

class _GlobalEliteAppState extends State<GlobalPlannerApp> {
  String _currentLang = 'en'; // ۱. انگلیسی ۲. عربی ۳. فارسی

  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Elite Global Planner',
      'hint': 'Next Business Goal...',
      'empty': 'Your schedule is clear',
      'time': 'Local Time',
    },
    'ar': {
      'title': 'مخطط النخبة العالمي',
      'hint': 'ما هو هدفك القادم؟',
      'empty': 'جدولك خالي حالياً',
      'time': 'الوقت المحلي',
    },
    'fa': {
      'title': 'برنامه‌ریز هوشمند جهانی',
      'hint': 'هدف بعدی شما چیست؟',
      'empty': 'لیست برنامه‌های شما خالی است',
      'time': 'زمان محلی',
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

  // گرفتن زمان فعلی بدون نیاز به پکیج خارجی (برای جلوگیری از قرمز شدن)
  String _getFormattedTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  // گرفتن تاریخ روز
  String _getFormattedDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _tasks = prefs.getStringList('tasks_v4') ?? []);
  }

  _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks_v4', _tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // اضافه کردن ساعت زنده به هدر برنامه
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.values['title']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18)),
            Text("${widget.values['time']}: ${_getFormattedTime()} - ${_getFormattedDate()}", 
                 style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.values['hint'],
                  filled: true,
                  fillColor: Colors.white10,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFFFFD700), size: 30),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        // اضافه کردن تسک همراه با ساعت ثبت (قابلیتی فراتر از نوت گوشی)
                        setState(() => _tasks.insert(0, "${_controller.text} (${_getFormattedTime()})"));
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
              itemBuilder: (context, index) => Card(
                color: Colors.white.withOpacity(0.05),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white10, width: 0.5),
                ),
                child: ListTile(
                  leading: const Icon(Icons.star_border, color: Color(0xFFFFD700), size: 20),
                  title: Text(_tasks[index], style: const TextStyle(fontSize: 15)),
                  trailing: IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
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
