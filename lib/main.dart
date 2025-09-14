import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/language.dart';
import 'viewmodels/round_view_model.dart';
import 'views/syntax_sprint_page.dart';

void main() => runApp(const SyntaxSprintApp());

class SyntaxSprintApp extends StatelessWidget {
  const SyntaxSprintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
        ChangeNotifierProvider(create: (_) => RoundViewModel()),
      ],
      child: MaterialApp(
        title: 'SyntaxSprint',
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const SyntaxSprintPage(),
      ),
    );
  }
}

class SettingsViewModel extends ChangeNotifier {
  bool strict = true;
  void toggleStrict() {
    strict = !strict;
    notifyListeners();
  }
}

class LanguageViewModel extends ChangeNotifier {
  Language selected = Language.python;
  void setLanguage(Language value) {
    selected = value;
    notifyListeners();
  }
}
