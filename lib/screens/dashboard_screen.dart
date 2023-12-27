import 'package:carol/providers/active_drawer_item_provider.dart';
import 'package:carol/screens/customer_screen.dart';
import 'package:carol/screens/owner_screen.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Widget content;

  @override
  Widget build(BuildContext context) {
    final activeDrawerItemEnum = ref.watch(activeDrawerItemProvider);
    if (activeDrawerItemEnum == DrawerItemEnum.customer) {
      content = CustomerScreen();
    } else if (activeDrawerItemEnum == DrawerItemEnum.owner) {
      content = const OwnerScreen();
    } else {
      throw UnimplementedError();
    }

    return content;
  }
}
