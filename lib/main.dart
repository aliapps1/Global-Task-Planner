import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(GlobalPlannerApp());

class GlobalPlannerApp extends StatefulWidget {
  @override
  _GlobalPlannerAppState createState() => _GlobalPlannerAppState();
}

class _GlobalPlannerAppState extends State<GlobalPlannerApp> {
  Locale _locale = Locale('en', ''); // زبان پیش‌فرض

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
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
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
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
  final List<String> _tasks = []; // لیست تسک‌ها
  final TextEditingController _taskController = TextEditingController();

  // تابع ترجمه متون ساده
  String _t(String key) {
    String lang = Localizations.localeOf(context).languageCode;
    Map<String, Map<String, String>> values = {
      'en': {'title': 'Global Planner', 'add': 'Add Task', 'hint': 'Enter task...', 'empty': 'No tasks yet!'},
      'fa': {'title': 'برنامه‌ریز جهانی', 'add': 'افزودن کار', 'hint': 'عنوان کار...', 'empty': 'هنوز کاری اضافه نشده!'},
      'ar': {'title': 'مخطط المهام', 'add': 'إضافة مهمة', 'hint': 'أدخل المهمة...', 'empty': 'لا توجد مهام بعد!'},
    };
    return values[lang]?[key] ?? key;
  }

  void _handleAddTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.insert(0, _taskController.text);
        _taskController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('title'), style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          PopupMenuButton<Locale>(
            icon: Icon(Icons.translate),
            onSelected: widget.onLanguageChange,
            itemBuilder: (context) => [
              PopupMenuItem(value: Locale('en', ''), child: Text("English")),
              PopupMenuItem(value: Locale('fa', ''), child: Text("فارسی")),
              PopupMenuItem(value: Locale('ar', ''), child: Text("العربية")),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      hintText: _t('hint'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _handleAddTask,
                  mini: true,
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tasks.isEmpty
                ? Center(child: Text(_t('empty'), style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(_tasks[index]),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => setState(() => _tasks.removeAt(index)),
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
