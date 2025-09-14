import 'package:flutter/material.dart';

class SettingsViewModel extends ChangeNotifier {
  bool strict = true;
  void toggleStrict() {
    strict = !strict;
    notifyListeners();
  }
}
