import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:onelot/data/video_info.dart';
import 'package:onelot/domain/api_service.dart';
import 'package:onelot/presentation/menu/home/video_item.dart';

import '../../../data/generic_response.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  bool isError = false;
  bool isLoading = false;
  String errorMsg = "";

  Future<GenericResponse>? _genericResponse;
  GenericResponse? genericResponse;

  Future<List<VideoInfo>>? _videosList;
  List<VideoInfo> finalVideosList = List.empty(growable: true);

  late ApiService apiService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    apiService = ApiService();

    fetchVideos();
  }

  void fetchVideos() {
    setState(() {
      isLoading = true;
      _genericResponse = apiService.fetchVideos();
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

  Future<List<VideoInfo>> getVideoData(List<dynamic> list) async {
    List<VideoInfo> results = List.empty(growable: true);

    await Future.wait(list.map((input) async {
      VideoInfo result = await parseVideoData(jsonEncode(input));
      results.add(result);
    }));

    return results;
  }


  Future<VideoInfo> parseVideoData(String jsonString) async{
    VideoInfo cwDriverJobs = VideoInfo.fromJson(jsonDecode(jsonString));
    debugPrint("DATA ELEMENT : $cwDriverJobs ");

    return cwDriverJobs;
  }

  @override
  Widget build(BuildContext context) {
    return  RefreshIndicator(
      onRefresh: () async{
         fetchVideos();
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
                InkWell(onTap: (){fetchVideos();},child:
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Icon(Icons.change_circle_outlined,color: Colors.grey,),
                    Text("Retry",style: TextStyle(color: Colors.grey),)
                  ],),
                ),)
              ],
            ),
          ),
        ) :  ListView.separated(
          itemCount: finalVideosList.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: (){
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (_)  =>   DriverInformation(driverInfo: finaldriversList[index],))).then((value) => fetchDrivers());
                //
                },
              title: VideoItem(videoInfo: finalVideosList[index],),
            );
          },
          separatorBuilder: (context, index) {
            return Divider(color: Colors.grey.shade300,);
          },
        ),
      ),
      );
  }
}
