import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/round_view_model.dart';
import 'viewmodels/settings.dart';
import 'viewmodels/language.dart';
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
