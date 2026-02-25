import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(GlobalTaskApp());
}

class GlobalTaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Task Planner',
      // لیست زبان‌های پشتیبانی شده
      supportedLocales: [
        Locale('en', ''), // انگلیسی
        Locale('ar', ''), // عربی
        Locale('fa', ''), // فارسی
      ],
      // تنظیمات مربوط به راست‌چین و چپ‌چین شدن خودکار
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // تشخیص زبان گوشی کاربر
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first; // اگر زبان گوشی در لیست نبود، انگلیسی باز شود
      },
      home: Scaffold(
        appBar: AppBar(title: Text('Global Task Planner')),
        body: Center(child: Text('Welcome / خوش آمدید / مرحباً')),
      ),
    );
  }
}
