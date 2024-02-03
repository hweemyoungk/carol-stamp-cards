import 'package:carol/models/base_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ListNotifier<T extends BaseModel>
    extends StateNotifier<List<T>?> {
  ListNotifier(super.state);

  bool replaceIfIdMatch(T model) {
    if (state == null) {
      return false;
    }
    final newState = <T>[];
    bool isReplace = false;
    for (final oldModel in state!) {
      if (oldModel.id != model.id) {
        newState.add(oldModel);
        continue;
      }
      isReplace = true;
      newState.add(model);
    }
    state = newState;
    return isReplace;
  }

  void replaceOrAppend(T model) {
    if (state == null) {
      return;
    }
    final isReplace = replaceIfIdMatch(model);
    if (!isReplace) {
      state = [...state!, model];
    }
  }

  void replaceOrPrepend(T model) {
    if (state == null) {
      return;
    }
    final isReplace = replaceIfIdMatch(model);
    if (!isReplace) {
      state = [model, ...state!];
    }
  }

  void set(
    List<T> models, {
    bool sort = true,
  }) {
    state = models;
    if (sort) {
      this.sort();
    }
  }

  void append(
    T model, {
    bool sort = true,
  }) {
    if (state == null) {
      return;
    }
    state = [...state!, model];
    if (sort) {
      this.sort();
    }
  }

  void prepend(
    T model, {
    bool sort = true,
  }) {
    if (state == null) {
      return;
    }
    state = [model, ...state!];
    if (sort) {
      this.sort();
    }
  }

  void appendAll(
    Iterable<T> models, {
    bool sort = true,
  }) {
    if (state == null) {
      return;
    }
    state = [...state!, ...models];
    if (sort) {
      this.sort();
    }
  }

  void prependAll(
    Iterable<T> models, {
    bool sort = true,
  }) {
    if (state == null) {
      return;
    }
    state = [...models, ...state!];
    if (sort) {
      this.sort();
    }
  }

  void sort();
}
