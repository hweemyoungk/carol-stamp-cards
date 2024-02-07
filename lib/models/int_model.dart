import 'package:carol/models/base_model.dart';

abstract class IntModel extends BaseModel<int> {
  IntModel({required super.id, required super.isDeleted});

  @override
  bool operator ==(Object other) =>
      other is BaseModel &&
      other.runtimeType == runtimeType &&
      0 < other.id && // Negative or zero is dummy id and should not be compared
      other.id == id;

  @override
  int get hashCode => id.hashCode;
}
