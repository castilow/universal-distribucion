import 'package:flutter/material.dart';

import 'seen_by.dart';
import 'story_music.dart';

class StoryText {
  final String text;
  final Color bgColor;
  final StoryMusic? music; // Música opcional (máximo 30 segundos)
  List<SeenBy> seenBy;
  final DateTime createdAt;

  StoryText({
    required this.text,
    required this.bgColor,
    this.music,
    this.seenBy = const [],
    required this.createdAt,
  });

  factory StoryText.fromMap(Map<String, dynamic> data) {
    return StoryText(
      text: data['text'] as String,
      bgColor: Color(data['bgColor'] as int),
      music: data['music'] != null 
          ? StoryMusic.fromMap(data['music'] as Map<String, dynamic>)
          : null,
      seenBy: SeenBy.seenByFrom(data['seenBy']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'bgColor': bgColor.value,
      'music': music?.toMap(),
      'seenBy': seenBy.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static List<StoryText> textsFrom(List listOfMaps) {
    final texts = List<Map<String, dynamic>>.from(listOfMaps);
    return List<StoryText>.from(texts.map((item) => StoryText.fromMap(item)));
  }
}