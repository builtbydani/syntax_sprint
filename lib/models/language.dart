enum Language { python, rust, typescript }

String langLabel(Language l) => switch (l) {
  Language.python => 'Python',
  Language.rust => 'Rust',
  Language.typescript => 'TypeScript',
};
