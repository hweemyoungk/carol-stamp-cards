abstract class BaseModel<ID> {
  final ID id;
  final bool isDeleted;

  BaseModel({
    required this.id,
    required this.isDeleted,
  });
}
