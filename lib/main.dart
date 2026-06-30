import 'premium_screen.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
final FlutterLocalNotificationsPlugin notifications =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tz.initializeTimeZones();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings = InitializationSettings(
    android: androidSettings,
  );

  await notifications.initialize(initSettings);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  runApp(const GlobalPlannerApp());
}

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
      title: 'Global Task Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, primaryColor: const Color(0xFFFFD700)),
      home: Directionality(
        textDirection: ['ar', 'fa'].contains(_currentLang) ? TextDirection.rtl : TextDirection.ltr,
        child: PlannerScreen(lang: _currentLang, onLangChange: _changeLanguage),
      ),
    );
  }
}

class PlannerTask {
  String id, title, note, type, priority, repeat;
  int color;
  DateTime date;
  String? time;
  bool completed, reminded;

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

  factory PlannerTask.fromJson(Map<String, dynamic> j) => PlannerTask(
        id: j['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: j['title'] ?? '',
        note: j['note'] ?? '',
        type: j['type'] ?? 'task',
        priority: j['priority'] ?? 'normal',
        color: j['color'] ?? 0xFFFFD700,
        date: DateTime.tryParse(j['date'] ?? '') ?? DateTime.now(),
        time: j['time'],
        completed: j['completed'] ?? false,
        repeat: j['repeat'] ?? 'none',
        reminded: j['reminded'] ?? false,
      );
}

class PlannerScreen extends StatefulWidget {
  final String lang;
  final Function(String) onLangChange;
  const PlannerScreen({super.key, required this.lang, required this.onLangChange});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final _title = TextEditingController();
  final _search = TextEditingController();

  List<PlannerTask> _tasks = [];
  Color _selColor = const Color(0xFFFFD700);
  String _selPriority = 'high';
  String _selType = 'task';
  String _selRepeat = 'none';
  String _filter = 'all';
  DateTime _selDate = DateTime.now();
  TimeOfDay? _selTime;
  Timer? _timer;

