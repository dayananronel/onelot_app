import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

import '../../data/base_model.dart';

class BaseService {

  final baseUrl = "http://10.0.2.2:3000/";

  Future<dynamic> get<T extends IBaseModel>(String path, {required IBaseModel model}) async {
    final response = await http.get(Uri.parse("$baseUrl$path"));
    debugPrint("ENDPOINT : ${"$baseUrl$path"}");
    switch (response.statusCode) {
      case HttpStatus.ok:
        return _jsonBodyParser<T>(model, response.body);
      default:
        throw response.body;
    }
  }

  Future<dynamic> post<T extends IBaseModel>(
      String path,Object body,
      {required IBaseModel model}
      ) async {

    debugPrint("ENDPOINT : ${"$baseUrl$path"}");
    debugPrint("PARAMETERS : ${body.toString()}");

    Map<String,String> mapHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.post(Uri.parse("$baseUrl$path"),headers: mapHeaders,body: body).timeout(
        const Duration(minutes: 1),onTimeout: () {
      // Time has run out, do what you wanted to do.
      return http.Response('Request time out.', 408); // Request Timeout response status code
    });


    debugPrint("HTTP RESPONSE STATUS : ${response.statusCode}");
    debugPrint("HTTP RESPONSE BODY : ${response.body}");

    switch (response.statusCode) {
      case HttpStatus.ok:
        return _jsonBodyParser<T>(model, response.body);
      default:
        return response.body;
    }
  }

  Future<dynamic> multiPartRequest<T extends IBaseModel>(
      String urlPath,
      List<String> paths,
      {required IBaseModel model}) async {

    Map<String,String> mapHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    Uri uri = Uri.parse("$baseUrl$urlPath");
    debugPrint("ENDPOINT : ${"$baseUrl$urlPath"}");
    http.MultipartRequest request = http.MultipartRequest('POST', uri);
    request.headers.addAll(mapHeaders);
    for(String path in paths){
      request.files.add(await http.MultipartFile.fromPath('video', path));
    }

    print('HTTP REQUEST FIELDS : ${request.fields}');
    print('HTTP REQUST File : ${request.files.toString()}');

    http.StreamedResponse response = await request.send();
    var responseBytes = await response.stream.toBytes();
    var responseString = utf8.decode(responseBytes);
    print('\n\n');
    print('RESPONSE WITH HTTP');
    print(responseString);
    print('\n\n');

    switch (response.statusCode) {
      case HttpStatus.ok:
        return _jsonBodyParser<T>(model, responseString);
      default:
        return responseString;
    }

  }

  dynamic _jsonBodyParser<T>(IBaseModel model, String body) {
    final jsonBody = jsonDecode(body);

    if (jsonBody is List) {
      return jsonBody.map((e) => model.fromJson(e)).toList().cast<T>();
    } else if (jsonBody is Map) {
      return model.fromJson(jsonBody);
    } else {
      return jsonBody;
    }
  }

}