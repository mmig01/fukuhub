import 'dart:async'; // StreamSubscription을 사용하기 위해 추가
import 'package:fukuhub/screens/before_login_screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fukuhub/widgets/total_app_bar_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  HomepageState createState() => HomepageState();
}

class HomepageState extends State<Homepage> {
  final FirebaseDatabase _realtime = FirebaseDatabase.instance;
  final String logo = 'assets/images/fuku_hub.png';
  final String mainPicture = "assets/images/fuku_hub.png";
  final Set<Marker> _markers = {};
  BitmapDescriptor? _customMarker;
  LatLng? _selectedPosition; // 선택된 위치 정보
  final TextEditingController _postController =
      TextEditingController(); // 게시글 입력 컨트롤러

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
  }

  // 커스텀 마커 로드
  void _loadCustomMarker() async {
    _customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/fuku_pin.png',
    );
  }

  // 마커 추가
  void _addMarker(LatLng position, String post) {
    final marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      infoWindow: InfoWindow(
        title: 'Custom Post',
        snippet: post,
      ),
      icon: _customMarker ?? BitmapDescriptor.defaultMarker, // 커스텀 마커 사용
    );

    setState(() {
      _markers.add(marker);
    });
  }

  // 위치 클릭 시 위젯 표시
  void _showPostWidget(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _postController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TotalAppBar(logo: logo),
      body: Row(
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
                    zoom: 12.0, // 10km 반경을 보기 위한 줌 레벨
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '게시글을 입력하세요.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedPosition != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _postController,
                          decoration: const InputDecoration(
                            labelText: 'Enter your post',
                            hintText: 'Enter your post here',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _addMarker(
                                    _selectedPosition!, _postController.text);
                                setState(() {
                                  _selectedPosition = null;
                                });
                              },
                              child: const Text('Save'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPosition = null;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    const Text('지도를 클릭하여 위치를 선택하세요.'),
                ],
              ),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Drawer Header
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
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
                    "hmm", // 사용자 이름
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Sunflower-Bold',
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  const Text(
                    "hmm", // 한 줄 소개
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontFamily: 'Sunflower-Light',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Drawer 아이템들
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                'My Page',
                style: TextStyle(
                  fontFamily: 'Sunflower-Light',
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              onTap: () {},
            ),
            const SizedBox(
              height: 10,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Sunflower-Light',
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
    );
  }

  // 로그아웃 처리
  Future<CircularProgressIndicator> _handleSignOut() async {
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
          await FirebaseAuth.instance.signOut();
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
