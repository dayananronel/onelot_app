import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:onelot/application/shared_pref_helper.dart';
import 'package:onelot/presentation/login/login_screen.dart';
import 'package:onelot/presentation/menu/home/home_screen.dart';
import 'package:onelot/presentation/menu/videos/video_list.dart';
import 'package:onelot/presentation/menu/videos/videos_screen.dart';
import 'package:path_provider/path_provider.dart';

import '../../application/utils/common_util.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String title = "Home";


  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    VideoList()
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if(_selectedIndex == 0){
        title = 'Home';
      }else if(_selectedIndex == 1){
        title = 'Uploaded Videos';
      }

    });
  }

  Future<bool> _logoutDialog() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Do you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Helper.saveLoginSession(false);

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => const LoginScreen()),
                  ModalRoute.withName('/')
              );

            },
            child: Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }


  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit an App'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  void handleClick(String value) {
    switch (value) {
      case 'Profile':
        break;
    }
  }


  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late String _videoPath;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }


  Future<void> _startRecording() async {
    final Directory? appDirectory = await getExternalStorageDirectory();
    _videoPath = '${appDirectory?.path}/video_${DateTime.now()}.mp4';
    await _controller.startVideoRecording();
  }

  Future<void> _stopRecording() async {
    await _controller.stopVideoRecording();
    // After recording, you can save the video path or perform other actions.
    // For simplicity, we'll just print the video path here.
    print('Video recorded at: $_videoPath');
  }

  @override
  void dispose() {
    //_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VideosScreen()));
            },
            child:Icon(Icons.videocam),
          ),
          backgroundColor: Colors.white,
          appBar: AppBar(
            actions:<Widget>[
                IconButton(onPressed: _logoutDialog, icon: Icon(Icons.logout,color: Colors.black,))
            ],
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Text(title,style: TextStyle(color: Colors.black),),
          ),
          body: Container(
            color: Colors.white10,
            child:
            _widgetOptions.elementAt(_selectedIndex),),
          bottomNavigationBar: BottomNavigationBar(

              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  label: "Home",
                    icon: Icon(Icons.home_rounded),
                ),
                BottomNavigationBarItem(
                    label: "Videos",
                    icon: Icon(Icons.video_collection),

                ),
              ],
              type: BottomNavigationBarType.shifting,
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
              elevation: 5
          ),
        )
    );

  }
}
