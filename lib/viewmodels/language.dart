import 'package:flutter/material.dart';
import '../models/language.dart';

class LanguageViewModel extends ChangeNotifier {
  Language selected = Language.python;
  void setLanguage(Language value) {
    selected = value;
    notifyListeners();
  }
}
