import 'package:carol/widgets/cards_explorer/cards_explorer.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/stores_explorer/stores_explorer.dart';
import 'package:flutter/material.dart';

class CustomerScreen extends StatefulWidget {
  CustomerScreen({super.key});

  final customerScreenBodies = {
    0: const CardsExplorer(),
    1: const StoresExplorer(),
  };

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int _activeBottomItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.customerScreenBodies[_activeBottomItemIndex],
      appBar: AppBar(
        title: const Text('Customer\'s Screen'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeBottomItemIndex,
        onTap: _onTapBottomItem,
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
      drawer: const MainDrawer(),
    );
  }

  void _onTapBottomItem(value) {
    if (mounted) {
      setState(() {
        _activeBottomItemIndex = value;
      });
    }
  }
}
