import 'language.dart';

class Concept {
  final String id;
  final String title;
  final String hint;
  final Map<Language, String> snippets;
  const Concept({
    required this.id,
    required this.title,
    required this.hint,
    required this.snippets,
  });
}

const SNIPPETS = <Concept>[
  Concept(
    id: 'for-array',
    title: 'For loop over an array/list',
    hint: 'Iterate sequentially over elements and print/log them.',
    snippets: {
      Language.python: 'arr = [1, 2, 3]\nfor value in arr:\n    print(value)',
      Language.typescript:
          'const arr = [1, 2, 3];\nfor (const value of arr) {\n  console.log(value);\n}',
      Language.rust:
          'let arr = [1, 2, 3];\nfor value in arr.iter() {\n    println!("{}", value);\n}',
    },
  ),
  Concept(
    id: 'if-else',
    title: 'If / else conditional',
    hint: 'Check a number and branch.',
    snippets: {
      Language.python:
          'x = 7\nif x > 5:\n    print("big")\nelse:\n    print("small")',
      Language.typescript:
          'const x = 7;\nif (x > 5) {\n  console.log("big");\n} else {\n  console.log("small");\n}',
      Language.rust:
          'let x = 7;\nif x > 5 {\n    println!("big");\n} else {\n    println!("small");\n}',
    },
  ),
  Concept(
    id: 'function-def',
    title: 'Function definition + return',
    hint: 'Add two numbers and return the sum.',
    snippets: {
      Language.python: 'def add(a, b):\n    return a + b',
      Language.typescript:
          'function add(a: number, b: number): number {\n  return a + b;\n}',
      Language.rust: 'fn add(a: i32, b: i32) -> i32 {\n    a + b\n}',
    },
  ),
  Concept(
    id: 'map-transform',
    title: 'Map/transform over a collection',
    hint: 'Square each element.',
    snippets: {
      Language.python:
          'nums = [1, 2, 3]\nsquares = [n*n for n in nums]\nprint(squares)',
      Language.typescript:
          'const nums = [1, 2, 3];\nconst squares = nums.map(n => n * n);\nconsole.log(squares);',
      Language.rust:
          'let nums = vec![1, 2, 3];\nlet squares: Vec<i32> = nums.iter().map(|n| n * n).collect();\nprintln!("{:?}", squares);',
    },
  ),
  Concept(
    id: 'error-handling',
    title: 'Error handling',
    hint: 'Read a file; print error if it fails.',
    snippets: {
      Language.python:
          'try:\n    with open("data.txt", "r") as f:\n        text = f.read()\n    print(text)\nexcept Exception as e:\n    print(e)',
      Language.typescript:
          'try {\n  const text = await (await fetch("/data.txt")).text();\n  console.log(text);\n} catch (e) {\n  console.error(e);\n}',
      Language.rust:
          'use std::fs;\nfn main() {\n    match fs::read_to_string("data.txt") {\n        Ok(text) => println!("{}", text),\n        Err(e) => eprintln!("{}", e),\n    }\n}',
    },
  ),
  Concept(
    id: 'struct-class',
    title: 'Simple data type (class/struct)',
    hint: 'Define a point with x and y.',
    snippets: {
      Language.python:
          'class Point:\n    def __init__(self, x, y):\n        self.x = x\n        self.y = y',
      Language.typescript:
          'class Point {\n  constructor(public x: number, public y: number) {}\n}',
      Language.rust:
          'struct Point { x: f32, y: f32 }\nimpl Point {\n    fn new(x: f32, y: f32) -> Self { Self { x, y } }\n}',
    },
  ),
  Concept(
    id: 'while-loop',
    title: 'While loop',
    hint: 'Count down from 3 to 1.',
    snippets: {
      Language.python: 'n = 3\nwhile n > 0:\n    print(n)\n    n -= 1',
      Language.typescript:
          'let n = 3;\nwhile (n > 0) {\n  console.log(n);\n  n -= 1;\n}',
      Language.rust:
          'let mut n = 3;\nwhile n > 0 {\n    println!("{}", n);\n    n -= 1;\n}',
    },
  ),
];