  final Map<String, Map<String, String>> _langData = {
    'en': {'n':'English','l':'Language','app':'Global Task Planner','p':'Plan for','h':'High','m':'Normal','i':'Idea','task':'Task','project':'Project','all':'All','done':'Done','search':'Search','repeat':'Repeat','none':'None','daily':'Daily','weekly':'Weekly','monthly':'Monthly','save':'Save','edit':'Edit','cancel':'Cancel','note':'Note','total':'Total','completed':'Completed','pending':'Pending','empty':'No tasks yet','today':'Today','tomorrow':'Tomorrow','week':'This Week','overdue':'Overdue','settings':'Settings','export':'Export Backup','import':'Import Backup','clear':'Clear Data','copy':'Backup copied','paste':'Paste backup text','ok':'OK'},
    'pt': {'n':'Português','l':'Idioma','app':'Global Task Planner','p':'Plano para','h':'Alto','m':'Normal','i':'Ideia','task':'Tarefa','project':'Projeto','all':'Todos','done':'Feito','search':'Pesquisar','repeat':'Repetir','none':'Nenhum','daily':'Diário','weekly':'Semanal','monthly':'Mensal','save':'Salvar','edit':'Editar','cancel':'Cancelar','note':'Nota','total':'Total','completed':'Concluído','pending':'Pendente','empty':'Sem tarefas','today':'Hoje','tomorrow':'Amanhã','week':'Esta semana','overdue':'Atrasado','settings':'Configurações','export':'Exportar backup','import':'Importar backup','clear':'Limpar dados','copy':'Backup copiado','paste':'Cole o backup','ok':'OK'},
    'fr': {'n':'Français','l':'Langue','app':'Global Task Planner','p':'Plan pour','h':'Haut','m':'Normal','i':'Idée','task':'Tâche','project':'Projet','all':'Tous','done':'Terminé','search':'Rechercher','repeat':'Répéter','none':'Aucun','daily':'Quotidien','weekly':'Hebdomadaire','monthly':'Mensuel','save':'Enregistrer','edit':'Modifier','cancel':'Annuler','note':'Note','total':'Total','completed':'Terminé','pending':'En attente','empty':'Aucune tâche','today':'Aujourd’hui','tomorrow':'Demain','week':'Cette semaine','overdue':'En retard','settings':'Paramètres','export':'Exporter backup','import':'Importer backup','clear':'Effacer données','copy':'Backup copié','paste':'Collez le backup','ok':'OK'},
    'de': {'n':'Deutsch','l':'Sprache','app':'Global Task Planner','p':'Plan für','h':'Hoch','m':'Normal','i':'Idee','task':'Aufgabe','project':'Projekt','all':'Alle','done':'Erledigt','search':'Suchen','repeat':'Wiederholen','none':'Keine','daily':'Täglich','weekly':'Wöchentlich','monthly':'Monatlich','save':'Speichern','edit':'Bearbeiten','cancel':'Abbrechen','note':'Notiz','total':'Gesamt','completed':'Erledigt','pending':'Offen','empty':'Keine Aufgaben','today':'Heute','tomorrow':'Morgen','week':'Diese Woche','overdue':'Überfällig','settings':'Einstellungen','export':'Backup exportieren','import':'Backup importieren','clear':'Daten löschen','copy':'Backup kopiert','paste':'Backup einfügen','ok':'OK'},
    'ru': {'n':'Русский','l':'Язык','app':'Global Task Planner','p':'План на','h':'Высокий','m':'Обычный','i':'Идея','task':'Задача','project':'Проект','all':'Все','done':'Готово','search':'Поиск','repeat':'Повтор','none':'Нет','daily':'Ежедневно','weekly':'Еженедельно','monthly':'Ежемесячно','save':'Сохранить','edit':'Изменить','cancel':'Отмена','note':'Заметка','total':'Всего','completed':'Выполнено','pending':'Осталось','empty':'Нет задач','today':'Сегодня','tomorrow':'Завтра','week':'Эта неделя','overdue':'Просрочено','settings':'Настройки','export':'Экспорт','import':'Импорт','clear':'Очистить','copy':'Скопировано','paste':'Вставьте backup','ok':'OK'},
    'zh': {'n':'中文','l':'语言','app':'Global Task Planner','p':'计划于','h':'高','m':'普通','i':'想法','task':'任务','project':'项目','all':'全部','done':'完成','search':'搜索','repeat':'重复','none':'无','daily':'每天','weekly':'每周','monthly':'每月','save':'保存','edit':'编辑','cancel':'取消','note':'备注','total':'总计','completed':'已完成','pending':'待办','empty':'暂无任务','today':'今天','tomorrow':'明天','week':'本周','overdue':'逾期','settings':'设置','export':'导出备份','import':'导入备份','clear':'清除数据','copy':'备份已复制','paste':'粘贴备份','ok':'确定'},
    'it': {'n':'Italiano','l':'Lingua','app':'Global Task Planner','p':'Piano per','h':'Alto','m':'Normale','i':'Idea','task':'Attività','project':'Progetto','all':'Tutti','done':'Fatto','search':'Cerca','repeat':'Ripeti','none':'Nessuno','daily':'Giornaliero','weekly':'Settimanale','monthly':'Mensile','save':'Salva','edit':'Modifica','cancel':'Annulla','note':'Nota','total':'Totale','completed':'Completati','pending':'In sospeso','empty':'Nessuna attività','today':'Oggi','tomorrow':'Domani','week':'Questa settimana','overdue':'Scaduti','settings':'Impostazioni','export':'Esporta backup','import':'Importa backup','clear':'Cancella dati','copy':'Backup copiato','paste':'Incolla backup','ok':'OK'},
    'ar': {'n':'العربية','l':'اللغة','app':'Global Task Planner','p':'خطة لـ','h':'عالي','m':'عادي','i':'فكرة','task':'مهمة','project':'مشروع','all':'الكل','done':'تم','search':'بحث','repeat':'تكرار','none':'بدون','daily':'يومي','weekly':'أسبوعي','monthly':'شهري','save':'حفظ','edit':'تعديل','cancel':'إلغاء','note':'ملاحظة','total':'المجموع','completed':'مكتمل','pending':'متبقي','empty':'لا توجد مهام','today':'اليوم','tomorrow':'غداً','week':'هذا الأسبوع','overdue':'متأخر','settings':'الإعدادات','export':'تصدير نسخة','import':'استيراد نسخة','clear':'مسح البيانات','copy':'تم نسخ النسخة','paste':'الصق النسخة','ok':'موافق'},
    'fa': {'n':'فارسی','l':'زبان','app':'Global Task Planner','p':'برنامه برای','h':'فوری','m':'معمولی','i':'ایده','task':'کار','project':'پروژه','all':'همه','done':'انجام‌شده','search':'جستجو','repeat':'تکرار','none':'ندارد','daily':'روزانه','weekly':'هفتگی','monthly':'ماهانه','save':'ذخیره','edit':'ویرایش','cancel':'لغو','note':'یادداشت','total':'کل','completed':'انجام‌شده','pending':'مانده','empty':'هنوز کاری ثبت نشده','today':'امروز','tomorrow':'فردا','week':'این هفته','overdue':'عقب‌افتاده','settings':'تنظیمات','export':'خروجی بکاپ','import':'ورود بکاپ','clear':'پاک کردن داده‌ها','copy':'بکاپ کپی شد','paste':'متن بکاپ را وارد کن','ok':'تأیید'},
    'hi': {'n':'हिन्दी','l':'भाषा','app':'Global Task Planner','p':'योजना के लिए','h':'उच्च','m':'सामान्य','i':'विचार','task':'कार्य','project':'प्रोजेक्ट','all':'सभी','done':'पूर्ण','search':'खोज','repeat':'दोहराएँ','none':'नहीं','daily':'दैनिक','weekly':'साप्ताहिक','monthly':'मासिक','save':'सहेजें','edit':'संपादित करें','cancel':'रद्द करें','note':'नोट','total':'कुल','completed':'पूर्ण','pending':'बाकी','empty':'अभी कोई कार्य नहीं','today':'आज','tomorrow':'कल','week':'इस सप्ताह','overdue':'विलंबित','settings':'सेटिंग्स','export':'बैकअप निर्यात','import':'बैकअप आयात','clear':'डेटा साफ़ करें','copy':'बैकअप कॉपी हुआ','paste':'बैकअप टेक्स्ट डालें','ok':'ठीक'},

'bn': {'n':'বাংলা','l':'ভাষা','app':'Global Task Planner','p':'পরিকল্পনা','h':'উচ্চ','m':'স্বাভাবিক','i':'ধারণা','task':'কাজ','project':'প্রকল্প','all':'সব','done':'সম্পন্ন','search':'অনুসন্ধান','repeat':'পুনরাবৃত্তি','none':'নেই','daily':'দৈনিক','weekly':'সাপ্তাহিক','monthly':'মাসিক','save':'সংরক্ষণ','edit':'সম্পাদনা','cancel':'বাতিল','note':'নোট','total':'মোট','completed':'সম্পন্ন','pending':'বাকি','empty':'এখনো কোনো কাজ নেই','today':'আজ','tomorrow':'আগামীকাল','week':'এই সপ্তাহ','overdue':'বিলম্বিত','settings':'সেটিংস','export':'ব্যাকআপ রপ্তানি','import':'ব্যাকআপ আমদানি','clear':'ডেটা মুছুন','copy':'ব্যাকআপ কপি হয়েছে','paste':'ব্যাকআপ টেক্সট দিন','ok':'ঠিক আছে'},
  };

