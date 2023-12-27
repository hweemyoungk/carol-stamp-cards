import 'package:carol/widgets/main_drawer.dart';
import 'package:carol/widgets/stores_explorer/stores_explorer.dart';
import 'package:flutter/material.dart';

class OwnerScreen extends StatelessWidget {
  const OwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const StoresExplorer(),
      appBar: AppBar(
        title: const Text('Owner\'s Screen'),
      ),
      drawer: const MainDrawer(),
    );
  }
}
