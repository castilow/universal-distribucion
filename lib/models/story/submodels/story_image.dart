import 'seen_by.dart';
import 'story_music.dart';

class StoryImage {
  final String imageUrl;
  final StoryMusic? music; // Música opcional
  List<SeenBy> seenBy;
  final DateTime createdAt;

  StoryImage({
    required this.imageUrl,
    this.music,
    this.seenBy = const [],
    required this.createdAt,
  });

  factory StoryImage.fromMap(Map<String, dynamic> data) {
    return StoryImage(
      imageUrl: data['imageUrl'] as String,
      music: data['music'] != null 
          ? StoryMusic.fromMap(data['music'] as Map<String, dynamic>)
          : null,
      seenBy: SeenBy.seenByFrom(data['seenBy']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'music': music?.toMap(),
      'seenBy': seenBy.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static List<StoryImage> imagesFrom(List listOfMaps) {
    final images = List<Map<String, dynamic>>.from(listOfMaps);
    return List<StoryImage>.from(
      images.map((item) => StoryImage.fromMap(item)),
    );
  }
}