  Map<String, String> get tr => _langData[widget.lang] ?? _langData['en']!;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkAlarms());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _title.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final data = p.getStringList('tasks_v50') ?? p.getStringList('tasks_v40') ?? [];
    setState(() => _tasks = data.map((e) => PlannerTask.fromJson(jsonDecode(e))).toList());
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('tasks_v50', _tasks.map((e) => jsonEncode(e.toJson())).toList());
  }

  String _date(DateTime d) {
    if (widget.lang == 'fa') return _toSolar(d);
    const months = {
      'en':['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
      'pt':['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'],
      'fr':['Jan','Fév','Mar','Avr','Mai','Juin','Juil','Août','Sep','Oct','Nov','Déc'],
      'de':['Jan','Feb','Mär','Apr','Mai','Jun','Jul','Aug','Sep','Okt','Nov','Dez'],
      'ru':['Янв','Фев','Мар','Апр','Май','Июн','Июл','Авг','Сен','Окт','Ноя','Дек'],
      'zh':['1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月'],
      'it':['Gen','Feb','Mar','Apr','Mag','Giu','Lug','Ago','Set','Ott','Nov','Dic'],
      'ar':['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'],
      'hi':['जन','फ़र','मार्च','अप्रैल','मई','जून','जुलाई','अग','सित','अक्टू','नवं','दिसं'],
'bn':['জানু','ফেব','মার্চ','এপ্রি','মে','জুন','জুল','আগ','সেপ্ট','অক্টো','নভে','ডিসে'],
    };
    final m = months[widget.lang] ?? months['en']!;
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  String _toSolar(DateTime d) {
    int gY=d.year,gM=d.month,gD=d.day;
    var gdm=[0,31,59,90,120,151,181,212,243,273,304,334];
    int gy2=(gM>2)?gY+1:gY;
    int days=355666+(365*gY)+((gy2+3)~/4)-((gy2+99)~/100)+((gy2+399)~/400)+gD+gdm[gM-1];
    int jy=-1595+33*(days~/12053); days%=12053; jy+=4*(days~/1461); days%=1461;
    if(days>365){jy+=(days-1)~/365; days=(days-1)%365;}
    int jm=(days<186)?1+(days~/31):7+((days-186)~/30);
    int jd=1+((days<186)?days%31:(days-186)%30);
    return '$jy/$jm/$jd';
  }
    Future<void> _scheduleNotification(PlannerTask task) async {
  if (task.time == null) return;

  final parts = task.time!.split(':');
  final date = DateTime(
    task.date.year,
    task.date.month,
    task.date.day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );

  await notifications.show(
    task.id.hashCode,
    'Reminder',
    task.title,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'planner_channel',
        'Planner Reminders',
        channelDescription: 'Task reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
    }

  void _add() {
    final text = _title.text.trim();
    if (text.isEmpty) return;
    final time = _selTime == null ? null : '${_selTime!.hour.toString().padLeft(2,'0')}:${_selTime!.minute.toString().padLeft(2,'0')}';
    setState(() {
      _tasks.insert(0, PlannerTask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: text,
        note: '',
        type: _selType,
        priority: _selPriority,
        color: _selColor.value,
        date: _selDate,
        time: time,
        completed: false,
        repeat: _selRepeat,
        reminded: false,
      ));
      _title.clear();
      _selTime = null;
      _selRepeat = 'none';
    });
    _save();
  }

  void _toggle(int i) {
    final t = _tasks[i];
    setState(() {
      t.completed = !t.completed;
      if (t.completed && t.repeat != 'none') {
        DateTime next = t.repeat == 'daily'
            ? t.date.add(const Duration(days: 1))
            : t.repeat == 'weekly'
                ? t.date.add(const Duration(days: 7))
                : DateTime(t.date.year, t.date.month + 1, t.date.day);
        _tasks.insert(0, PlannerTask(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: t.title,
          note: t.note,
          type: t.type,
          priority: t.priority,
          color: t.color,
          date: next,
          time: t.time,
          completed: false,
          repeat: t.repeat,
          reminded: false,
        ));
      }
    });
    _save();
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  List<PlannerTask> get _visible {
    final q = _search.text.toLowerCase().trim();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final weekEnd = DateTime(now.year, now.month, now.day + 7);

    return _tasks.where((t) {
      final s = q.isEmpty || t.title.toLowerCase().contains(q) || t.note.toLowerCase().contains(q);
      final f = _filter == 'all' ||
          (_filter == 'done' && t.completed) ||
          (_filter == 'high' && t.priority == 'high') ||
          (_filter == 'normal' && t.priority == 'normal') ||
          (_filter == 'idea' && t.type == 'idea') ||
          (_filter == 'project' && t.type == 'project') ||
          (_filter == 'today' && _sameDay(t.date, now)) ||
          (_filter == 'tomorrow' && _sameDay(t.date, tomorrow)) ||
          (_filter == 'week' && !t.date.isBefore(DateTime(now.year, now.month, now.day)) && t.date.isBefore(weekEnd)) ||
          (_filter == 'overdue' && !t.completed && t.date.isBefore(DateTime(now.year, now.month, now.day)));
      return s && f;
    }).toList();
  }

  Future<void> _checkAlarms() async {
    final now = DateTime.now();
    final nowTime = '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';
    for (final t in _tasks) {
      if (!t.completed && !t.reminded && _sameDay(t.date, now) && t.time == nowTime) {
        t.reminded = true;
        _save();
          await notifications.show(
  0,
  'Reminder',
  t.title,
  const NotificationDetails(
    android: AndroidNotificationDetails(
      'planner_channel',
      'Planner Reminders',
      channelDescription: 'Task reminders',
      importance: Importance.max,
      priority: Priority.high,
    ),
  ),
);
        HapticFeedback.vibrate();
        showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Icon(Icons.alarm, color: Color(0xFFFFD700), size: 50),
          content: Text(t.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20)),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(tr['ok']!))],
        ));
        break;
      }
    }
  }

  void _edit(int i) {
    final t = _tasks[i];
    final title = TextEditingController(text: t.title);
    final note = TextEditingController(text: t.note);
    String type = t.type, repeat = t.repeat;
    DateTime date = t.date;
    String? time = t.time;

    showDialog(context: context, builder: (_) => StatefulBuilder(builder: (context, setD) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(tr['edit']!),
      content: SingleChildScrollView(child: Column(children: [
        TextField(controller: title, decoration: InputDecoration(labelText: tr['task'])),
        TextField(controller: note, decoration: InputDecoration(labelText: tr['note'])),
        DropdownButton<String>(value: type, isExpanded: true, items: [
          DropdownMenuItem(value:'task', child: Text(tr['task']!)),
          DropdownMenuItem(value:'idea', child: Text(tr['i']!)),
          DropdownMenuItem(value:'project', child: Text(tr['project']!)),
        ], onChanged: (v) => setD(() => type = v ?? 'task')),
        DropdownButton<String>(value: repeat, isExpanded: true, items: [
          DropdownMenuItem(value:'none', child: Text(tr['none']!)),
          DropdownMenuItem(value:'daily', child: Text(tr['daily']!)),
          DropdownMenuItem(value:'weekly', child: Text(tr['weekly']!)),
          DropdownMenuItem(value:'monthly', child: Text(tr['monthly']!)),
        ], onChanged: (v) => setD(() => repeat = v ?? 'none')),
        Row(children: [
          Expanded(child: Text(_date(date))),
          IconButton(icon: const Icon(Icons.calendar_month), onPressed: () async {
            final p = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2035));
            if (p != null) setD(() => date = p);
          }),
          IconButton(icon: const Icon(Icons.access_time), onPressed: () async {
            final p = await showTimePicker(context: context, initialTime: TimeOfDay.now());
            if (p != null) setD(() => time = '${p.hour.toString().padLeft(2,'0')}:${p.minute.toString().padLeft(2,'0')}');
          }),
        ]),
        if (time != null) Text(time!),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(tr['cancel']!)),
        TextButton(onPressed: () {
          setState(() {
            t.title = title.text.trim();
            t.note = note.text.trim();
            t.type = type;
            t.repeat = repeat;
            t.date = date;
            t.time = time;
            t.reminded = false;
          });
          _save();
          Navigator.pop(context);
        }, child: Text(tr['save']!)),
      ],
    )));
  }

  void _settings() {
    final backup = jsonEncode(_tasks.map((e) => e.toJson()).toList());
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(tr['settings'] ?? 'Settings'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
  title: const Text('Premium', style: TextStyle(color: Color(0xFFFFD700))),
  leading: const Icon(Icons.workspace_premium, color: Color(0xFFFFD700)),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PremiumScreen(lang: widget.lang),
    ));
  },
),
        ListTile(title: Text(tr['export']!), leading: const Icon(Icons.copy), onTap: () {
          Clipboard.setData(ClipboardData(text: backup));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr['copy']!)));
          Navigator.pop(context);
        }),
        ListTile(title: Text(tr['import']!), leading: const Icon(Icons.paste), onTap: () {
          Navigator.pop(context);
          showDialog(context: context, builder: (_) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(tr['import']!),
            content: TextField(controller: ctrl, maxLines: 5, decoration: InputDecoration(hintText: tr['paste'])),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(tr['cancel']!)),
              TextButton(onPressed: () {
                try {
                  final list = jsonDecode(ctrl.text) as List;
                  setState(() => _tasks = list.map((e) => PlannerTask.fromJson(e)).toList());
                  _save();
                  Navigator.pop(context);
                } catch (_) {}
              }, child: Text(tr['save']!)),
            ],
          ));
        }),
        ListTile(title: Text(tr['clear']!), leading: const Icon(Icons.delete_forever, color: Colors.redAccent), onTap: () {
          setState(() => _tasks.clear());
          _save();
          Navigator.pop(context);
        }),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final total = _tasks.length;
    final done = _tasks.where((e) => e.completed).length;
    final progress = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 105,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Column(children: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Color(0xFFFFD700)),
            onSelected: widget.onLangChange,
            itemBuilder: (_) => _langData.entries.map((e) => PopupMenuItem(value: e.key, child: Text(e.value['n']!))).toList(),
          ),
          Text(tr['l']!, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10)),
        ]),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tr['app']!, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18)),
          Text(_date(_selDate), style: const TextStyle(fontSize: 11, color: Colors.white54)),
        ]),
        actions: [IconButton(onPressed: _settings, icon: const Icon(Icons.settings, color: Color(0xFFFFD700)))],
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(18)),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _stat(tr['total']!, '$total'),
              _stat(tr['completed']!, '$done'),
              _stat(tr['pending']!, '${total - done}'),
            ]),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.white12, color: const Color(0xFFFFD700), minHeight: 6),
          ]),
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _prio(const Color(0xFFFFD700), tr['h']!, 'high'),
          _prio(const Color(0xFF448AFF), tr['m']!, 'normal'),
          _prio(const Color(0xFF9E9E9E), tr['i']!, 'idea'),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _choice(tr['task']!, 'task'), _choice(tr['i']!, 'idea'), _choice(tr['project']!, 'project'),
        ]),
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: TextField(
          controller: _title,
          onSubmitted: (_) => _add(),
          decoration: InputDecoration(
            hintText: '${tr['p']} ${_date(_selDate)}',
            prefixIcon: IconButton(icon: CircleAvatar(backgroundColor: _selColor, child: const Icon(Icons.add, color: Colors.black)), onPressed: _add),
            suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
              PopupMenuButton<String>(icon: const Icon(Icons.repeat, color: Colors.white70), onSelected: (v) => setState(() => _selRepeat = v), itemBuilder: (_) => [
                PopupMenuItem(value:'none', child: Text(tr['none']!)),
                PopupMenuItem(value:'daily', child: Text(tr['daily']!)),
                PopupMenuItem(value:'weekly', child: Text(tr['weekly']!)),
                PopupMenuItem(value:'monthly', child: Text(tr['monthly']!)),
              ]),
              IconButton(icon: Icon(Icons.access_time, color: _selTime != null ? const Color(0xFFFFD700) : Colors.white70), onPressed: () async {
                final p = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (p != null) setState(() => _selTime = p);
              }),
              IconButton(icon: const Icon(Icons.calendar_month, color: Colors.white70), onPressed: () async {
                final p = await showDatePicker(context: context, initialDate: _selDate, firstDate: DateTime(2020), lastDate: DateTime(2035));
                if (p != null) setState(() => _selDate = p);
              }),
            ]),
            filled: true, fillColor: Colors.white12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          ),
        )),
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: tr['search'],
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            filled: true, fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        )),
    
        const SizedBox(height: 8),

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Wrap(
    spacing: 8,
    runSpacing: 8,
    alignment: WrapAlignment.center,
    children: [
      _filterBtn(tr['all']!, 'all'),
      _filterBtn(tr['today']!, 'today'),
      _filterBtn(tr['tomorrow']!, 'tomorrow'),
      _filterBtn(tr['week']!, 'week'),
      _filterBtn(tr['overdue']!, 'overdue'),
      _filterBtn(tr['h']!, 'high'),
      _filterBtn(tr['m']!, 'normal'),
      _filterBtn(tr['i']!, 'idea'),
      _filterBtn(tr['project']!, 'project'),
      _filterBtn(tr['done']!, 'done'),
    ],
  ),
),

