import 'dart:convert';
import 'dart:io';

import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/screens/owner_grant_stamps_screen.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class OwnerScanQrScreen extends ConsumerStatefulWidget {
  const OwnerScanQrScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OwnerScanQrScreen> createState() => _OwnerScanQrScreenState();
}

class _OwnerScanQrScreenState extends ConsumerState<OwnerScanQrScreen> {
  SimpleStampCardQr? _qr;
  QRViewController? _controller;
  final GlobalKey _qrKey = GlobalKey();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller!.pauseCamera();
    }
    _controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: _buildQrView(context),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: DesignUtils.basicWidgetEdgeInsets(),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _controller?.toggleFlash();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: _controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return const Text('Toggle Flash');
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: DesignUtils.basicWidgetEdgeInsets(),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _controller?.flipCamera();
                            setState(() {});
                          },
                          child: FutureBuilder(
                            future: _controller?.getCameraInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.data != null) {
                                return const Text('Flip camera');
                              } else {
                                return const Text('Loading...');
                              }
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });
    controller.scannedDataStream.listen(
      _handleScanData,
      onDone: () async {
        if (_qr == null) {
          if (mounted) {
            Navigator.of(context).pop();
          }
          return;
        }

        final qr = _qr!;

        if (qr.isInactive) {
          if (mounted) {
            Carol.showTextSnackBar(text: 'Inactive card');
            Navigator.of(context).pop();
          }
          return;
        }

        // Fetch StampCard and Blueprint
        // Get dummy blueprint and stampcard
        // final ownerStores = ref.read(ownerStoresProvider);
        // if (ownerStores.isEmpty) {
        //   Carol.showTextSnackBar(text: 'You don\'t have any store yet');
        //   Navigator.of(context).pop();
        // }
        // final store = ownerStores[0];
        // final storeProvider =
        //     ownerStoreProviders.tryGetProviderById(id: store.id)!;
        // final storeNotifier = ref.read(storeProvider.notifier);
        // final StampCardBlueprint blueprint;
        // if (store.blueprints == null) {
        //   // Load blueprints
        //   final blueprints =
        //       genDummyBlueprints(numBlueprints: 1, storeId: store.id);
        //   storeNotifier.set(entity: store.copyWith(blueprints: blueprints));
        //   blueprint = blueprints[0];
        // } else {
        //   blueprint = store.blueprints![0];
        // }
        // final StampCard stampCard = genDummyStampCards(
        //   numCards: 1,
        //   blueprint: blueprint,
        // )[0];

        final stampCardTask = owner_apis.getStampCard(id: qr.stampCardId);
        final blueprintTask = owner_apis.getBlueprint(id: qr.blueprintId);
        final StampCard stampCard;
        final Blueprint blueprint;
        try {
          [
            stampCard as StampCard,
            blueprint as Blueprint,
          ] = await Future.wait(
            [
              stampCardTask,
              blueprintTask,
            ],
            eagerError: true,
          );
        } on Exception catch (e) {
          Carol.showExceptionSnackBar(
            e,
            contextMessage:
                'Failed to get customer\'s stamp card and blueprint information.',
          );
          if (mounted) {
            Navigator.of(context).pop();
          }
          return;
        }

        // No need to register to providers: temporary data for redeem process.

        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (ctx) => OwnerGrantStampsScreen(
              stampCard: stampCard,
              blueprint: blueprint,
            ),
          ));
        }
      },
    );
  }

  void _handleScanData(Barcode scanData) {
    if (!_validateResult(scanData)) {
      return;
    }
    _qr = SimpleStampCardQr.fromJson(json.decode(scanData.code!));
    // Close stream to invoke onDone
    _controller!.dispose();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      Carol.showTextSnackBar(text: 'Needs permission');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool _validateResult(Barcode result) {
    // Must be QR
    if (result.format != BarcodeFormat.qrcode) {
      Carol.showTextSnackBar(text: 'Must be QR code');
      return false;
    }
    final code = result.code;
    if (code == null) {
      Carol.showTextSnackBar(text: 'Data is empty');
      return false;
    }
    try {
      SimpleStampCardQr.fromJson(json.decode(code));
    } catch (e) {
      Carol.showTextSnackBar(text: 'Not valid QR');
      return false;
    }

    return true;
  }
}
