import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      title: 'Global Task Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFD700),
      ),
      home: Directionality(
        textDirection:
            ['ar', 'fa'].contains(_currentLang) ? TextDirection.rtl : TextDirection.ltr,
        child: PlannerScreen(
          lang: _currentLang,
          onLangChange: _changeLanguage,
        ),
      ),
    );
  }
}

class PlannerTask {
  String id;
  String title;
  String note;
  String type;
  String priority;
  int color;
  DateTime date;
  String? time;
  bool completed;
  String repeat;
  bool reminded;

  PlannerTask({
    required this.id,
    required this.title,
    required this.note,
    required this.type,
    required this.priority,
    required this.color,
    required this.date,
    required this.time,
    required this.completed,
    required this.repeat,
    required this.reminded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'note': note,
        'type': type,
        'priority': priority,
        'color': color,
        'date': date.toIso8601String(),
        'time': time,
        'completed': completed,
        'repeat': repeat,
        'reminded': reminded,
      };

  factory PlannerTask.fromJson(Map<String, dynamic> json) {
    return PlannerTask(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      note: json['note'] ?? '',
      type: json['type'] ?? 'task',
      priority: json['priority'] ?? 'high',
      color: json['color'] ?? 0xFFFFD700,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: json['time'],
      completed: json['completed'] ?? false,
      repeat: json['repeat'] ?? 'none',
      reminded: json['reminded'] ?? false,
    );
  }
}

class PlannerScreen extends StatefulWidget {
  final String lang;
  final Function(String) onLangChange;

  const PlannerScreen({
    super.key,
    required this.lang,
    required this.onLangChange,
  });

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<PlannerTask> _tasks = [];

  Color _selColor = const Color(0xFFFFD700);
  String _selPriority = 'high';
  String _selType = 'task';
  String _selRepeat = 'none';
  String _filter = 'all';

  DateTime _selDate = DateTime.now();
  TimeOfDay? _selTime;

  Timer? _alarmTimer;

  final Map<String, Map<String, String>> _langData = {
    'en': {
      'n': 'English',
      't': 'Elite Planner',
      'p': 'Plan for',
      'h': 'High',
      'm': 'Normal',
      'i': 'Idea',
      'l': 'Language',
      'task': 'Task',
      'project': 'Project',
      'all': 'All',
      'done': 'Done',
      'search': 'Search',
      'repeat': 'Repeat',
      'none': 'None',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'save': 'Save',
      'edit': 'Edit',
      'note': 'Note',
      'today': 'Today',
      'total': 'Total',
      'completed': 'Completed',
      'pending': 'Pending',
    },
    'ar': {
      'n': 'العربية',
      't': 'مخطط النخبة',
      'p': 'خطة لـ',
      'h': 'عالي',
      'm': 'عادي',
      'i': 'فكرة',
      'l': 'اللغة',
      'task': 'مهمة',
      'project': 'مشروع',
      'all': 'الكل',
      'done': 'تم',
      'search': 'بحث',
      'repeat': 'تكرار',
      'none': 'بدون',
      'daily': 'يومي',
      'weekly': 'أسبوعي',
      'monthly': 'شهري',
      'save': 'حفظ',
      'edit': 'تعديل',
      'note': 'ملاحظة',
      'today': 'اليوم',
      'total': 'المجموع',
      'completed': 'مكتمل',
      'pending': 'متبقي',
    },
    'fa': {
      'n': 'فارسی',
      't': 'برنامه‌ریز استراتژیک',
      'p': 'برنامه برای',
      'h': 'فوری',
      'm': 'معمولی',
      'i': 'ایده',
      'l': 'زبان',
      'task': 'کار',
      'project': 'پروژه',
      'all': 'همه',
      'done': 'انجام‌شده',
      'search': 'جستجو',
      'repeat': 'تکرار',
      'none': 'ندارد',
      'daily': 'روزانه',
      'weekly': 'هفتگی',
      'monthly': 'ماهانه',
      'save': 'ذخیره',
      'edit': 'ویرایش',
      'note': 'یادداشت',
      'today': 'امروز',
      'total': 'کل',
      'completed': 'انجام‌شده',
      'pending': 'مانده',
    },
  };

  Map<String, String> get tr => _langData[widget.lang] ?? _langData['en']!;

  @override
  void initState() {
    super.initState();
    _loadData();
    _alarmTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkAlarms(),
    );
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    _titleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final newData = prefs.getStringList('tasks_v40');
    if (newData != null) {
      setState(() {
        _tasks = newData
            .map((e) => PlannerTask.fromJson(jsonDecode(e)))
            .toList();
      });
      return;
    }

