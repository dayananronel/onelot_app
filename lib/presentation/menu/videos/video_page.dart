import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onelot/domain/api_service.dart';
import 'package:video_player/video_player.dart';

import '../../../application/utils/common_util.dart';
import '../../../data/generic_response.dart';

class VideoPage extends StatefulWidget {
  final String filePath;

  const VideoPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;

  late ApiService apiService;

  List<String> videopaths = List.empty(growable: true);

  late FToast fToast;

  bool isError = false;
  bool isLoading = false;
  String errorMsg = "";

  Future<GenericResponse>? _genericResponse;
  GenericResponse? genericResponse;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fToast = FToast();
    fToast.init(context);
    apiService =  ApiService();

    videopaths.add(widget.filePath);

  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              uploadVideo(videopaths);
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return VideoPlayer(_videoPlayerController);
          }
        },
      ),
    );
  }


  void uploadVideo(List<String> files){
    showLoaderDialog("Uploading file...", context);

    setState(() {
      _genericResponse = apiService.uploadVideo(files);

    });

    _genericResponse?.then((value) async{
      genericResponse = value;

      debugPrint("GENERIC RESPONSE : ${value.toString()}");

      Navigator.of(context).pop();

      if(genericResponse == null){
        showToast("Request failed. Please try again.",TYPE_ERROR);
      }
      else{
        if(genericResponse?.status == 200){
          showToast("File uploaded successfully.",TYPE_SUCCESS);

          Navigator.pop(context);

        }else{
          showToast("Failed to upload file. Please try again.",TYPE_ERROR);
        }
      }
    });
  }

  showLoaderDialog(String msg, BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(margin: const EdgeInsets.only(left: 7), child: Text(msg)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showToast(String message,String type)  async{
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: type == "error" ? Colors.red : Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          toastIcon(type),
          const SizedBox(
            width: 12.0,
          ),
          Flexible(child: Text(message)),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Icon toastIcon(String type){
    Icon finalIcon = Icon(Icons.check,color: Colors.white,);
    if(type == "error"){
      finalIcon =  Icon(Icons.cancel_outlined,color: Colors.white,);
    }
    return finalIcon;
  }


}