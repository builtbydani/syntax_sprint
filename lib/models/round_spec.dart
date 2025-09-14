import 'concept.dart';
import 'language.dart';

class RoundSpec {
  final Concept concept;
  final Language language;
  final String snippet;
  const RoundSpec({
    required this.concept,
    required this.language,
    required this.snippet,
  });
}
