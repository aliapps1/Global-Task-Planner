import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() => runApp(GlobalPlannerApp());

class GlobalPlannerApp extends StatefulWidget {
  @override
  _GlobalPlannerAppState createState() => _GlobalPlannerAppState();
}

class _GlobalPlannerAppState extends State<GlobalPlannerApp> {
  Locale _locale = Locale('fa', '');

  void _changeLanguage(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: [Locale('en', ''), Locale('fa', ''), Locale('ar', '')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // تعریف تم روشن مدرن
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // در حالت اصلی از فونت سیستم استفاده می‌کند
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
      ),
      // تعریف تم تاریک لوکس
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        scaffoldBackgroundColor: Color(0xFF121212),
      ),
      themeMode: ThemeMode.system,
      home: TaskHomeScreen(onLanguageChange: _changeLanguage),
    );
  }
}

class TaskHomeScreen extends StatefulWidget {
  final Function(Locale) onLanguageChange;
  TaskHomeScreen({required this.onLanguageChange});

  @override
  _TaskHomeScreenState createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  List<String> _tasks = [];
  List<String> _times = [];
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = prefs.getStringList('tasks') ?? [];
      _times = prefs.getStringList('times') ?? [];
    });
  }

  _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks', _tasks);
    await prefs.setStringList('times', _times);
  }

  void _handleAddTask() {
    if (_taskController.text.trim().isNotEmpty) {
      String now = DateFormat('HH:mm - yyyy/MM/dd').format(DateTime.now());
      setState(() {
        _tasks.insert(0, _taskController.text.trim());
        _times.insert(0, now);
        _taskController.clear();
      });
      _saveData();
    }
  }

  String _getLabel(String key) {
    String lang = Localizations.localeOf(context).languageCode;
    Map<String, Map<String, String>> words = {
      'fa': {'title': 'برنامه‌ریز هوشمند', 'hint': 'چی تو ذهنته؟', 'empty': 'هنوز کاری ثبت نکردی'},
      'en': {'title': 'Smart Planner', 'hint': 'What is on your mind?', 'empty': 'No tasks yet'},
      'ar': {'title': 'المخطط الذكي', 'hint': 'ماذا يدور في ذهنك؟', 'empty': 'لا توجد مهام بعد'},
    };
    return words[lang]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(_getLabel('title'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: isDark ? Colors.white24 : Colors.black12,
              child: Icon(Icons.language, size: 20, color: isDark ? Colors.white : Colors.black87),
            ),
            onPressed: () {
              String current = Localizations.localeOf(context).languageCode;
              if (current == 'fa') widget.onLanguageChange(Locale('en', ''));
              else if (current == 'en') widget.onLanguageChange(Locale('ar', ''));
              else widget.onLanguageChange(Locale('fa', ''));
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // بخش ورودی مدرن
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: TextField(
                controller: _taskController,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: _getLabel('hint'),
                  filled: true,
                  fillColor: isDark ? Color(0xFF2C2C2C) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                    child: IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.indigoAccent, size: 32),
                      onPressed: _handleAddTask,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // لیست تسک‌ها
          Expanded(
            child: _tasks.isEmpty
                ? Center(child: Text(_getLabel('empty'), style: TextStyle(color: Colors.grey, fontSize: 16)))
                : ListView.builder(
                    padding: EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) => Dismissible(
                      key: UniqueKey(),
                      onDismissed: (_) {
                        setState(() {
                          _tasks.removeAt(index);
                          _times.removeAt(index);
                        });
                        _saveData();
                      },
                      background: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete_sweep, color: Colors.white, size: 30),
                      ),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          leading: Container(
                            width: 12, height: 12,
                            decoration: BoxDecoration(color: Colors.indigoAccent, shape: BoxShape.circle),
                          ),
                          title: Text(_tasks[index], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(_times[index], style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ),
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
