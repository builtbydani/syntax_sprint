import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/language.dart';
import '../viewmodels/round_view_model.dart';

class SyntaxSprintPage extends StatefulWidget {
  const SyntaxSprintPage({super.key});

  @override
  State<SyntaxSprintPage> createState() => _SyntaxSprintPageState();
}

class _SyntaxSprintPageState extends State<SyntaxSprintPage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RoundViewModel>();
    final codeTheme = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0B1220)
        : const Color(0xFFF7F8FB);

    final progress = (vm.controller.text.length / vm.current.snippet.length)
        .clamp(0.0, 1.0);
    final correct = _countCorrectChars(
      vm.controller.text,
      vm.current.snippet,
      vm.strictSpacing,
    );
    final minutes = max(vm.sw.elapsedMilliseconds / 60000.0, 1e-6);
    final wpm = vm.started ? max(0, ((correct / 5) / minutes).round()) : 0;
    final accuracy = vm.controller.text.isEmpty
        ? 100
        : (100 * correct / vm.controller.text.length).round();

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
                            vm.current.concept.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Language: ${langLabel(vm.current.language)}',
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
                                value: vm.strictSpacing,
                                onChanged: (v) {
                                  final r = context.read<RoundViewModel>();
                                  r.strictSpacing = v;
                                  r.notifyListeners();
                                },
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
                                value: vm.showHint,
                                onChanged: (v) {
                                  final r = context.read<RoundViewModel>();
                                  r.showHint = v;
                                  r.notifyListeners();
                                },
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

              if (vm.showHint)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 16),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          vm.current.concept.hint,
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
                  vm.current.snippet,
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
                focusNode: _focusNode,
                onKey: (event) {
                  if (event is RawKeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.tab) {
                    _insertAtCursor(context, '    ');
                  }
                },
                child: TextField(
                  controller: vm.controller,
                  onChanged: (_) =>
                      context.read<RoundViewModel>().onTextChanged(),
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
                              vm.controller.text,
                              vm.current.snippet,
                              context,
                              vm.strictSpacing,
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
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress: ${(100 * progress).floor()}%'),
                      Wrap(
                        spacing: 16,
                        children: [
                          Text('WPM: $wpm'),
                          Text('Accuracy: $accuracy%'),
                          Text('Errors: ${vm.errorCount}'),
                          Text(
                            'Time: ${(vm.sw.elapsedMilliseconds / 1000).toStringAsFixed(1)}s',
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
                    onPressed: () => context.read<RoundViewModel>().resetRound(
                      keepTask: false,
                    ),
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Next'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<RoundViewModel>().resetRound(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                  if (!vm.started)
                    OutlinedButton.icon(
                      onPressed: () {
                        final r = context.read<RoundViewModel>();
                        if (!r.started) {
                          r.sw
                            ..reset()
                            ..start();
                          r.started = true;
                          r.notifyListeners();
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
                        selected: {vm.mixed},
                        onSelectionChanged: (s) {
                          final r = context.read<RoundViewModel>();
                          r.mixed = s.first;
                          r.notifyListeners();
                        },
                      ),
                      const SizedBox(height: 12),
                      if (vm.mixed)
                        Wrap(
                          spacing: 8,
                          children: Language.values.map((l) {
                            final on = vm.enabled.contains(l);
                            return FilterChip(
                              selected: on,
                              label: Text(langLabel(l)),
                              onSelected: (v) {
                                if (!v && vm.enabled.length == 1) {
                                  return; // keep at least one
                                }
                                final r = context.read<RoundViewModel>();
                                if (v) {
                                  r.enabled.add(l);
                                } else {
                                  r.enabled.remove(l);
                                }
                                r.notifyListeners();
                              },
                            );
                          }).toList(),
                        ),
                      if (!vm.mixed)
                        Wrap(
                          spacing: 8,
                          children: Language.values.map((l) {
                            final on = vm.fixed == l;
                            return ChoiceChip(
                              selected: on,
                              label: Text(langLabel(l)),
                              onSelected: (_) {
                                final r = context.read<RoundViewModel>();
                                r.fixed = l;
                                r.notifyListeners();
                              },
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

String _normalize(String text, bool strictSpacing) {
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

int _countCorrectChars(String input, String target, bool strictSpacing) {
  final a = _normalize(input, strictSpacing);
  final b = _normalize(target, strictSpacing);
  var count = 0;
  for (var i = 0; i < min(a.length, b.length); i++) {
    if (a[i] == b[i]) count++;
  }
  return count;
}

void _insertAtCursor(BuildContext context, String text) {
  final vm = context.read<RoundViewModel>();
  final controller = vm.controller;
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
  vm.onTextChanged();
}

List<TextSpan> _renderDiff(
  String input,
  String target,
  BuildContext ctx,
  bool strict,
) {
  final a = _normalize(input, strict);
  final b = _normalize(target, strict);
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
