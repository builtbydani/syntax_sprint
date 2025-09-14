import 'dart:math';
import 'package:flutter/material.dart';

import '../models/concept.dart';
import '../models/language.dart';
import '../models/round_spec.dart';

class RoundViewModel extends ChangeNotifier {
  // Settings
  final Set<Language> enabled = {
    Language.python,
    Language.rust,
    Language.typescript,
  };
  bool mixed = true;
  Language fixed = Language.typescript;
  bool strictSpacing = true;
  bool showHint = false;

  // Round state
  late RoundSpec current = _pickNext(null);
  final TextEditingController controller = TextEditingController();
  int errorCount = 0;
  bool started = false;
  bool finished = false;
  final Stopwatch sw = Stopwatch();

  void onTextChanged() {
    final next = controller.text;
    if (!started && next.isNotEmpty) {
      started = true;
      sw
        ..reset()
        ..start();
    }

    final idx = next.length - 1;
    if (idx >= 0) {
      final got = _canonicalCharAt(next, idx);
      final exp = _canonicalCharAt(current.snippet, idx);
      if (got != exp) errorCount++;
    }

    if (_normalize(next) == _normalize(current.snippet)) {
      sw.stop();
      finished = true;
    }
    notifyListeners();
  }

  void resetRound({bool keepTask = true}) {
    controller.clear();
    sw.stop();
    started = false;
    finished = false;
    errorCount = 0;
    showHint = false;
    if (!keepTask) current = _pickNext(current);
    notifyListeners();
  }

  RoundSpec _pickNext(RoundSpec? prev) {
    final concept = SNIPPETS[Random().nextInt(SNIPPETS.length)];
    final langs = mixed ? enabled.toList() : [fixed];
    final lang = langs[Random().nextInt(langs.length)];
    return RoundSpec(
      concept: concept,
      language: lang,
      snippet: concept.snippets[lang]!,
    );
  }

  String _normalize(String text) {
    final unix = text.replaceAll('\r\n', '\n');
    if (strictSpacing) return unix;
    final sb = StringBuffer();
    bool spaceMode = false;
    for (final rune in unix.runes) {
      final ch = String.fromCharCode(rune);
      if (ch == '\n') {
        sb.write('\n');
        spaceMode = false;
        continue;
      }
      if (ch == ' ' || ch == '\t') {
        if (!spaceMode) sb.write(' ');
        spaceMode = true;
      } else {
        sb.write(ch);
        spaceMode = false;
      }
    }
    return sb.toString();
  }

  String _canonicalCharAt(String s, int idx) {
    final n = _normalize(s);
    return (idx >= 0 && idx < n.length) ? n[idx] : '';
  }

  @override
  void dispose() {
    controller.dispose();
    sw.stop();
    super.dispose();
  }
}
