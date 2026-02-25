import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(GlobalPlannerApp());

class GlobalPlannerApp extends StatefulWidget {
  @override
  _GlobalPlannerAppState createState() => _GlobalPlannerAppState();
}

class _GlobalPlannerAppState extends State<GlobalPlannerApp> {
  // زبان پیش‌فرض: انگلیسی
  Locale _locale = Locale('en', '');

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
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: TaskHomeScreen(onLanguageChange: _changeLanguage),
    );
  }
}

class TaskHomeScreen extends StatelessWidget {
  final Function(Locale) onLanguageChange;
  TaskHomeScreen({required this.onLanguageChange});

  // متون ترجمه شده ساده
  String _getTitle(BuildContext context) {
    if (Localizations.localeOf(context).languageCode == 'fa') return "برنامه‌ریز جهانی";
    if (Localizations.localeOf(context).languageCode == 'ar') return "مخطط المهام العالمي";
    return "Global Task Planner";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(context)),
        actions: [
          PopupMenuButton<Locale>(
            icon: Icon(Icons.language),
            onSelected: onLanguageChange,
            itemBuilder: (context) => [
              PopupMenuItem(value: Locale('en', ''), child: Text("English")),
              PopupMenuItem(value: Locale('fa', ''), child: Text("فارسی")),
              PopupMenuItem(value: Locale('ar', ''), child: Text("العربية")),
            ],
          )
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text(Localizations.localeOf(context).languageCode == 'fa' ? "اولین کار من" : "My First Task"),
              subtitle: Text("Priority: High"),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}
