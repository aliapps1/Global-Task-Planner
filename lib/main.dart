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

  // بومی‌سازی کامل متون و سایزهای بزرگتر
  final Map<String, Map<String, String>> _uiStrings = {
    'en': {'high': 'High', 'normal': 'Normal', 'idea': 'Idea', 'title': 'Elite Strategic Planner', 'lang': 'Language', 'plan': 'Plan for'},
    'fa': {'high': 'فوری', 'normal': 'معمولی', 'idea': 'ایده', 'title': 'برنامه‌ریز استراتژیک', 'lang': 'زبان', 'plan': 'برنامه برای'},
    'ar': {'high': 'عالي', 'normal': 'عادي', 'idea': 'فكرة', 'title': 'مخطط النخبة', 'lang': 'اللغة', 'plan': 'خطة لـ'},
    'pt': {'high': 'Alto', 'normal': 'Normal', 'idea': 'Ideia', 'title': 'Planejador Elite', 'lang': 'Idioma', 'plan': 'Plano para'},
    'fr': {'high': 'Haut', 'normal': 'Normal', 'idea': 'Idée', 'title': 'Planificateur Élite', 'lang': 'Langue', 'plan': 'Plan pour'},
    'de': {'high': 'Hoch', 'normal': 'Normal', 'idea': 'Idee', 'title': 'Elite Planer', 'lang': 'Sprache', 'plan': 'Plan für'},
    'ru': {'high': 'Срочно', 'normal': 'Обычно', 'idea': 'Идея', 'title': 'Элитный Планировщик', 'lang': 'Язык', 'plan': 'План на'},
    'zh': {'high': '紧急', 'normal': '普通', 'idea': '主意', 'title': '精英规划师', 'lang': '语言', 'plan': '计划用于'},
    'it': {'high': 'Alto', 'normal': 'Normale', 'idea': 'Idea', 'title': 'Pianificatore Elite', 'lang': 'Lingua', 'plan': 'Piano per'},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _tasks = prefs.getStringList('tasks_v9_large') ?? []);
  }

  _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tasks_v9_large', _tasks);
  }

  Future<void> _pickDateTime() async {
    DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // افزایش ارتفاع اپ‌بار
        title: Text(_uiStrings[widget.lang]!['title']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.language, color: Color(0xFFFFD700), size: 35), // دکمه زبان بزرگتر
                  onSelected: widget.onLangChange,
                  itemBuilder: (context) => _uiStrings.keys.map((String key) => PopupMenuItem(value: key, child: Text(key.toUpperCase(), style: const TextStyle(fontSize: 18)))).toList(),
                ),
                Text(_uiStrings[widget.lang]!['lang']!, style: const TextStyle(fontSize: 12, color: Color(0xFFFFD700))),
              ],
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _priorityBtn(const Color(0xFFFFD700), _uiStrings[widget.lang]!['high']!),
              _priorityBtn(const Color(0xFF448AFF), _uiStrings[widget.lang]!['normal']!),
              _priorityBtn(const Color(0xFF9E9E9E), _uiStrings[widget.lang]!['idea']!),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 20), // متن ورودی بزرگتر
              decoration: InputDecoration(
                hintText: "${_uiStrings[widget.lang]!['plan']} ${_selectedDate.day}/${_selectedDate.month}...",
                prefixIcon: IconButton(icon: const Icon(Icons.calendar_month, color: Colors.white, size: 30), onPressed: _pickDateTime),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: _selectedColor, size: 35),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      String date = "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
                      setState(() => _tasks.insert(0, "${_controller.text}|$date|${_selectedColor.value}"));
                      _controller.clear();
                      _saveData();
                    }
                  },
                ),
                filled: true,
                fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                var p = _tasks[index].split('|');
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(15),
                    border: Border(left: BorderSide(color: Color(int.parse(p[2])), width: 6)), // نوار ضخیم‌تر
                  ),
                  child: ListTile(
                    title: Text(p[0], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)), // فونت تسک بزرگتر
                    subtitle: Text(p[1], style: const TextStyle(fontSize: 13, color: Colors.white38)),
                    leading: const Icon(Icons.alarm, size: 24, color: Colors.white30),
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            CircleAvatar(radius: 22, backgroundColor: c, child: isSel ? const Icon(Icons.check, size: 25, color: Colors.white) : null), // دایره‌های بزرگتر
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 14, color: isSel ? Colors.white : Colors.white38, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
