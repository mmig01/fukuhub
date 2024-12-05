import 'dart:async'; // StreamSubscription을 사용하기 위해 추가
import 'dart:typed_data';
import 'package:fukuhub/models/comment_model.dart';
import 'package:fukuhub/widgets/%08commentSection.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fukuhub/models/marker_model.dart';
import 'package:fukuhub/screens/before_login_screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fukuhub/widgets/total_app_bar_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker_web/image_picker_web.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  StreamSubscription<User?>? _authSubscription; // StreamSubscription 변수 추가
  final storageRef = FirebaseStorage.instance.ref(); // Storage 참조

  Uint8List? _image;

  final String logo = 'assets/images/fuku_hub.png';
  final String mainPicture = "assets/images/fuku_hub.png";
  final Set<Marker> _markers = {};
  BitmapDescriptor? _customMarker;
  LatLng? _selectedPosition; // 선택된 위치 정보
  bool isMarked = false; // 마커가 있는지 여부
  bool isPasswordCorrect = false; // 비밀번호가 일치하는지 여부
  bool isCommentPasswordCorrect = false; // 댓글 비밀번호가 일치하는지 여부
  MarkerModel _selectedMarker = MarkerModel(
    title: '',
    imageUrl: '',
    description: '',
    name: '',
    password: '',
    postid: '',
  ); // 선택된 마커 정보
  final TextEditingController _titleController =
      TextEditingController(); // 제목 컨트롤러
  final TextEditingController _nameController =
      TextEditingController(); // 이름 컨트롤러
  final TextEditingController _passwordController =
      TextEditingController(); // 비밀번호 컨트롤러
  final TextEditingController _descriptionController =
      TextEditingController(); // 설명 컨트롤러
  final TextEditingController _commentNameController =
      TextEditingController(); // 댓글 작성자 이름 컨트롤러
  final TextEditingController _commentPasswordController =
      TextEditingController(); // 설명 컨트롤러
  final TextEditingController _commentController =
      TextEditingController(); // 댓글 컨트롤러
  double doorOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    // 페이지 로드 시 페이드 효과 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        doorOpacity = 1.0;
      });
    });
    // 데이터베이스에서 마커 추가
    _addMarkersFromDatabase();
  }

  // 커스텀 마커 로드
  void _loadCustomMarker() async {
    _customMarker = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/fuku_pin.png',
    );
  }

  Future<void> _addMarkersFromDatabase() async {
    final databaseRef = FirebaseDatabase.instance.ref().child('posts');

    try {
      // Firebase에서 게시글 데이터 가져오기
      final snapshot = await databaseRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> posts = snapshot.value as Map<dynamic, dynamic>;

        // 게시글 데이터 반복
        posts.forEach((postId, post) async {
          List<CommentModel>? postComments = [];
          // 위치 데이터가 없으면 무시
          if (post['position'] == null) return;

          LatLng position = LatLng(
            post['position']['latitude'],
            post['position']['longitude'],
          );

          String truncateDescription(String description) {
            if (description.length > 10) {
              return '${description.substring(0, 10)}...';
            }
            return description;
          }

          // description 축약
          String truncatedDescription =
              truncateDescription(post['description']);

          final commentDatabaseRef =
              FirebaseDatabase.instance.ref('posts/$postId').child('comments');
          final commentSnapshot = await commentDatabaseRef.get();

          if (commentSnapshot.exists) {
            Map<dynamic, dynamic> comments =
                commentSnapshot.value as Map<dynamic, dynamic>;
            comments.forEach((commentId, comment) {
              final commentModel = CommentModel(
                comment: comment['comment'],
                name: comment['name'],
              );
              postComments.add(commentModel);
            });
          }

          // 각 게시글 정보를 마커로 추가
          final marker = Marker(
            markerId: MarkerId(postId),
            position: position,
            infoWindow: InfoWindow(
              title: post['title'],
              snippet: truncatedDescription,
              onTap: () {
                setState(() {
                  _selectedMarker = MarkerModel(
                    name: post['name'],
                    password: post['password'],
                    title: post['title'],
                    // image url 이 null 이면 '' 으로 대체
                    imageUrl: post['imageUrl'] ?? '',
                    description: post['description'], postid: post['postid'],
                    comments: postComments,
                  );
                  isMarked = true;
                });
              },
            ),
            icon: _customMarker ?? BitmapDescriptor.defaultMarker, // 커스텀 마커 사용
          );

          setState(() {
            _markers.add(marker);
          });
        });
      } else {
        print('No posts found in the database.');
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  // 위치 클릭 시 위젯 표시
  void _showPostWidget(LatLng position) {
    setState(() {
      isMarked = false;
      _selectedPosition = position;
      _titleController.clear();
      _nameController.clear();
      _passwordController.clear();
      _descriptionController.clear();
      _commentNameController.clear();
      _commentPasswordController.clear();
      _commentController.clear();
      _image = null;
    });
  }

  Future<Uint8List> compressImage(Uint8List imageData,
      {int quality = 60}) async {
    // 이미지 디코딩
    final decodedImage = img.decodeImage(imageData);
    if (decodedImage == null) {
      throw Exception("Failed to decode image");
    }

    // 품질 설정하여 압축
    final compressedImage = img.encodeJpg(decodedImage, quality: quality);

    // Uint8List 반환
    return Uint8List.fromList(compressedImage);
  }

  Future<void> _pickImage() async {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(), // 로딩 스피너 표시
          );
        },
      );
    }
    Uint8List? pickedFile = await ImagePickerWeb.getImageAsBytes();
    if (pickedFile != null) {
      // 로딩 화면을 잠깐 표시

      final compressedImage = await compressImage(pickedFile, quality: 80);

      setState(() {
        _image = compressedImage;
      });
    }
    if (mounted) {
      Navigator.of(context).pop(); // 로딩 화면 닫기
    }
  }

  // 입력 필드가 비어 있는지 확인하는 함수
  bool _validateInputs() {
    if (_nameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      return false;
    }
    return true;
  }

  bool _validateCommentInputs() {
    if (_commentNameController.text.isEmpty ||
        _commentPasswordController.text.isEmpty ||
        _commentController.text.isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _savePost() async {
    if (_selectedPosition != null) {
      try {
        // Firebase Realtime Database에 새 게시글 생성
        final databaseRef =
            FirebaseDatabase.instance.ref().child('posts').push();
        final postId = databaseRef.key; // 고유 ID 가져오기
        if (postId == null) throw Exception('Failed to generate post ID');

        // Firebase Realtime Database에 데이터 저장
        await databaseRef.set({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'position': {
            'latitude': _selectedPosition!.latitude,
            'longitude': _selectedPosition!.longitude,
          },
          'name': _nameController.text,
          'password': _passwordController.text,
          'postid': postId,
        });

        // 로딩 화면을 잠깐 표시
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return const Center(
                child: CircularProgressIndicator(), // 로딩 스피너 표시
              );
            },
          );
        }

        if (_image != null) {
          // Firebase Storage에 이미지 업로드
          String fileName = 'posts/$postId/image.png'; // postId를 경로에 사용
          final storageRef = FirebaseStorage.instance.ref().child(fileName);
          final uploadTask = storageRef.putData(_image!);

          final snapshot = await uploadTask;
          final imageUrl = await snapshot.ref.getDownloadURL();

          // Firebase Realtime Database에 데이터 저장
          await databaseRef.update({
            'imageUrl': imageUrl,
          });
        }

        // 상태 초기화
        setState(() {
          _selectedPosition = null;
          _titleController.clear();
          _nameController.clear();
          _passwordController.clear();
          _descriptionController.clear();
          _image = null;
        });

        await _addMarkersFromDatabase();
        // 약간의 지연을 주고 페이지를 이동
        await Future.delayed(const Duration(seconds: 2));

        // 로딩 화면을 닫고 새 페이지로 이동
        if (mounted) {
          Navigator.of(context).pop(); // 로딩 화면 닫기
        }
      } catch (e) {
        print('Error saving post: $e');
      }
    } else {}
  }

  Future<void> _saveComment() async {
    try {
      // Firebase Realtime Database에 새 게시글 생성
      final databaseRef = FirebaseDatabase.instance
          .ref('posts/${_selectedMarker.postid}')
          .child('comments')
          .push();
      final commentId = databaseRef.key; // 고유 ID 가져오기
      if (commentId == null) throw Exception('Failed to generate comment ID');

      // Firebase Realtime Database에 데이터 저장
      await databaseRef.set({
        'comment': _commentController.text,
        'name': _commentNameController.text,
        'password': _commentPasswordController.text,
      });

      // 로딩 화면을 잠깐 표시
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(), // 로딩 스피너 표시
            );
          },
        );
      }

      // 상태 초기화
      setState(() {
        _selectedPosition = null;
        _commentController.clear();
        _commentNameController.clear();
        _commentPasswordController.clear();
      });

      await _addMarkersFromDatabase();
      // 약간의 지연을 주고 페이지를 이동
      await Future.delayed(const Duration(seconds: 2));

      // 로딩 화면을 닫고 새 페이지로 이동
      if (mounted) {
        Navigator.of(context).pop(); // 로딩 화면 닫기
      }
    } catch (e) {
      print('Error saving post: $e');
    }
  }

  // 비밀번호가 맞는지 확인하는 함수 (예시용, 실제 구현에서는 비밀번호를 비교해야 함)
  // 비밀번호 검증 후 게시글 삭제
  Future<void> _checkPasswordAndDelete() async {
    final password = _passwordController.text;

    // Firebase에서 게시글의 비밀번호를 가져옴
    try {
      final postRef =
          FirebaseDatabase.instance.ref('posts/${_selectedMarker.postid}');
      final snapshot = await postRef.get();

      if (snapshot.exists) {
        // 게시글의 비밀번호를 가져옴
        final postPassword = snapshot.child('password').value as String;

        // 입력한 비밀번호와 Firebase에 저장된 비밀번호 비교
        if (password == postPassword) {
          // 비밀번호가 맞으면 해당 게시글 삭제
          await _deletePost();
          // 삭제 성공 후 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('削除しました。')),
          );
          Navigator.of(context).pop(); // 다이얼로그 닫기
        } else {
          // 비밀번호가 틀리면 오류 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('間違ったパスワードです！')),
          );
        }
      } else {
        // 게시글을 찾을 수 없는 경우
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('投稿が見つかりませんでした！')),
        );
      }
    } catch (e) {
      print('Error checking password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('パスワードの確認に失敗しました。')),
      );
    }
  }

  // Firebase에서 해당 게시글을 삭제하는 함수
  Future<void> _deletePost() async {
    try {
      // _selectedMarker의 postid를 사용하여 해당 게시글 삭제
      final postId = _selectedMarker.postid;
      final postRef = FirebaseDatabase.instance.ref('posts/$postId');

      // 해당 게시글을 삭제
      await postRef.remove();

      // 게시글이 삭제된 후 추가 작업이 있으면 여기에 구현
      setState(() {
        _selectedPosition = null;
        isMarked = false;
        _markers.removeWhere((marker) => marker.markerId.value == postId);
      });
    } catch (e) {
      print('Error deleting post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('削除に失敗しました。')),
      );
    }
  }

  // 삭제 아이콘 클릭 시 비밀번호 입력 다이얼로그 표시
  Future<void> _showPasswordDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('パスワードを入力してください'),
          content: TextField(
            controller: _passwordController,
            decoration: const InputDecoration(hintText: 'パスワード'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _passwordController.clear();
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: _checkPasswordAndDelete,
              child: const Text('確認'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel(); // Firebase Auth 리스너 정리
    _titleController.dispose(); // 텍스트 컨트롤러 정리
    _nameController.dispose(); // 이름 컨트롤러 정리
    _passwordController.dispose(); // 비밀번호 컨트롤러 정리
    _descriptionController.dispose(); // 텍스트 컨트롤러 정리
    _commentNameController.dispose(); // 댓글 작성자 이름 컨트롤러 정리
    _commentPasswordController.dispose(); // 댓글 비밀번호 컨트롤러 정리
    _commentController.dispose(); // 댓글 컨트롤러 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TotalAppBar(logo: logo),
      body: AnimatedOpacity(
        opacity: doorOpacity,
        duration: const Duration(milliseconds: 1200),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(
                    'assets/images/fukuback2.jpeg',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.white.withOpacity(0.6), // 투명도 설정
                    BlendMode.lighten,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Row(
                children: [
                  // 왼쪽 절반: Google Map
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: LatLng(37.4483, 140.5758), // 다무라 시의 위도와 경도
                            zoom: 12.5, // 10km 반경을 보기 위한 줌 레벨
                          ),
                          markers: _markers,
                          onTap: (LatLng position) {
                            _showPostWidget(position); // 장소 클릭 시 위젯 표시
                          },
                        ),
                      ),
                    ),
                  ),
                  // 오른쪽 절반: Column을 통한 정보 표시 영역
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 10),
                                isMarked
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                width: 1,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(50.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                  _selectedMarker.title,
                                                  style: const TextStyle(
                                                    fontFamily: 'sana',
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                if (_selectedMarker.imageUrl !=
                                                    '')
                                                  Container(
                                                    height: 300,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Image.network(
                                                      _selectedMarker.imageUrl,
                                                      loadingBuilder: (context,
                                                          child,
                                                          loadingProgress) {
                                                        if (loadingProgress ==
                                                            null) {
                                                          return child; // 이미지가 정상적으로 로드되었을 때
                                                        } else {
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              value: loadingProgress
                                                                          .expectedTotalBytes !=
                                                                      null
                                                                  ? loadingProgress
                                                                          .cumulativeBytesLoaded /
                                                                      (loadingProgress
                                                                              .expectedTotalBytes ??
                                                                          1)
                                                                  : null, // 진행률을 표시
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return const Icon(
                                                          Icons.broken_image,
                                                          size: 50,
                                                          color: Colors.grey,
                                                        ); // 에러 발생 시 대체 아이콘
                                                      },
                                                    ),
                                                  ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  _selectedMarker.description,
                                                  style: const TextStyle(
                                                    fontFamily: 'sana',
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  '作成者: ${_selectedMarker.name}',
                                                  style: const TextStyle(
                                                    fontFamily: 'sana',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed:
                                                    _showPasswordDialog, // 삭제 아이콘 클릭 시 다이얼로그 표시
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 50,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                width: 1,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'コメント',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'sana',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                CommentsSection(
                                                    postId:
                                                        _selectedMarker.postid),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 50,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                width: 1,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                const Text(
                                                  '有益な情報ですか？ コメントを残してください。',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'sana',
                                                  ),
                                                ),
                                                const SizedBox(height: 30),
                                                SizedBox(
                                                  width: 200,
                                                  child: TextField(
                                                    controller:
                                                        _commentNameController,
                                                    decoration: InputDecoration(
                                                      hintStyle: TextStyle(
                                                        color: Colors.black
                                                            .withOpacity(
                                                                0.5), // 힌트 텍스트 색상
                                                        fontSize:
                                                            14, // 힌트 텍스트 크기
                                                      ),
                                                      labelText: '作成者',
                                                      hintText: '名前（ニックネーム）',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: TextField(
                                                    obscureText: true,
                                                    controller:
                                                        _commentPasswordController,
                                                    decoration: InputDecoration(
                                                      hintStyle: TextStyle(
                                                        color: Colors.black
                                                            .withOpacity(
                                                                0.5), // 힌트 텍스트 색상
                                                        fontSize:
                                                            14, // 힌트 텍스트 크기
                                                      ),
                                                      labelText: 'パスワード',
                                                      hintText: 'パスワード',
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 30),
                                                TextField(
                                                  controller:
                                                      _commentController,
                                                  decoration: InputDecoration(
                                                    hintStyle: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(
                                                              0.5), // 힌트 텍스트 색상
                                                      fontSize: 14, // 힌트 텍스트 크기
                                                    ),
                                                    labelText: 'コメント',
                                                    hintText: 'コメントを残してください。',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Column(
                                                  children: [
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty.all<
                                                                    Color>(
                                                                const Color(
                                                                    0xFFFFB6C1)),
                                                      ),
                                                      onPressed: () {
                                                        if (_validateCommentInputs()) {
                                                          _saveComment();
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'すべてのフィールドを入力してください。'),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: const Text('セーブ',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'sana',
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    : _selectedPosition != null
                                        ? Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.black
                                                    .withOpacity(0.7),
                                                width: 1,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              children: [
                                                const Text(
                                                  '記憶を残してみてください。',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontFamily: 'sana',
                                                  ),
                                                ),
                                                const SizedBox(height: 30),
                                                SizedBox(
                                                  width: 200,
                                                  child: TextField(
                                                    controller: _nameController,
                                                    decoration: InputDecoration(
                                                      hintStyle: TextStyle(
                                                        color: Colors.black
                                                            .withOpacity(
                                                                0.5), // 힌트 텍스트 색상
                                                        fontSize:
                                                            14, // 힌트 텍스트 크기
                                                      ),
                                                      labelText: '作成者',
                                                      hintText: '名前（ニックネーム）',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: TextField(
                                                    obscureText: true,
                                                    controller:
                                                        _passwordController,
                                                    decoration: InputDecoration(
                                                      hintStyle: TextStyle(
                                                        color: Colors.black
                                                            .withOpacity(
                                                                0.5), // 힌트 텍스트 색상
                                                        fontSize:
                                                            14, // 힌트 텍스트 크기
                                                      ),
                                                      labelText: 'パスワード',
                                                      hintText: 'パスワード',
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 30),
                                                TextField(
                                                  controller: _titleController,
                                                  decoration: InputDecoration(
                                                    hintStyle: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(
                                                              0.5), // 힌트 텍스트 색상
                                                      fontSize: 14, // 힌트 텍스트 크기
                                                    ),
                                                    labelText: '題目',
                                                    hintText: 'タイトルを入力してください。',
                                                  ),
                                                ),
                                                const SizedBox(height: 50),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    if (_image != null)
                                                      Image.memory(
                                                        _image!,
                                                        height: 200,
                                                        width: 200,
                                                      ),
                                                    const SizedBox(height: 10),
                                                    ElevatedButton(
                                                      onPressed: _pickImage,
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty.all<
                                                                    Color>(
                                                                const Color(
                                                                    0xFFFFB6C1)),
                                                      ),
                                                      child: const Text('イメージ',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'sana',
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                TextField(
                                                  controller:
                                                      _descriptionController,
                                                  decoration: InputDecoration(
                                                    hintStyle: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(
                                                              0.5), // 힌트 텍스트 색상
                                                      fontSize: 14, // 힌트 텍스트 크기
                                                    ),
                                                    labelText: '内容',
                                                    hintText: 'あなたの話を聞かせてください。',
                                                  ),
                                                ),
                                                const SizedBox(height: 30),
                                                Column(
                                                  children: [
                                                    ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            WidgetStateProperty.all<
                                                                    Color>(
                                                                const Color(
                                                                    0xFFFFB6C1)),
                                                      ),
                                                      onPressed: () {
                                                        if (_validateInputs()) {
                                                          _savePost();
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'すべてのフィールドを入力してください。'),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      child: const Text(
                                                        'セーブ',
                                                        style: TextStyle(
                                                            fontFamily: 'sana',
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        : const Text(
                                            '地図をクリックして場所を選択してください.',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'sana',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 로딩 표시
                ],
              ),
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: const AssetImage(
                'assets/images/fukuback2.jpeg', // 공통 배경 이미지
              ),
              fit: BoxFit.cover, // 이미지 잘라내기
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.6), // 투명도 설정
                BlendMode.lighten,
              ),
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              // Drawer Header
              DrawerHeader(
                // decoration: const BoxDecoration(
                //   color: Colors.white,
                // ),
                child: Column(
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      height: 80,
                      child: Image.asset(mainPicture),
                    ),
                    const Text(
                      "福島記憶リポジトリ",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'sana',
                      ),
                    ),
                  ],
                ),
              ),
              // Drawer 아이템들

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text(
                  'バイバイ',
                  style: TextStyle(
                    fontFamily: 'sana',
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  _handleSignOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 로그아웃 처리
  Future<CircularProgressIndicator> _handleSignOut() async {
    await FirebaseAuth.instance.signOut();
    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(), // 로딩 스피너 표시
            );
          },
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.of(context).pop(); // 로딩 화면 닫기
        }

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const Login(
                isFirstNavigatedSocialLoginButton: true,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 500),
              reverseTransitionDuration: const Duration(milliseconds: 500),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      print('Sign out error: $e');
    }
    return const CircularProgressIndicator();
  }
}
