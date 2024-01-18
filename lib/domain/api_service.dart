
import 'package:flutter/cupertino.dart';

import '../data/generic_response.dart';
import 'base_service.dart';

class ApiService extends BaseService {

  Future<GenericResponse> fetchVideos() async {
    try{
      final response =await get("video", model: GenericResponse());
      return response;
    }catch(error){
      debugPrint("ERROR $error");
      return GenericResponse();
    }
  }

  Future<GenericResponse> fetchUploadedVideos() async {
    try{
      final response =await get("getFiles", model: GenericResponse());
      return response;
    }catch(error){
      debugPrint("ERROR $error");
      return GenericResponse();
    }
  }

  Future<GenericResponse> uploadVideo(
      List<String> arrPaths
      ) async {
    try{
      final response =  await multiPartRequest("upload",arrPaths, model: GenericResponse());
      return response;
    }catch(error){
      debugPrint("ERROR ${error}");
      return GenericResponse();
    }
  }


}