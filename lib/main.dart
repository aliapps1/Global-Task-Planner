import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart'; // برای حافظه
import 'dart:convert'; // برای تبدیل لیست به متن

void main() => runApp(GlobalPlannerApp());

class GlobalPlannerApp extends StatefulWidget {
  @override
  _GlobalPlannerAppState createState() => _GlobalPlannerAppState();
}

class _GlobalPlannerAppState extends State<GlobalPlannerApp> {
  Locale _locale = Locale('en', '');

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
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
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
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks(); // به محض باز شدن برنامه، کارها را از حافظه بخوان
  }

  // --- توابع حافظه ---
  _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _tasks = prefs.getStringList('user_tasks') ?? [];
    });
  }

  _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_tasks', _tasks);
  }
  // ------------------

  void _handleAddTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.insert(0, _taskController.text);
        _taskController.clear();
      });
      _saveTasks(); // ذخیره بعد از اضافه کردن
    }
  }

  void _handleDeleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks(); // ذخیره بعد از حذف کردن
  }

  String _t(String key) {
    String lang = Localizations.localeOf(context).languageCode;
    Map<String, Map<String, String>> values = {
      'en': {'title': 'Global Planner', 'hint': 'Enter task...', 'empty': 'No tasks!'},
      'fa': {'title': 'برنامه‌ریز جهانی', 'hint': 'کار جدید...', 'empty': 'لیست خالی است!'},
      'ar': {'title': 'مخطط المهام', 'hint': 'مهمة جديدة...', 'empty': 'لا يوجد مهام!'},
    };
    return values[lang]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('title')),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              // سوئیچ سریع بین زبان‌ها برای تست
              Locale current = Localizations.localeOf(context);
              if (current.languageCode == 'en') widget.onLanguageChange(Locale('fa', ''));
              else if (current.languageCode == 'fa') widget.onLanguageChange(Locale('ar', ''));
              else widget.onLanguageChange(Locale('en', ''));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _taskController, decoration: InputDecoration(hintText: _t('hint')))),
                IconButton(icon: Icon(Icons.add_box, size: 40, color: Colors.indigo), onPressed: _handleAddTask),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? Center(child: Text(_t('empty')))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) => Card(
                      child: ListTile(
                        title: Text(_tasks[index]),
                        trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _handleDeleteTask(index)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
