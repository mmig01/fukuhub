import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fukuhub/models/comment_model.dart'; // CommentModel 정의된 곳

class CommentsSection extends StatefulWidget {
  final String postId;

  const CommentsSection({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  Future<List<CommentModel>> _fetchComments() async {
    // Firebase에서 데이터 가져오기
    try {
      final databaseRef =
          FirebaseDatabase.instance.ref('posts/${widget.postId}/comments');
      final snapshot = await databaseRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> commentsMap =
            snapshot.value as Map<dynamic, dynamic>;
        return commentsMap.entries.map((entry) {
          final data = entry.value;
          return CommentModel(
            name: data['name'] ?? 'Anonymous',
            comment: data['comment'] ?? '',
          );
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CommentModel>>(
      future: _fetchComments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 로딩 중일 때 스피너 표시
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // 에러 발생 시 메시지 표시
          return const Center(
            child: Text(
              'Failed to load comments',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // 데이터가 없을 때 메시지 표시
          return const Center(
            child: Text(
              'コメントがありません。',
              style: TextStyle(
                fontFamily: 'sana',
                fontSize: 16,
              ),
            ),
          );
        } else {
          // 데이터가 있을 때 댓글 표시
          final comments = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // 부모와 스크롤 충돌 방지
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                child: Text(
                  '${comment.name}: ${comment.comment}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'sana',
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
