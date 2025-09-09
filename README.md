# SyntaxSprint 🏃‍♀️💻

A Flutter app to drill **language syntax** via short, type-to-match code snippets. Think *monkeytype* but for code structures — switch between **TypeScript**, **Rust**, and **Python** to train your context-switching muscles.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Platform](https://img.shields.io/badge/Platforms-Web%20%7C%20Desktop%20%7C%20Mobile-6f42c1)
![License](https://img.shields.io/badge/License-MIT-success)

---

## ✨ What it does (MVP)

- **Concept drills**: conditionals, loops, functions, map/transform, error handling, simple structs/classes.
- **Multi-language**: TypeScript, Rust, Python (more coming).
- **Typing view**: verbatim copy of the snippet with **live per-char diff**, **WPM**, **accuracy**, **errors**, and **progress**.
- **Modes**: **Mixed** (random language each round) or **Fixed**.
- **Strict spacing toggle**: be picky (exact whitespace) or forgiving (collapse spaces).
- **Tab support** on desktop/web inserts 4 spaces for indentation.

> 🎯 Goal: build **procedural memory** for syntax, not just recognition.

---

## 🚀 Getting started

```bash
flutter pub get
flutter run -d chrome     # Web
# or
flutter run -d linux      # Linux desktop
# or use your emulator/device
# If you change assets later (e.g., JSON snippets), update pubspec.yaml and run flutter pub get
```

## 🧩 Content model

Snippets are grouped by *concept* and defined *per language*.
Today they live in code; soon we’ll load from JSON (example format):

```json
[
  {
    "id": "for-array",
    "title": "For loop over an array/list",
    "hint": "Iterate sequentially over elements and print/log them.",
    "snippets": {
      "python": "arr = [1, 2, 3]\nfor value in arr:\n    print(value)",
      "typescript": "const arr = [1, 2, 3];\nfor (const value of arr) {\n  console.log(value);\n}",
      "rust": "let arr = [1, 2, 3];\nfor value in arr.iter() {\n    println!(\"{}\", value);\n}"
    }
  }
]
```

## 🏗️ Architecture

- **Current:** clean stateful MVP in a single screen.

- **Next:** MVVM with Riverpod

- - models/ → Concept, Language, RoundSpec

- - data/ → SnippetRepository (JSON-backed)

- - viewmodel/ → SyntaxSprintViewModel (StateNotifier) + SyntaxSprintState

- - ui/ → widgets for code preview, diff view, controls

- - utils/ → normalization & diff helpers

This keeps logic testable and the UI dumb and fast to iterate.

## 🗺️ Roadmap
- *Content*: common data structures (stack, queue, list, set, map), search and sort snippets
- *"Test" mode*: prompt -> you implement (with hidden target + tolerant matching)
- *Stats*: XP, streaks, PB WPM, accuracy by lang, local history
- *Syntax highlighting*: pretty target view
- *More languages*: Dart, SQL, Java (also, langs user defined via JSON, not hard-coded)
- *Fill-in-the-blank*: drills for pain points (Rust match, TS generics, Python slicing, etc.)
- *Leaderboards*

## 🧠 Why this exists
Context switching between languages is hard. This app builds muscle memory for common idioms so you stop thinking about punctuation and focus on solving problems. I mainly built it for myself, but hope others may find it useful too

## 📜 License

