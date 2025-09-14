import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/concept.dart';
import 'models/language.dart';
import 'models/round_spec.dart';

void main() => runApp(const SyntaxSprintApp());

class SyntaxSprintApp extends StatelessWidget {
  const SyntaxSprintApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
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

class SyntaxSprintPage extends StatefulWidget {
  const SyntaxSprintPage({super.key});
  @override
  State<SyntaxSprintPage> createState() => _SyntaxSprintPageState();
}

class _SyntaxSprintPageState extends State<SyntaxSprintPage> {
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
  final controller = TextEditingController();
  int errorCount = 0;
  bool started = false;
  bool finished = false;
  final Stopwatch sw = Stopwatch();

  @override
  void dispose() {
    controller.dispose();
    sw.stop();
    super.dispose();
  }

  void _onTextChanged() {
    final next = controller.text;
    if (!started && next.isNotEmpty) {
      setState(() => started = true);
      sw
        ..reset()
        ..start();
    }

    final idx = next.length - 1;
    if (idx >= 0) {
      final got = _canonicalCharAt(next, idx);
      final exp = _canonicalCharAt(current.snippet, idx);
      if (got != exp) setState(() => errorCount++);
    }

    if (_normalize(next) == _normalize(current.snippet)) {
      sw.stop();
      setState(() => finished = true);
    }
    setState(() {});
  }