    final oldData = prefs.getStringList('tasks_v26') ?? [];
    setState(() {
      _tasks = oldData.map((old) {
        final p = old.split('|');
        return PlannerTask(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: p.isNotEmpty ? p[0] : '',
          note: '',
          type: 'task',
          priority: 'high',
          color: p.length > 2 ? int.tryParse(p[2]) ?? 0xFFFFD700 : 0xFFFFD700,
          date: DateTime.now(),
          time: null,
          completed: false,
          repeat: 'none',
          reminded: false,
        );
      }).toList();
    });
    _saveData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'tasks_v40',
      _tasks.map((t) => jsonEncode(t.toJson())).toList(),
    );
  }

  void _addTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final timeText = _selTime == null
        ? null
        : '${_selTime!.hour.toString().padLeft(2, '0')}:${_selTime!.minute.toString().padLeft(2, '0')}';

    final task = PlannerTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      note: '',
      type: _selType,
      priority: _selPriority,
      color: _selColor.value,
      date: _selDate,
      time: timeText,
      completed: false,
      repeat: _selRepeat,
      reminded: false,
    );

    setState(() {
      _tasks.insert(0, task);
      _titleController.clear();
      _selTime = null;
      _selRepeat = 'none';
    });

    _saveData();
  }

  void _toggleDone(int index) {
    setState(() {
      _tasks[index].completed = !_tasks[index].completed;
    });
    _saveData();
  }

  void _deleteTask(int index) {
    setState(() => _tasks.removeAt(index));
    _saveData();
  }

  void _editTask(int index) {
    final task = _tasks[index];
    final titleCtrl = TextEditingController(text: task.title);
    final noteCtrl = TextEditingController(text: task.note);

    String type = task.type;
    String repeat = task.repeat;
    DateTime date = task.date;
    String? time = task.time;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(tr['edit']!),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(labelText: tr['task']),
                  ),
                  TextField(
                    controller: noteCtrl,
                    decoration: InputDecoration(labelText: tr['note']),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: type,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(value: 'task', child: Text(tr['task']!)),
                      DropdownMenuItem(value: 'idea', child: Text(tr['i']!)),
                      DropdownMenuItem(value: 'project', child: Text(tr['project']!)),
                    ],
                    onChanged: (v) => setDialogState(() => type = v ?? 'task'),
                  ),
                  DropdownButton<String>(
                    value: repeat,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(value: 'none', child: Text(tr['none']!)),
                      DropdownMenuItem(value: 'daily', child: Text(tr['daily']!)),
                      DropdownMenuItem(value: 'weekly', child: Text(tr['weekly']!)),
                      DropdownMenuItem(value: 'monthly', child: Text(tr['monthly']!)),
                    ],
                    onChanged: (v) => setDialogState(() => repeat = v ?? 'none'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_formatDate(date)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setDialogState(() => date = picked);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              time =
                                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (time != null) Text(time!),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    task.title = titleCtrl.text.trim();
                    task.note = noteCtrl.text.trim();
                    task.type = type;
                    task.repeat = repeat;
                    task.date = date;
                    task.time = time;
                    task.reminded = false;
                  });
                  _saveData();
                  Navigator.pop(context);
                },
                child: Text(tr['save']!),
              ),
            ],
          );
        },
      ),
    );
  }

  void _checkAlarms() {
    final now = DateTime.now();
    final nowTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (final task in _tasks) {
      final sameDay = task.date.year == now.year &&
          task.date.month == now.month &&
          task.date.day == now.day;

      if (!task.completed &&
          !task.reminded &&
          sameDay &&
          task.time == nowTime) {
        task.reminded = true;
        _saveData();
        HapticFeedback.vibrate();
        _showAlarmDialog(task);
        break;
      }
    }
  }

  void _showAlarmDialog(PlannerTask task) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.alarm, color: Color(0xFFFFD700), size: 50),
        content: Text(
          task.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  List<PlannerTask> get _visibleTasks {
    final q = _searchController.text.trim().toLowerCase();

    return _tasks.where((t) {
      final matchSearch = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.note.toLowerCase().contains(q);

      final matchFilter = _filter == 'all' ||
          (_filter == 'done' && t.completed) ||
          (_filter == 'high' && t.priority == 'high') ||
          (_filter == 'normal' && t.priority == 'normal') ||
          (_filter == 'idea' && t.type == 'idea') ||
          (_filter == 'project' && t.type == 'project');

      return matchSearch && matchFilter;
    }).toList();
  }

  String _formatDate(DateTime d) {
    if (widget.lang == 'fa') return _toSolar(d);
    return '${d.day}/${d.month}/${d.year}';
  }

  String _toSolar(DateTime d) {
    int gY = d.year, gM = d.month, gD = d.day;
    var gDMonth = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    int gy2 = (gM > 2) ? (gY + 1) : gY;
    int days = 355666 +
        (365 * gY) +
        ((gy2 + 3) ~/ 4) -
        ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) +
        gD +
        gDMonth[gM - 1];
    int jy = -1595 + (33 * (days ~/ 12053));
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }
    int jm = (days < 186) ? 1 + (days ~/ 31) : 7 + ((days - 186) ~/ 30);
    int jd = 1 + ((days < 186) ? (days % 31) : ((days - 186) % 30));
    return '$jy/$jm/$jd';
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleTasks;
    final total = _tasks.length;
    final done = _tasks.where((t) => t.completed).length;
    final pending = total - done;
    final progress = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 105,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.language, color: Color(0xFFFFD700), size: 28),
                onSelected: widget.onLangChange,
                itemBuilder: (context) => _langData.entries
                    .map((e) => PopupMenuItem(value: e.key, child: Text(e.value['n']!)))
                    .toList(),
              ),
              Text(
                tr['l']!,
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10),
              ),
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tr['t']!,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              _formatDate(_selDate),
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _statsBox(total, done, pending, progress),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _prioBtn(const Color(0xFFFFD700), tr['h']!, 'high'),
              _prioBtn(const Color(0xFF448AFF), tr['m']!, 'normal'),
              _prioBtn(const Color(0xFF9E9E9E), tr['i']!, 'idea'),
            ],
          ),
          const SizedBox(height: 12),
          _typeRow(),
          const SizedBox(height: 12),
          _inputBox(),
          const SizedBox(height: 8),
          _searchBox(),
          const SizedBox(height: 8),
          _filterRow(),
          const SizedBox(height: 8),
          Expanded(
            child: visible.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final task = visible[index];
                      final realIndex = _tasks.indexWhere((x) => x.id == task.id);
                      return _taskCard(task, realIndex);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statsBox(int total, int done, int pending, double progress) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(tr['total']!, total.toString()),
              _statItem(tr['completed']!, done.toString()),
              _statItem(tr['pending']!, pending.toString()),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            color: const Color(0xFFFFD700),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _prioBtn(Color c, String label, String priority) {
    final isSelected = _selPriority == priority;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selColor = c;
          _selPriority = priority;
          if (priority == 'idea') _selType = 'idea';
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: c,
              child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _smallChoice(tr['task']!, 'task'),
        _smallChoice(tr['i']!, 'idea'),
        _smallChoice(tr['project']!, 'project'),
      ],
    );
  }

  Widget _smallChoice(String label, String value) {
    final selected = _selType == value;
    return GestureDetector(
      onTap: () => setState(() => _selType = value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.white24 : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }

  Widget _inputBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _titleController,
        decoration: InputDecoration(
          hintText: '${tr['p']} ${_formatDate(_selDate)}',
          prefixIcon: IconButton(
            icon: CircleAvatar(
              backgroundColor: _selColor,
              child: const Icon(Icons.add, color: Colors.black),
            ),
            onPressed: _addTask,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.repeat, color: Colors.white70),
                onSelected: (v) => setState(() => _selRepeat = v),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'none', child: Text(tr['none']!)),
                  PopupMenuItem(value: 'daily', child: Text(tr['daily']!)),
                  PopupMenuItem(value: 'weekly', child: Text(tr['weekly']!)),
                  PopupMenuItem(value: 'monthly', child: Text(tr['monthly']!)),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.access_time,
                  color: _selTime != null ? const Color(0xFFFFD700) : Colors.white70,
                ),
                onPressed: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t != null) setState(() => _selTime = t);
                },
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month, color: Colors.white70),
                onPressed: () async {
                  final p = await showDatePicker(
                    context: context,
                    initialDate: _selDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (p != null) setState(() => _selDate = p);
                },
              ),
            ],
          ),
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (_) => _addTask(),
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: tr['search'],
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _filterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _filterBtn(tr['all']!, 'all'),
          _filterBtn(tr['h']!, 'high'),
          _filterBtn(tr['m']!, 'normal'),
          _filterBtn(tr['i']!, 'idea'),
          _filterBtn(tr['project']!, 'project'),
          _filterBtn(tr['done']!, 'done'),
        ],
      ),
    );
  }

  Widget _filterBtn(String label, String value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFD700) : Colors.white10,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _taskCard(PlannerTask task, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border(
          left: BorderSide(color: Color(task.color), width: 4),
        ),
      ),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            task.completed ? Icons.check_circle : Icons.circle_outlined,
            color: task.completed ? const Color(0xFFFFD700) : Colors.white54,
          ),
          onPressed: () => _toggleDone(index),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontSize: 14,
            decoration: task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? Colors.white38 : Colors.white,
          ),
        ),
        subtitle: Text(
          '${_formatDate(task.date)}'
          '${task.time == null ? '' : '  ${task.time}'}'
          '  • ${task.type}'
          '${task.repeat == 'none' ? '' : '  • ${task.repeat}'}
          '${task.note.isEmpty ? '' : '\n${task.note}'}',
          style: const TextStyle(fontSize: 10, color: Colors.white38),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
              onPressed: () => _editTask(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 20),
              onPressed: () => _deleteTask(index),
            ),
          ],
        ),
      ),
    );
  }
}
