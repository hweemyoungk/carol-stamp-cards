import 'package:carol/screens/owner_new_store_screen.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/stores_explorer/stores_explorer.dart';
import 'package:flutter/material.dart';

class OwnerScreen extends StatefulWidget {
  const OwnerScreen({super.key});

  @override
  State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const StoresExplorer(),
      appBar: AppBar(
        title: const Text('Owner\'s Screen'),
        actions: [
          IconButton(onPressed: _onPressNewStore, icon: const Icon(Icons.add))
        ],
      ),
      drawer: const MainDrawer(),
    );
  }

  void _onPressNewStore() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const OwnerNewStoreScreen(),
    ));
  }
}
