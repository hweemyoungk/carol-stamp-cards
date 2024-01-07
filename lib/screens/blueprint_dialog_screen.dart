import 'package:carol/apis.dart' as apis;
import 'package:carol/data/dummy_data.dart';
import 'package:carol/main.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/user.dart';
import 'package:carol/providers/entity_provider.dart';
import 'package:carol/providers/stamp_card_provider.dart';
import 'package:carol/providers/stamp_cards_provider.dart';
import 'package:carol/providers/store_provider.dart';
import 'package:carol/screens/owner_design_blueprint_screen.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class BlueprintDialogScreen extends ConsumerStatefulWidget {
  const BlueprintDialogScreen({
    super.key,
    required this.blueprintProvider,
    required this.blueprintDialogMode,
  });

  final StateNotifierProvider<EntityStateNotifier<StampCardBlueprint>,
      StampCardBlueprint> blueprintProvider;
  final BlueprintDialogMode blueprintDialogMode;

  @override
  ConsumerState<BlueprintDialogScreen> createState() =>
      _BlueprintDialogScreenState();
}

class _BlueprintDialogScreenState extends ConsumerState<BlueprintDialogScreen> {
  final List<Widget> _alertRows = [];
  Widget? _unissuableAlerts;
  late Widget _issueButton;
  late TextFormField cardNameTextField;

  _IssueStatus _issueStatus = _IssueStatus.checkingIssuability;
  bool _isFetchingRedeemRules = false;

