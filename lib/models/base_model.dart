abstract class BaseModel {
  final int id;

  BaseModel({required this.id});

  @override
  bool operator ==(Object other) =>
      other is BaseModel && other.runtimeType == runtimeType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
