
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String TYPE_ERROR = "error";
const String TYPE_SUCCESS = "success";

Icon toastIcon(String type){
  Icon finalIcon = Icon(Icons.check,color: Colors.white,);
  if(type == "error"){
    finalIcon =  Icon(Icons.cancel_outlined,color: Colors.white,);
  }
  return finalIcon;
}

void clearSharedPref() async {
  final pref = await SharedPreferences.getInstance();
  await pref.clear();

}