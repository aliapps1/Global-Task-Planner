import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // برای کار با تاریخ و ساعت

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
  List<String> _tasks = []; // متن تسک‌ها
  List<String> _times = []; // زمان ثبت تسک‌ها
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
    if (_taskController.text.isNotEmpty) {
      String now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
      setState(() {
        _tasks.insert(0, _taskController.text);
        _times.insert(0, now);
        _taskController.clear();
      });
      _saveData();
    }
  }

  void _handleDelete(int index) {
    setState(() {
      _tasks.removeAt(index);
      _times.removeAt(index);
    });
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    String lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'fa' ? 'برنامه‌ریز' : (lang == 'ar' ? 'المخطط' : 'Planner')),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              if (lang == 'en') widget.onLanguageChange(Locale('fa', ''));
              else if (lang == 'fa') widget.onLanguageChange(Locale('ar', ''));
              else widget.onLanguageChange(Locale('en', ''));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: lang == 'fa' ? 'چی تو ذهنته؟' : 'What is on your mind?',
                suffixIcon: IconButton(icon: Icon(Icons.add_circle, color: Colors.indigo), onPressed: _handleAddTask),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(_tasks[index]),
                  subtitle: Text(_times[index], style: TextStyle(fontSize: 10, color: Colors.grey)),
                  trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red[300]), onPressed: () => _handleDelete(index)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
