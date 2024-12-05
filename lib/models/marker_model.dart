import 'package:fukuhub/models/comment_model.dart';

class MarkerModel {
  final String title;
  final String name;
  final String password;
  final String imageUrl;
  final String description;
  final String postid;
  final List<CommentModel>? comments;
  MarkerModel({
    required this.name,
    required this.password,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.postid,
    this.comments,
  });
}
