import 'package:carol/models/base_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EntityProviders<T extends BaseModel> {
  final Map<String, StateNotifierProvider<EntityStateNotifier<T>, T>>
      providers = {};

  bool tryAddProvider({
    required T entity,
    bool overwrite = true,
  }) {
    final provider = providers[entity.id];
    if (provider != null && !overwrite) return false;
    providers[entity.id] = StateNotifierProvider<EntityStateNotifier<T>, T>(
        (ref) => EntityStateNotifier<T>(entity: entity));
    return true;
  }

  void tryAddProviders({
    required Iterable<T> entities,
    bool overwrite = true,
  }) {
    for (final entity in entities) {
      tryAddProvider(entity: entity, overwrite: overwrite);
    }
  }

  StateNotifierProvider<EntityStateNotifier<T>, T>? tryGetProvider(
      {required T entity}) {
    return providers[entity.id];
  }

  StateNotifierProvider<EntityStateNotifier<T>, T>? tryGetProviderById(
      {required String id}) {
    return providers[id];
  }
}

class EntityStateNotifier<T extends BaseModel> extends StateNotifier<T> {
  EntityStateNotifier({required this.entity}) : super(entity);

  final T entity;

  void set({
    required T entity,
  }) {
    state = entity;
  }
}
