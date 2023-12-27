import 'package:carol/widgets/main_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActiveDrawerItemNotifier extends StateNotifier<DrawerItemEnum> {
  ActiveDrawerItemNotifier() : super(DrawerItemEnum.customer);

  void set(DrawerItemEnum drawerItemEnum) {
    state = drawerItemEnum;
  }
}

final activeDrawerItemProvider =
    StateNotifierProvider<ActiveDrawerItemNotifier, DrawerItemEnum>(
        (ref) => ActiveDrawerItemNotifier());
