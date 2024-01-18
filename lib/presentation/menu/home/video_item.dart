import 'package:flutter/material.dart';
import 'package:onelot/data/video_info.dart';

class VideoItem extends StatefulWidget {
  final VideoInfo videoInfo;
  const VideoItem({Key? key, required this.videoInfo}) : super(key: key);

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {

  late VideoInfo videoInfo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    videoInfo = widget.videoInfo;

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            videoInfo.thumbnailUrl,
            height: 150.0,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              // Display a placeholder image or any other UI element when an error occurs
              return Container(
                height: 150.0,
                width: double.infinity,
                color: Colors.grey, // Placeholder color
                child: Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 40.0,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 8.0),
          Text(
            videoInfo.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
