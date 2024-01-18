import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:onelot/data/video_info.dart';
import 'package:onelot/presentation/menu/videos/upload_item.dart';

import '../../../data/generic_response.dart';
import '../../../domain/api_service.dart';

class VideoList extends StatefulWidget {
  const VideoList({Key? key}) : super(key: key);

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {

  bool isError = false;
  bool isLoading = false;
  String errorMsg = "";

  Future<GenericResponse>? _genericResponse;
  GenericResponse? genericResponse;

  Future<List<String>>? _videosList;
  List<String> finalVideosList = List.empty(growable: true);

  late ApiService apiService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    apiService = ApiService();

    fetchUploadedVideos();
  }

  void fetchUploadedVideos() {
    setState(() {
      isLoading = true;
      _genericResponse = apiService.fetchUploadedVideos();
    });

    _genericResponse?.then((value){
      genericResponse = value;

      setState(() {
        isLoading = false;
      });

      if(genericResponse == null){
        setState(() {
          isError = true;
          errorMsg = "Failed to fetch videos. Please try again.";
        });

      }else{

        if(genericResponse?.status == 200){

          debugPrint("DATA : ${genericResponse?.data}");

          List<dynamic> list = jsonDecode(genericResponse?.data ?? "");

          if(list.isEmpty){
            setState(() {
              isError = true;
              errorMsg = "No videos found.";
            });
          }
          else{

            setState(() {
              _videosList = getVideoData(list);
            });

            _videosList?.then((value) {

              debugPrint("Videos ARR : ${value}");

              finalVideosList = value;

              setState(() {
                isError = false;
                errorMsg = "";
              });

            });

          }

        }else{
          setState(() {
            isError = true;
            errorMsg = "Failed to fetch videos. \n: ${(genericResponse?.message ?? "")}";
          });
        }
      }

    });

  }

  Future<List<String>> getVideoData(List<dynamic> list) async {
    List<String> results = List.empty(growable: true);

    await Future.wait(list.map((input) async {
      String result = await parseVideoData(jsonEncode(input));
      results.add(result);
    }));

    return results;
  }


  Future<String> parseVideoData(String jsonString) async{
    String video = jsonDecode(jsonString);
    debugPrint("DATA ELEMENT : $video ");

    return video;
  }

  @override
  Widget build(BuildContext context) {
    return  RefreshIndicator(
      onRefresh: () async{
        fetchUploadedVideos();
      },
      child: Container(
        child: isLoading ?  const Center(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: CircularProgressIndicator(),
          ),
        ): isError ? Center(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,color: Colors.red,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${errorMsg}",style: TextStyle(color: Colors.grey,fontSize: 18),textAlign: TextAlign.center,),
                ),
              ],
            ),
          ),
        ) : ListView.builder(
          itemCount: finalVideosList.length,
          itemBuilder: (context, index) {
            return UploadedItem(videoModel: finalVideosList[index]);
          },
        ),
      ),
    );
  }
}
