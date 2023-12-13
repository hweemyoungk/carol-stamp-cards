import 'package:carol/widgets/cards_explorer/cards_explorer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CardsExplorer(
        parentContext: context,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {},
        items: const [
          BottomNavigationBarItem(
            label: 'Cards',
            icon: Icon(Icons.view_list),
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