  @override
  Widget build(BuildContext context) {
    final blueprint = ref.watch(widget.blueprintProvider);

    Widget image = blueprint.bgImageUrl == null
        ? Image.memory(
            kTransparentImage,
            fit: BoxFit.contain,
          )
        : Image.asset(
            blueprint.bgImageUrl!,
            fit: BoxFit.contain,
          );
    final backButton = TextButton(
      style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.background),
      onPressed: _onPressBack,
      child: Text(
        'Back',
        textAlign: TextAlign.end,
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      ),
    );
    final dialogTitle = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(blueprint.displayName),
        if (!blueprint.isPublishing) const Icon(Icons.visibility_off),
      ],
    );

    if (widget.blueprintDialogMode == BlueprintDialogMode.customer) {
      // Customer mode
      if (_issueStatus == _IssueStatus.checkingIssuability) {
        _checkIssuable(
          user: currentUser,
          blueprint: blueprint,
        );
      }
      _setIssueButton();
      _unissuableAlerts = _issueStatus == _IssueStatus.checkingIssuability ||
              _issueStatus == _IssueStatus.issuable
          ? null
          : Column(children: _alertRows);
      cardNameTextField = TextFormField(
        controller: TextEditingController(text: blueprint.displayName),
        enabled: _issueStatus == _IssueStatus.issuable,
        decoration: InputDecoration(
          labelText: 'Card Name',
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        // initialValue: blueprint.displayName,
        style: const TextStyle(fontSize: 24),
      );
      return AlertDialog(
        title: dialogTitle,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              image,
              Padding(
                padding: Utils.basicWidgetEdgeInsets(),
                child: Text(
                  blueprint.description,
                ),
              ),
              Padding(
                padding: Utils.basicWidgetEdgeInsets(),
                child: Text(
                  'Stamp Grant Conditions',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary),
                ),
              ),
              Padding(
                padding: Utils.basicWidgetEdgeInsets(),
                child: Text(blueprint.stampGrantCondDescription),
              ),
              Padding(
                padding: Utils.basicWidgetEdgeInsets(),
                child: cardNameTextField,
              ),
              if (_unissuableAlerts != null) _unissuableAlerts!,
              backButton,
              _issueButton,
            ],
          ),
        ),
      );
    } else {
      // Owner mode
      return AlertDialog(
        title: dialogTitle,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              image,
              Padding(
                padding: Utils.basicWidgetEdgeInsets(),
                child: Text(
                  blueprint.description,
                ),
              ),
              Padding(
                padding: Utils.basicWidgetEdgeInsets(),
                child: Text(
                  'Stamp Grant Conditions',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary),
                ),
              ),
              Padding(
                padding: Utils.basicWidgetEdgeInsets(),
                child: Text(blueprint.stampGrantCondDescription),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                  disabledBackgroundColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                ),
                onPressed: _isFetchingRedeemRules ? null : _onPressModify,
                child: _isFetchingRedeemRules
                    ? SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                      )
                    : Text(
                        'Modify',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer),
                      ),
              ),
              backButton,
            ],
          ),
        ),
      );
    }
  }

  void _setIssueButton() {
    if (_issueStatus == _IssueStatus.checkingIssuability ||
        _issueStatus == _IssueStatus.issuing) {
      _issueButton = ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor:
              Theme.of(context).colorScheme.tertiaryContainer,
        ),
        child: SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
      );
    } else if (_issueStatus == _IssueStatus.notIssuable) {
      _issueButton = ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
            disabledBackgroundColor:
                Theme.of(context).colorScheme.errorContainer),
        child: Text(
          'Cannot issue this card!',
          style:
              TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
        ),
      );
    } else if (_issueStatus == _IssueStatus.issuable) {
      _issueButton = ElevatedButton(
        onPressed: _onPressIssue,
        child: const Text('Get this card'),
      );
    } else if (_issueStatus == _IssueStatus.issueFailed) {
      _issueButton = ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Theme.of(context).colorScheme.error,
        ),
        child: Icon(
          Icons.done,
          color: Theme.of(context).colorScheme.onError,
        ),
      );
    } else if (_issueStatus == _IssueStatus.issueSuccessful) {
      _issueButton = ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Theme.of(context).colorScheme.primary,
        ),
        child: Icon(
          Icons.done,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }
  }

  Future<void> _checkIssuable({
    required User user,
    required StampCardBlueprint blueprint,
  }) async {
    if (mounted) {
      setState(() {
        _alertRows.clear();
      });
    }

    // Check publishing (Very unlikely to happen)
    if (!blueprint.isPublishing) {
      if (mounted) {
        setState(() {
          _issueStatus = _IssueStatus.notIssuable;
          _alertRows.add(
            const AlertRow(text: 'Currently not publishing'),
          );
        });
      }
    }

    // Check max issues
    Future<bool> numMaxIssuesTask = blueprint.numMaxIssues == 0
        ? Future.value(false)
        : _violatedNumMaxIssues(
            user: user,
            blueprint: blueprint,
          ).then((violated) {
            if (violated) {
              if (mounted) {
                setState(() {
                  _issueStatus = _IssueStatus.notIssuable;
                  // _isIssuable = false;
                  _alertRows.add(
                    const AlertRow(text: 'Exceeded max number of issues'),
                  );
                });
              }
            }
            return violated;
          });

    // Assume another check
    Future<bool> veryLongTask = Utils.delaySeconds(5).then((value) {
      if (random.nextDouble() < 0.9) {
        return false;
      }
      if (mounted) {
        setState(() {
          _issueStatus = _IssueStatus.notIssuable;
          // _isIssuable = false;
          _alertRows.add(
            const AlertRow(text: 'Violated very long check task'),
          );
        });
      }
      return true;
    });

    final tasks = [
      numMaxIssuesTask,
      veryLongTask,
    ];
    final violations = await Future.wait(tasks);
    if (violations.every((violated) => !violated)) {
      if (mounted) {
        setState(() {
          _issueStatus = _IssueStatus.issuable;
          // _isIssuable = true;
        });
      }
    }
  }

  Future<bool> _violatedNumMaxIssues({
    required User user,
    required StampCardBlueprint blueprint,
  }) async {
    final numIssuedCards = await _getNumIssuedCards(
      userId: user.id,
      blueprintId: blueprint.id,
    );
    return blueprint.numMaxIssues <= numIssuedCards;
  }

  Future<int> _getNumIssuedCards({
    required String userId,
    required String blueprintId,
  }) async {
    // TODO replace with http
    await Utils.delaySeconds(2);
    return random.nextInt(3);
  }

  void _onPressIssue() async {
    final blueprint = ref.read(widget.blueprintProvider);
    if (mounted) {
      setState(() {
        _issueStatus = _IssueStatus.issuing;
        // _issuing = true;
      });
    }
    final newStampCard = await issueCard(
      user: currentUser,
      blueprint: blueprint,
    );
    if (newStampCard == null) {
      // failed
      if (mounted) {
        setState(() {
          _issueStatus = _IssueStatus.issueFailed;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _issueStatus = _IssueStatus.issueSuccessful;
        });
      }
    }
    await Utils.delaySeconds(1);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<StampCard?> issueCard({
    required User user,
    required StampCardBlueprint blueprint,
  }) async {
    final stampCardsNotifier = ref.read(stampCardsProvider.notifier);
    // TODO post stampCard and receive location
    final stampCardDisplayName = cardNameTextField.controller!.text;
    await Utils.delaySeconds(1);
    final String newStampCardId = uuid.v4();

    // TODO get stampCard
    await Utils.delaySeconds(1);
    final newStampCard = StampCard(
      id: newStampCardId,
      customerId: user.id,
      displayName: stampCardDisplayName,
      expirationDate: blueprint.expirationDate,
      isFavorite: false,
      lastModifiedDate: DateTime.now(),
      numCollectedStamps: 0,
      numMaxStamps: blueprint.numMaxStamps,
      numGoalStamps: blueprint.numMaxStamps,
      numRedeemed: 0,
      numMaxRedeems: blueprint.numMaxRedeems,
      storeId: blueprint.storeId,
      blueprintId: blueprint.id,
      wasDiscarded: false,
      wasUsedOut: false,
      isInactive: false,
      bgImageUrl: blueprint.bgImageUrl,
      icon: blueprint.icon,
    );
    stampCardProviders.tryAddProvider(entity: newStampCard);
    stampCardsNotifier.prepend(newStampCard, sort: false);

    Carol.showTextSnackBar(text: 'Your stamp card is ready!');
    return newStampCard;
  }

  void _onPressBack() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _onPressModify() async {
    var blueprint = ref.read(widget.blueprintProvider);
    final blueprintNotifier = ref.read(widget.blueprintProvider.notifier);
    // Set _redeemRules
    if (blueprint.redeemRules == null) {
      setState(() {
        _isFetchingRedeemRules = true;
      });
      // TODO Fetch redeemRules
      // Await: Fetch redeemRules first
      // apis.listRedeemRules(blueprintId: blueprint.id);
      await apis.listDummyRedeemRules(blueprint: blueprint).then((value) {
        final fetchedBlueprint = blueprint.copyWith(redeemRules: value);
        blueprintNotifier.set(entity: fetchedBlueprint);
        blueprint = fetchedBlueprint;
      });
      if (mounted) {
        setState(() {
          _isFetchingRedeemRules = false;
        });
      }
    }
    if (mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          final storeProvider =
              ownerStoreProviders.tryGetProviderById(id: blueprint.storeId)!;
          blueprint.storeId;
          ownerStoreProviders;
          return OwnerDesignBlueprintScreen(
            designMode: BlueprintDesignMode.modify,
            storeProvider: storeProvider,
            blueprint: blueprint,
          );
        },
      ));
    }
  }
}

class AlertRow extends StatelessWidget {
  const AlertRow({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.errorContainer,
          ),
        ),
        Text(text),
      ],
    );
  }
}

enum _IssueStatus {
  checkingIssuability,
  notIssuable,
  issuable,
  issuing,
  issueFailed,
  issueSuccessful,
}

enum BlueprintDialogMode {
  customer,
  owner,
}
