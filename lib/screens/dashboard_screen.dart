import 'package:carol/widgets/cards_explorer/cards_explorer.dart';
import 'package:carol/widgets/stores_explorer/stores_explorer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _activeBottomItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    final body = dashboardScreenBodies[_activeBottomItemIndex];
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeBottomItemIndex,
        onTap: (value) {
          if (mounted) {
            setState(() {
              _activeBottomItemIndex = value;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Cards',
            icon: Icon(Icons.card_giftcard),
          ),
          BottomNavigationBarItem(
            label: 'Stores',
            icon: Icon(Icons.store),
          ),
        ],
      ),
    );
  }
}

const dashboardScreenBodies = {
  0: CardsExplorer(),
  1: StoresExplorer(),
};
