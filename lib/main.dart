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
  void _changeLanguage(String lang) => setState(() => _currentLang = lang);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, primaryColor: const Color(0xFFFFD700)),
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
  Color _selColor = const Color(0xFFFFD700);
  DateTime _selDate = DateTime.now();

  final Map<String, Map<String, String>> _langData = {
    'en': {'n': 'English', 't': 'Elite Planner', 'l': 'Language', 'p': 'Plan for', 'h': 'High', 'm': 'Normal', 'i': 'Idea'},
    'pt': {'n': 'Português', 't': 'Planejador', 'l': 'Idioma', 'p': 'Plano...', 'h': 'Alto', 'm': 'Normal', 'i': 'Ideia'},
    'fr': {'n': 'Français', 't': 'Planificateur', 'l': 'Langue', 'p': 'Plan...', 'h': 'Haut', 'm': 'Normal', 'i': 'Idée'},
    'de': {'n': 'Deutsch', 't': 'Planer', 'l': 'Sprache', 'p': 'Plan...', 'h': 'Hoch', 'm': 'Normal', 'i': 'Idee'},
    'ru': {'n': 'Русский', 't': 'Планировщик', 'l': 'Язык', 'p': 'План...', 'h': 'Срочно', 'm': 'Обычно', 'i': 'Идея'},
    'zh': {'n': '中文', 't': '规划师', 'l': '语言', 'p': '计划...', 'h': '紧急', 'm': '普通', 'i': '主意'},
    'it': {'n': 'Italiano', 't': 'Pianificatore', 'l': 'Lingua', 'p': 'Piano...', 'h': 'Alto', 'm': 'Normale', 'i': 'Idea'},
    'ar': {'n': 'العربية', 't': 'مخطط النخبة', 'l': 'اللغة', 'p': 'خطة لـ', 'h': 'عالي', 'm': 'عادي', 'i': 'فكرة'},
    'fa': {'n': 'فارسی', 't': 'برنامه‌ریز استراتژیک', 'l': 'زبان', 'p': 'برنامه برای', 'h': 'فوری', 'm': 'معمولی', 'i': 'ایده'},
  };

  String _toSolar(DateTime d) {
    int gY = d.year, gM = d.month, gD = d.day;
    var gDMonth = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    int gy2 = (gM > 2) ? (gY + 1) : gY;
    int days = 355666 + (365 * gY) + ((gy2 + 3) ~/ 4) - ((gy2 + 99) ~/ 100) + ((gy2 + 399) ~/ 400) + gD + gDMonth[gM - 1];
    int jy = -1595 + (33 * (days ~/ 12053));
    days %= 12053; jy += 4 * (days ~/ 1461); days %= 1461;
    if (days > 365) { jy += (days - 1) ~/ 365; days = (days - 1) % 365; }
    int jm = (days < 186) ? 1 + (days ~/ 31) : 7 + ((days - 186) ~/ 30);
    int jd = 1 + ((days < 186) ? (days % 31) : ((days - 186) % 30));
    return "$jy/$jm/$jd";
  }

  @override
  void initState() { super.initState(); _loadData(); }
  _loadData() async { final prefs = await SharedPreferences.getInstance(); setState(() => _tasks = prefs.getStringList('tasks_v13_fix') ?? []); }
  _saveData() async { final prefs = await SharedPreferences.getInstance(); await prefs.setStringList('tasks_v13_fix', _tasks); }

  @override
  Widget build(BuildContext context) {
    String solar = _toSolar(_selDate);
    String miladi = "${_selDate.day}/${_selDate.month}/${_selDate.year}";

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(child: Text(_langData[widget.lang]!['t']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Text(widget.lang == 'fa' ? "شمسی: $solar | میلادی: $miladi" : miladi, 
                 style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
            child: Column(
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.language, color: Color(0xFFFFD700), size: 35),
                  onSelected: widget.onLangChange,
                  itemBuilder: (context) => _langData.entries.map((e) => PopupMenuItem(value: e.key, child: Text(e.value['n']!))).toList(),
                ),
                Text(_langData[widget.lang]!['l']!, style: const TextStyle(fontSize: 10, color: Color(0xFFFFD700))),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _prioBtn(const Color(0xFFFFD700), _langData[widget.lang]!['h']!),
              _prioBtn(const Color(0xFF448AFF), _langData[widget.lang]!['m']!),
              _prioBtn(const Color(0xFF9E9E9E), _langData[widget.lang]!['i']!),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
              child: TextField(
                controller: _controller,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: "${_langData[widget.lang]!['p']} ${widget.lang == 'fa' ? solar : miladi}",
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month, color: Colors.white, size: 30),
                    onPressed: () async {
                      DateTime? p = await showDatePicker(context: context, initialDate: _selDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (p != null) setState(() => _selDate = p);
                    },
                  ),
                  suffixIcon: IconButton(icon: Icon(Icons.add_circle, color: _selColor, size: 40), onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      String dLabel = widget.lang == 'fa' ? solar : miladi;
                      setState(() => _tasks.insert(0, "${_controller.text}|$dLabel|${_selColor.value}"));
                      _controller.clear(); _saveData();
                    }
                  }),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                var p = _tasks[index].split('|');
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(15), border: Border(left: BorderSide(color: Color(int.parse(p[2])), width: 8))),
                  child: ListTile(
                    title: Text(p[0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                    subtitle: Text(p[1], style: const TextStyle(fontSize: 14, color: Colors.white38)),
                    trailing: IconButton(icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 28), onPressed: () {
                      setState(() => _tasks.removeAt(index)); _saveData();
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _prioBtn(Color c, String label) {
    bool isS = _selColor.value == c.value;
    return GestureDetector(
      onTap: () => setState(() => _selColor = c),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(children: [
          CircleAvatar(radius: 26, backgroundColor: c, child: isS ? const Icon(Icons.check, size: 28, color: Colors.white) : null),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 15, color: isS ? Colors.white : Colors.white54, fontWeight: isS ? FontWeight.bold : FontWeight.normal)),
        ]),
      ),
    );
  }
}
