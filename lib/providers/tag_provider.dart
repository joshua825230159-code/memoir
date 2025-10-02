import 'package:flutter/material.dart';

class TagProvider extends ChangeNotifier {
  final Set<String> _allTags = {};

  Set<String> get allTags => _allTags;

  void addTag(String tag) {
    _allTags.add(tag);
    notifyListeners();
  }

  void removeTag(String tag) {
    _allTags.remove(tag);
    notifyListeners();
  }
}