const SizedBox(height: 8),
        Expanded(child: visible.isEmpty ? Center(child: Text(tr['empty']!, style: const TextStyle(color: Colors.white38))) : ListView.builder(
          itemCount: visible.length,
          itemBuilder: (_, idx) {
            final task = visible[idx];
            final i = _tasks.indexWhere((e) => e.id == task.id);
            return _card(task, i);
          },
        )),
      ]),
    );
  }

  Widget _stat(String a, String b) => Column(children: [Text(b, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18)), Text(a, style: const TextStyle(color: Colors.white54, fontSize: 10))]);

  Widget _prio(Color c, String label, String p) {
    final s = _selPriority == p;
    return GestureDetector(onTap: () => setState(() { _selColor = c; _selPriority = p; if (p == 'idea') _selType = 'idea'; }), child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(children: [CircleAvatar(radius: 22, backgroundColor: c, child: s ? const Icon(Icons.check, color: Colors.white) : null), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, color: s ? Colors.white : Colors.white54))]),
    ));
  }

  Widget _choice(String label, String v) {
    final s = _selType == v;
    return GestureDetector(onTap: () => setState(() => _selType = v), child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(color: s ? Colors.white24 : Colors.white10, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    ));
  }

  Widget _filterBtn(String label, String v) {
    final s = _filter == v;
    return GestureDetector(onTap: () => setState(() => _filter = v), child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: s ? const Color(0xFFFFD700) : Colors.white10, borderRadius: BorderRadius.circular(18)),
      child: Text(label, style: TextStyle(color: s ? Colors.black : Colors.white70, fontSize: 11)),
    ));
  }

  Widget _card(PlannerTask t, int i) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border(left: BorderSide(color: Color(t.color), width: 4))),
    child: ListTile(
      leading: IconButton(icon: Icon(t.completed ? Icons.check_circle : Icons.circle_outlined, color: t.completed ? const Color(0xFFFFD700) : Colors.white54), onPressed: () => _toggle(i)),
      title: Text(t.title, style: TextStyle(fontSize: 14, decoration: t.completed ? TextDecoration.lineThrough : null, color: t.completed ? Colors.white38 : Colors.white)),
      subtitle: Text('${_date(t.date)}${t.time == null ? '' : '  ${t.time}'}  • ${tr[t.type] ?? t.type}${t.repeat == 'none' ? '' : '  • ${tr[t.repeat] ?? t.repeat}'}${t.note.isEmpty ? '' : '\n${t.note}'}', style: const TextStyle(fontSize: 10, color: Colors.white38)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(icon: const Icon(Icons.edit, color: Colors.white54, size: 20), onPressed: () => _edit(i)),
        IconButton(icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 20), onPressed: () { setState(() => _tasks.removeAt(i)); _save(); }),
      ]),
    ),
  );
}
