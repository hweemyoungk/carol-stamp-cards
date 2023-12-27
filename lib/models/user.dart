import 'package:carol/models/base_model.dart';

class User extends BaseModel {
  User({
    required super.id,
    required this.displayName,
    required this.profileImageUrl,
  });
  final String displayName;
  final String? profileImageUrl;
}
