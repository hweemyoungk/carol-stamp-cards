import 'package:carol/models/base_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SingleModelNotifier<T extends BaseModel> extends StateNotifier<T?> {
  SingleModelNotifier(T? state) : super(state);

  void set(T? model) {
    state = model;
  }

  void replaceIfIdMatch(T model) {
    if (state == null) return;
    if (state!.id != model.id) return;
    state = model;
  }
}
