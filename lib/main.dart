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
        textDirection: ['ar', 'fa'].contains(_currentLang) ? TextDirection.rtl : TextDirection.ltr,
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
  Color _selectedColor = const Color(0xFFFFD700);
  DateTime _selectedDate = DateTime.now();

  // ترجمه کامل رابط کاربری و زبان‌ها
  final Map<String, Map<String, String>> _uiStrings = {
    'en': {'high': 'High', 'normal': 'Normal', 'idea': 'Idea', 'title': 'Elite Strategic Planner', 'lang': 'Language'},
    'fa': {'high': 'فوری', 'normal': 'معمولی', 'idea': 'ایده', 'title': 'برنامه‌ریز استراتژیک', 'lang': 'زبان'},
    'ar': {'high': 'عالي', 'normal': 'عادي', 'idea': 'فكرة', 'title': 'مخطط النخبة', 'lang': 'اللغة'},
    'pt': {'high': 'Alto', 'normal': 'Normal', 'idea': 'Ideia', 'title': 'Planejador Elite', 'lang': 'Idioma'},
    'fr': {'high': 'Haut', 'normal': 'Normal', 'idea': 'Idée', 'title': 'Planificateur Élite', 'lang': 'Langue'},
    'de': {'high': 'Hoch', 'normal': 'Normal', 'idea': 'Idee', 'title': 'Elite Planer', 'lang': 'Sprache'},
    'ru': {'high': 'Срочно', 'normal': 'Обычно', 'idea': 'Идея', 'title': 'Элитный Планировщик', 'lang': 'Язык'},
    'zh': {'high': '紧急', 'normal': '普通', 'idea': '主意', 'title': '精英规划师', 'lang': '语言'},
    'it': {'high': 'Alto', 'normal': 'Normale', 'idea': 'Idea', 'title': 'Pianificatore Elite', 'lang': 'Lingua'},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _tasks = prefs.getStringList('tasks_v8_strategic') ?? []);
  }

  _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks_v8_strategic', _tasks);
  }

  // انتخاب تاریخ برای آینده
  Future<void> _pickDateTime() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_uiStrings[widget.lang]!['title']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Column(
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.language, color: Color(0xFFFFD700)),
                onSelected: widget.onLangChange,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'en', child: Text('English')),
                  const PopupMenuItem(value: 'pt', child: Text('Português')),
                  const PopupMenuItem(value: 'fr', child: Text('Français')),
                  const PopupMenuItem(value: 'de', child: Text('Deutsch')),
                  const PopupMenuItem(value: 'ru', child: Text('Русский')),
                  const PopupMenuItem(value: 'zh', child: Text('中文')),
                  const PopupMenuItem(value: 'it', child: Text('Italiano')),
                  const PopupMenuItem(value: 'ar', child: Text('العربية')),
                  const PopupMenuItem(value: 'fa', child: Text('فارسی')),
                ],
              ),
              Text(_uiStrings[widget.lang]!['lang']!, style: const TextStyle(fontSize: 8, color: Color(0xFFFFD700))),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _priorityBtn(const Color(0xFFFFD700), _uiStrings[widget.lang]!['high']!),
                _priorityBtn(const Color(0xFF448AFF), _uiStrings[widget.lang]!['normal']!),
                _priorityBtn(const Color(0xFF9E9E9E), _uiStrings[widget.lang]!['idea']!),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "${_selectedDate.day}/${_selectedDate.month} - Plan...",
                prefixIcon: IconButton(icon: const Icon(Icons.calendar_month, color: Colors.white70), onPressed: _pickDateTime),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: _selectedColor),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      String timestamp = "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
                      setState(() => _tasks.insert(0, "${_controller.text}|$timestamp|${_selectedColor.value}"));
                      _controller.clear();
                      _saveData();
                    }
                  },
                ),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                var p = _tasks[index].split('|');
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(right: BorderSide(color: Color(int.parse(p[2])), width: 4)),
                  ),
                  child: ListTile(
                    title: Text(p[0], style: const TextStyle(fontSize: 14)),
                    subtitle: Text(p[1], style: const TextStyle(fontSize: 10, color: Colors.white38)),
                    leading: const Icon(Icons.alarm, size: 18, color: Colors.white24),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _priorityBtn(Color c, String label) {
    bool isSel = _selectedColor.value == c.value;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = c),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            CircleAvatar(radius: 16, backgroundColor: c, child: isSel ? const Icon(Icons.check, size: 16, color: Colors.white) : null),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 9, color: isSel ? Colors.white : Colors.white38)),
          ],
        ),
      ),
    );
  }
}
