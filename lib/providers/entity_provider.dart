import 'package:carol/models/base_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EntityProviders<T extends BaseModel> {
  final Map<String, StateNotifierProvider<EntityStateNotifier<T>, T>>
      providers = {};

  bool tryAddProvider({required T entity}) {
    final provider = providers[entity.id];
    if (provider != null) return false;
    providers[entity.id] = StateNotifierProvider<EntityStateNotifier<T>, T>(
        (ref) => EntityStateNotifier<T>(entity: entity));
    return true;
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
