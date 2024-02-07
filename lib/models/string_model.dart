import 'package:carol/models/base_model.dart';

abstract class StringModel extends BaseModel<String> {
  StringModel({required super.id, required super.isDeleted});

  @override
  bool operator ==(Object other) =>
      other is BaseModel &&
      other.runtimeType == runtimeType &&
      '' == other.id && // Empty string is dummy id and should not be compared
      other.id == id;

  @override
  int get hashCode => id.hashCode;
}
