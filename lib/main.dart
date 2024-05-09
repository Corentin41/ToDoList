import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/screens/home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:todolist/themes/theme_provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => ThemeProvider(),
    child: const MainApp(),
    )
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<StatefulWidget> createState() => _MainAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MainAppState? state = context.findAncestorStateOfType<_MainAppState>();
    state?.setLocale(newLocale);
  }
}

  class _MainAppState extends State<MainApp> {

    late String languagePref;

    Locale? _locale;

    setLocale(Locale locale) {
      setState(() {
        _locale = locale;
      });
    }

    @override
    void initState() {
        getLanguagePref().then((value) {
          setState(() {
            // Changer la langue de l'application en fonction de value
            switch(value){
              case "fr" :
                _locale = Locale("fr");
              case "en" :
                _locale = Locale("en");
              case "es" :
                _locale = Locale("es");
            }
          });
        });
    }

  // Fonction pour récupérer le SharedPref de la langue
    Future<String> getLanguagePref() async {
      final prefs = await SharedPreferences.getInstance();
      languagePref = prefs.getString('languagePref') ?? Platform.localeName;
      return languagePref;
    }

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ToDo App',
        theme: Provider.of<ThemeProvider>(context).themeData,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: _locale,
        supportedLocales: [
          Locale('fr'),
          Locale('en'),
          Locale('es')
        ],
        home: HomePage(),
      );
    }
  }
