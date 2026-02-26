import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // برای لرزش و صدای سیستم
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const GlobalPlannerApp());

class GlobalPlannerApp extends StatefulWidget {
  const GlobalPlannerApp({super.key});
  @override
  State<GlobalPlannerApp> createState() => _GlobalPlannerAppState();
}

class _GlobalPlannerAppState extends State<GlobalPlannerApp> {
  String _currentLang = 'fa';
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
  TimeOfDay _selTime = TimeOfDay.now();
  Timer? _alarmTimer;

  // بازگشت تمام زبان‌ها طبق تصویر شما
  final Map<String, Map<String, String>> _langData = {
    'en': {'n': 'English', 't': 'Elite Planner', 'p': 'Plan for', 'at': 'at', 'h': 'High', 'm': 'Normal', 'i': 'Idea'},
    'ar': {'n': 'العربية', 't': 'مخطط النخبة', 'p': 'خطة لـ', 'at': 'في', 'h': 'عالي', 'm': 'عادي', 'i': 'فكرة'},
    'fa': {'n': 'فارسی', 't': 'برنامه‌ریز استراتژیک', 'p': 'برنامه برای', 'at': 'ساعت', 'h': 'فوری', 'm': 'معمولی', 'i': 'ایده'},
    'de': {'n': 'Deutsch', 't': 'Planer', 'p': 'Plan für', 'at': 'um', 'h': 'Hoch', 'm': 'Normal', 'i': 'Idee'},
    'ru': {'n': 'Русский', 't': 'Планировщик', 'p': 'План на', 'at': 'в', 'h': 'Сروчно', 'm': 'Обычно', 'i': 'Идея'},
    'fr': {'n': 'Français', 't': 'Planificateur', 'p': 'Plan pour', 'at': 'à', 'h': 'Haut', 'm': 'Normal', 'i': 'Idée'},
    'it': {'n': 'Italiano', 't': 'Pianificatore', 'p': 'Piano per', 'at': 'alle', 'h': 'Alto', 'm': 'Normale', 'i': 'Idea'},
    'pt': {'n': 'Português', 't': 'Planejador', 'p': 'Plano para', 'at': 'às', 'h': 'Alto', 'm': 'Normal', 'i': 'Ideia'},
    'zh': {'n': '中文', 't': '规划师', 'p': '计划于', 'at': '在', 'h': '紧急', 'm': '普通', 'i': '想法'},
  };

  @override
  void initState() { 
    super.initState(); 
    _loadData();
    _alarmTimer = Timer.periodic(const Duration(seconds: 30), (timer) => _checkAlarms());
  }

  @override
  void dispose() { _alarmTimer?.cancel(); super.dispose(); }

  // تابع هوشمند زنگ خوردن (صدا + لرزش)
  void _checkAlarms() {
    final now = DateTime.now();
    final nowStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    
    for (var task in _tasks) {
      if (task.contains("($nowStr)") && !task.startsWith("✔")) {
        HapticFeedback.vibrate(); // لرزش گوشی
        SystemSound.play(SystemSoundType.click); // صدای سیستم
        _showAlarmDialog(task.split('|')[0]);
        break;
      }
    }
  }

  void _showAlarmDialog(String title) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, _, __) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.alarm_on, color: Colors.yellow, size: 60),
        content: Text("⏰ $title", textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          Center(child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context),
            child: const Text("تایید شد / Done"),
          ))
        ],
      ),
    );
  }

  // مبدل شمسی داخلی
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

  _loadData() async { final prefs = await SharedPreferences.getInstance(); setState(() => _tasks = prefs.getStringList('tasks_v20') ?? []); }
  _saveData() async { final prefs = await SharedPreferences.getInstance(); await prefs.setStringList('tasks_v20', _tasks); }

  @override
  Widget build(BuildContext context) {
    String timeStr = "${_selTime.hour.toString().padLeft(2, '0')}:${_selTime.minute.toString().padLeft(2, '0')}";
    String dateLabel = (widget.lang == 'fa') ? _toSolar(_selDate) : "${_selDate.day}/${_selDate.month}/${_selDate.year}";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 100, backgroundColor: Colors.transparent,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_langData[widget.lang]!['t']!, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
          Text("${_langData[widget.lang]!['at']} $timeStr | $dateLabel", style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ]),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.public, color: Color(0xFFFFD700), size: 30),
            onSelected: widget.onLangChange,
            itemBuilder: (context) => _langData.entries.map((e) => PopupMenuItem(value: e.key, child: Text(e.value['n']!))).toList(),
          ),
        ],
      ),
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _prioBtn(const Color(0xFFFFD700), _langData[widget.lang]!['h']!),
          _prioBtn(const Color(0xFF448AFF), _langData[widget.lang]!['m']!),
          _prioBtn(const Color(0xFF9E9E9E), _langData[widget.lang]!['i']!),
        ]),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "${_langData[widget.lang]!['p']} $dateLabel",
              prefixIcon: IconButton(
                icon: CircleAvatar(backgroundColor: _selColor, child: const Icon(Icons.add, color: Colors.black)),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    setState(() => _tasks.insert(0, "${_controller.text}|$dateLabel (${_langData[widget.lang]!['at']} $timeStr)|${_selColor.value}"));
                    _controller.clear(); _saveData();
                  }
                },
              ),
              suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.access_time), onPressed: () async {
                  TimeOfDay? t = await showTimePicker(context: context, initialTime: _selTime);
                  if (t != null) setState(() => _selTime = t);
                }),
                IconButton(icon: const Icon(Icons.calendar_today), onPressed: () async {
                  DateTime? p = await showDatePicker(context: context, initialDate: _selDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (p != null) setState(() => _selDate = p);
                }),
              ]),
              filled: true, fillColor: Colors.white10,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(child: ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            var p = _tasks[index].split('|');
            return Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border(left: BorderSide(color: Color(int.parse(p[2])), width: 5))),
              child: ListTile(
                title: Text(p[0]), subtitle: Text(p[1], style: const TextStyle(fontSize: 10, color: Colors.white38)),
                trailing: IconButton(icon: const Icon(Icons.delete_sweep, color: Colors.redAccent), onPressed: () { setState(() => _tasks.removeAt(index)); _saveData(); }),
              ),
            );
          },
        )),
      ]),
    );
  }

  Widget _prioBtn(Color c, String label) {
    bool isS = _selColor.value == c.value;
    return GestureDetector(
      onTap: () => setState(() => _selColor = c),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Column(children: [
        CircleAvatar(radius: 25, backgroundColor: c, child: isS ? const Icon(Icons.check, color: Colors.white) : null),
        Text(label, style: TextStyle(fontSize: 11, color: isS ? Colors.white : Colors.white54)),
      ])),
    );
  }
}
