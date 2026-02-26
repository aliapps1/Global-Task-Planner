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
  TimeOfDay _selTime = TimeOfDay.now(); // متغیر جدید برای ذخیره ساعت

  final Map<String, Map<String, String>> _langData = {
    'en': {'n': 'English', 't': 'Elite Planner', 'l': 'Language', 'p': 'Plan for', 'h': 'High', 'm': 'Normal', 'i': 'Idea', 'at': 'at'},
    'pt': {'n': 'Português', 't': 'Planejador', 'l': 'Idioma', 'p': 'Plano para', 'h': 'Alto', 'm': 'Normal', 'i': 'Ideia', 'at': 'às'},
    'fr': {'n': 'Français', 't': 'Planificateur', 'l': 'Langue', 'p': 'Plan pour', 'h': 'Haut', 'm': 'Normal', 'i': 'Idée', 'at': 'à'},
    'de': {'n': 'Deutsch', 't': 'Elite Planer', 'l': 'Sprache', 'p': 'Plan für', 'h': 'Hoch', 'm': 'Normal', 'i': 'Idee', 'at': 'um'},
    'ru': {'n': 'Русский', 't': 'Планировщик', 'l': 'Язык', 'p': 'План на', 'h': 'Срочно', 'm': 'Обычно', 'i': 'Идея', 'at': 'в'},
    'zh': {'n': '中文', 't': '精英规划师', 'l': '语言', 'p': '计划用于', 'h': '紧急', 'm': '普通', 'i': '主意', 'at': '在'},
    'it': {'n': 'Italiano', 't': 'Pianificatore', 'l': 'Lingua', 'p': 'Piano per', 'h': 'Alto', 'm': 'Normale', 'i': 'Idea', 'at': 'alle'},
    'ar': {'n': 'العربية', 't': 'مخطط النخبة', 'l': 'اللغة', 'p': 'خطة لـ', 'h': 'عالي', 'm': 'عادي', 'i': 'فكرة', 'at': 'في تمام'},
    'fa': {'n': 'فارسی', 't': 'برنامه‌ریز استراتژیک', 'l': 'زبان', 'p': 'برنامه برای', 'h': 'فوری', 'm': 'معمولی', 'i': 'ایده', 'at': 'ساعت'},
  };

  // تابع تبدیل به شمسی
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

  // تابع تبدیل به قمری
  String _toHijri(DateTime d) {
    int jd = d.difference(DateTime(1900, 1, 1)).inDays + 2415021;
    int l = jd - 1948440 + 10632;
    int n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    int j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) + (l ~/ 5670) * ((43 * l) ~/ 15238);
    l = l - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) - (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    int m = (24 * l) ~/ 709;
    int day = l - (709 * m) ~/ 24;
    int year = 30 * n + j - 30;
    return "$year/${m + 1}/$day";
  }

  @override
  void initState() { super.initState(); _loadData(); }
  _loadData() async { final prefs = await SharedPreferences.getInstance(); setState(() => _tasks = prefs.getStringList('tasks_v17_alarm') ?? []); }
  _saveData() async { final prefs = await SharedPreferences.getInstance(); await prefs.setStringList('tasks_v17_alarm', _tasks); }

  @override
  Widget build(BuildContext context) {
    String miladi = "${_selDate.day}/${_selDate.month}/${_selDate.year}";
    String timeStr = "${_selTime.hour.toString().padLeft(2, '0')}:${_selTime.minute.toString().padLeft(2, '0')}";
    
    String dateLabel = miladi;
    if (widget.lang == 'fa') dateLabel = _toSolar(_selDate);
    else if (widget.lang == 'ar') dateLabel = _toHijri(_selDate);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        toolbarHeight: 110,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(child: Text(_langData[widget.lang]!['t']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 5),
            Text("${_langData[widget.lang]!['at']} $timeStr | $dateLabel", style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Color(0xFFFFD700), size: 30),
            onPressed: () {
              showModalBottomSheet(context: context, itemBuilder: (context) {
                return ListView(children: _langData.entries.map((e) => ListTile(title: Text(e.value['n']!), onTap: () { widget.onLangChange(e.key); Navigator.pop(context); })).toList());
              });
            },
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
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: "${_langData[widget.lang]!['p']} $dateLabel",
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _selColor, shape: BoxShape.circle),
                  child: IconButton(icon: const Icon(Icons.add, color: Colors.black), onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      String finalLabel = "$dateLabel (${_langData[widget.lang]!['at']} $timeStr)";
                      setState(() => _tasks.insert(0, "${_controller.text}|$finalLabel|${_selColor.value}"));
                      _controller.clear(); _saveData();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Alarm set for $timeStr")));
                    }
                  }),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.access_time, color: Colors.white70), onPressed: () async {
                      TimeOfDay? t = await showTimePicker(context: context, initialTime: _selTime);
                      if (t != null) setState(() => _selTime = t);
                    }),
                    IconButton(icon: const Icon(Icons.calendar_month, color: Colors.white), onPressed: () async {
                      DateTime? p = await showDatePicker(context: context, initialDate: _selDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (p != null) setState(() => _selDate = p);
                    }),
                  ],
                ),
                filled: true, fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
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
                    title: Text(p[0], style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                    subtitle: Text(p[1], style: const TextStyle(fontSize: 12, color: Colors.white38)),
                    trailing: IconButton(icon: const Icon(Icons.check_circle, color: Colors.greenAccent), onPressed: () {
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
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(children: [
          CircleAvatar(radius: 24, backgroundColor: c, child: isS ? const Icon(Icons.check, color: Colors.white) : null),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: isS ? Colors.white : Colors.white54)),
        ]),
      ),
    );
  }
}
