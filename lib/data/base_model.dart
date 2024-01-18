abstract class IBaseModel<T> {
  Map<String, dynamic> toJson();
  T fromJson(Map<dynamic, dynamic> json);
}
