abstract class BaseModel {
  final int id;
  final bool isDeleted;

  BaseModel({
    required this.id,
    required this.isDeleted,
  });

  @override
  bool operator ==(Object other) =>
      other is BaseModel && other.runtimeType == runtimeType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