  void _resetRound({bool keepTask = true}) {
    controller.clear();
    sw.stop();
    setState(() {
      started = false;
      finished = false;
      errorCount = 0;
      showHint = false;
      if (!keepTask) current = _pickNext(current);
    });
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
    // Collapse consecutive spaces/tabs but keep newlines intact.
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

  int _countCorrectChars(String input, String target) {
    final a = _normalize(input);
    final b = _normalize(target);
    var count = 0;
    for (var i = 0; i < min(a.length, b.length); i++) {
      if (a[i] == b[i]) count++;
    }
    return count;
  }

  double get _progress =>
      (controller.text.length / current.snippet.length).clamp(0.0, 1.0);

  int get _wpm {
    if (!started) return 0;
    final correct = _countCorrectChars(controller.text, current.snippet);
    final minutes = max(sw.elapsedMilliseconds / 60000.0, 1e-6);
    return max(0, ((correct / 5) / minutes).round());
  }

  int get _accuracy {
    final typed = controller.text.length;
    if (typed == 0) return 100;
    final correct = _countCorrectChars(controller.text, current.snippet);
    return (100 * correct / typed).round();
  }

  // Insert text at current caret in controller
  void _insertAtCursor(String text) {
    final value = controller.value;
    final start = value.selection.start;
    final end = value.selection.end;
    if (start < 0 || end < 0) return;
    final next = value.text.replaceRange(start, end, text);
    controller.value = value.copyWith(
      text: next,
      selection: TextSelection.collapsed(offset: start + text.length),
      composing: TextRange.empty,
    );
    _onTextChanged();
  }

  @override
  Widget build(BuildContext context) {
    final codeTheme = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0B1220)
        : const Color(0xFFF7F8FB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SyntaxSprint'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.concept.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Language: ${langLabel(current.language)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 16,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Strict spacing',
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: strictSpacing,
                                onChanged: (v) =>
                                    setState(() => strictSpacing = v),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Show hint',
                                style: TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 8),
                              Switch(
                                value: showHint,
                                onChanged: (v) => setState(() => showHint = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (showHint)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          current.concept.hint,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

              // Target code
              Container(
                decoration: BoxDecoration(
                  color: codeTheme,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  current.snippet,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Input area with Tab handler on desktop/web
              RawKeyboardListener(
                autofocus: true,
                focusNode: FocusNode(),
                onKey: (event) {
                  if (event is RawKeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.tab) {
                    // Prevent focus change: insert 4 spaces
                    _insertAtCursor('    ');
                    // Consume event by not letting focus move
                  }
                },
                child: TextField(
                  controller: controller,
                  onChanged: (_) => _onTextChanged(),
                  maxLines: 8,
                  minLines: 8,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type the code above…',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                ),
              ),

              const SizedBox(height: 12),

              // Live diff
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live match',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: RichText(
                          text: TextSpan(
                            children: _renderDiff(
                              controller.text,
                              current.snippet,
                              context,
                              strictSpacing,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Progress + stats
              Column(
                children: [
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress: ${(100 * _progress).floor()}%'),
                      Wrap(
                        spacing: 16,
                        children: [
                          Text('WPM: $_wpm'),
                          Text('Accuracy: $_accuracy%'),
                          Text('Errors: $errorCount'),
                          Text(
                            'Time: ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(1)}s',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Controls
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      setState(() => current = _pickNext(current));
                      _resetRound();
                    },
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Next'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _resetRound(keepTask: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                  if (!started)
                    OutlinedButton.icon(
                      onPressed: () {
                        if (!started) {
                          sw
                            ..reset()
                            ..start();
                          setState(() => started = true);
                        }
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Modes & Languages
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modes & Languages',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('Mixed')),
                          ButtonSegment(value: false, label: Text('Fixed')),
                        ],
                        selected: {mixed},
                        onSelectionChanged: (s) =>
                            setState(() => mixed = s.first),
                      ),
                      const SizedBox(height: 12),
                      if (mixed)
                        Wrap(
                          spacing: 8,
                          children: Language.values.map((l) {
                            final on = enabled.contains(l);
                            return FilterChip(
                              selected: on,
                              label: Text(langLabel(l)),
                              onSelected: (v) {
                                if (!v && enabled.length == 1)
                                  return; // keep at least one
                                setState(() {
                                  v ? enabled.add(l) : enabled.remove(l);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      if (!mixed)
                        Wrap(
                          spacing: 8,
                          children: Language.values.map((l) {
                            final on = fixed == l;
                            return ChoiceChip(
                              selected: on,
                              label: Text(langLabel(l)),
                              onSelected: (_) => setState(() => fixed = l),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Add more concepts by editing SNIPPETS in concept.dart',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<TextSpan> _renderDiff(
  String input,
  String target,
  BuildContext ctx,
  bool strict,
) {
  String normalize(String s) {
    s = s.replaceAll('\r\n', '\n');
    if (strict) return s;
    final buf = StringBuffer();
    bool spaceMode = false;
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      if (ch == '\n') {
        buf.write('\n');
        spaceMode = false;
        continue;
      }
      if (ch == ' ' || ch == '\t') {
        if (!spaceMode) buf.write(' ');
        spaceMode = true;
      } else {
        buf.write(ch);
        spaceMode = false;
      }
    }
    return buf.toString();
  }

  final a = normalize(input);
  final b = normalize(target);
  final theme = Theme.of(ctx);
  final good = theme.brightness == Brightness.dark
      ? const Color(0xFF34D399)
      : const Color(0xFF047857);
  final badBg = theme.brightness == Brightness.dark
      ? const Color(0x993F1D2B)
      : const Color(0xFFFFE4E6);
  final badFg = theme.brightness == Brightness.dark
      ? const Color(0xFFFECACA)
      : const Color(0xFF9F1239);
  final remaining = theme.textTheme.bodyMedium!.color!.withOpacity(0.5);

  final out = <TextSpan>[];
  final maxLen = max(a.length, b.length);
  for (var i = 0; i < maxLen; i++) {
    final got = i < a.length ? a[i] : '';
    final exp = i < b.length ? b[i] : '';
    TextStyle style;
    if (i >= a.length) {
      style = TextStyle(
        color: remaining,
        fontFamily: 'monospace',
        fontSize: 13,
        height: 1.6,
      );
    } else if (got == exp) {
      style = TextStyle(
        color: good,
        fontFamily: 'monospace',
        fontSize: 13,
        height: 1.6,
      );
    } else {
      style = TextStyle(
        backgroundColor: badBg,
        color: badFg,
        fontFamily: 'monospace',
        fontSize: 13,
        height: 1.6,
      );
    }
    out.add(TextSpan(text: exp.isEmpty ? ' ' : exp, style: style));
  }
  return out;
}
