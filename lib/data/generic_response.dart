import '../data/base_model.dart';

class GenericResponse extends IBaseModel<GenericResponse> {
  String? data;
  int? status = 0;
  String? message;

  GenericResponse({
    this.data,
    this.status,
    this.message
});

  GenericResponse.fromJson(Map<dynamic, dynamic> json) {
    data = json['data'];
    status = json['status'];
    message = json['message'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['status'] = status;
    data['message'] = message;
    return data;
  }


  @override
  GenericResponse fromJson(Map<dynamic, dynamic> json) {
    return GenericResponse.fromJson(json);
  }

}