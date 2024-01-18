import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class UploadedItem extends StatefulWidget {
  final String videoModel;

  const UploadedItem({Key? key, required this.videoModel}) : super(key: key);

  @override
  State<UploadedItem> createState() => _UploadedItemState();
}

class _UploadedItemState extends State<UploadedItem> {

  late VideoPlayerController _videoPlayerController;
  double _currentVolume = 1.0; // Initial volume value
  final bool _isFullScreen = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(
        "http://10.0.2.2:3000/uploads/${widget.videoModel}")
      ..addListener(() {
        if (_videoPlayerController.value.isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = _videoPlayerController.value.isPlaying;
          });
        }
      })
      ..initialize().then((_) {
        setState(() {
          // Video is initialized and ready to play.
          _isPlaying = _videoPlayerController.value.isPlaying;
        });
      });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.videoModel,style: TextStyle(color: Colors.black,fontSize: 18),),
          ),
          GestureDetector(
            onTap: () {
              if (_videoPlayerController.value.isPlaying) {
                _videoPlayerController.pause();
              } else {
                _videoPlayerController.play();
              }
            },
            child: AspectRatio(
              aspectRatio: 16 / 9,
              // Default aspect ratio in non-fullscreen mode
              child: VideoPlayer(_videoPlayerController),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: _isPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      if (_videoPlayerController.value.isPlaying) {
                        _videoPlayerController.pause();
                      } else {
                        _videoPlayerController.play();
                      }
                    });
                  },
                ),
                IconButton(
                  icon:  Icon(Icons.fullscreen),
                  onPressed: () {
                   _showFullScreenDialog();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: () {
                    setState(() {
                      _videoPlayerController.pause();
                    });
                  },
                ),
                IconButton(
                  icon: _currentVolume == 0.0 ? Icon(Icons.volume_off_rounded) : Icon(Icons.volume_up),
                  onPressed: () {
                    setState(() {
                      if (_currentVolume == 0.0) {
                        _currentVolume = 1.0;
                      } else {
                        _currentVolume = 0.0;
                      }
                      _videoPlayerController.setVolume(_currentVolume);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenDialog() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            body: Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController),
              ),
            ),
          );
        },
        fullscreenDialog: true,
      ),
    );
  }
}
