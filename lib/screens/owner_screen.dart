import 'package:carol/models/stamp_card.dart';
import 'package:carol/screens/owner_design_store_screen.dart';
import 'package:carol/screens/owner_scan_qr_screen.dart';
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
      body: Stack(
        children: [
          const Positioned(
            child: StoresExplorer(),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: IconButton.filled(
              iconSize: 100,
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _onPressScanQr,
            ),
          )
        ],
      ),
      appBar: AppBar(
        title: const Text('Owner\'s Screen'),
        actions: [
          IconButton(
            onPressed: _onPressNewStore,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),
    );
  }

  void _onPressNewStore() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const OwnerDesignStoreScreen(
        designMode: StoreDesignMode.create,
      ),
    ));
  }

  void _onPressScanQr() {
    Navigator.of(context).push<SimpleStampCardQr>(MaterialPageRoute(
      builder: (context) => const OwnerScanQrScreen(),
    ));
    // final qr =
    //     await Navigator.of(context).push<SimpleStampCardQr>(MaterialPageRoute(
    //   builder: (context) => const OwnerScanQrScreen(),
    // ));
    // if (qr == null) {
    //   return;
    // }
    // Carol.showTextSnackBar(text: 'Got stamp card id: ${qr.stampCardId}');
  }
}
