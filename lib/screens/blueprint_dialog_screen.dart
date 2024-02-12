import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/main.dart';
import 'package:carol/models/redeem_rule.dart';
import 'package:carol/models/stamp_card.dart';
import 'package:carol/models/stamp_card_blueprint.dart';
import 'package:carol/models/user.dart';
import 'package:carol/providers/blueprint_notifier.dart';
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/owner_design_blueprint_screen.dart';
import 'package:carol/screens/store_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/blueprint/blueprint_info.dart';
import 'package:carol/widgets/cards_explorer/cards_list.dart';
import 'package:carol/widgets/common/loading.dart';
import 'package:carol/widgets/stores_explorer/stores_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerBlueprintDialogScreenBlueprintProvider =
    StateNotifierProvider<BlueprintNotifier, Blueprint?>(
        (ref) => BlueprintNotifier(null));
final ownerBlueprintDialogScreenBlueprintProvider =
    StateNotifierProvider<BlueprintNotifier, Blueprint?>(
        (ref) => BlueprintNotifier(null));

class BlueprintDialogScreen extends ConsumerStatefulWidget {
  final BlueprintDialogMode blueprintDialogMode;
  const BlueprintDialogScreen({
    super.key,
    required this.blueprintDialogMode,
  });

  @override
  ConsumerState<BlueprintDialogScreen> createState() =>
      _BlueprintDialogScreenState();
}

class _BlueprintDialogScreenState extends ConsumerState<BlueprintDialogScreen> {
  final List<Widget> _alertRows = [];
  Widget? _unissuableAlerts;
  late Widget _issueButton;
  late TextFormField _cardNameTextField;

  _IssueStatus _issueStatus = _IssueStatus.checkingIssuability;

  Blueprint? _watchBlueprint() {
    if (widget.blueprintDialogMode == BlueprintDialogMode.customer) {
      return ref.watch(customerBlueprintDialogScreenBlueprintProvider);
    }
    return ref.watch(ownerBlueprintDialogScreenBlueprintProvider);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider)!;
    final blueprint = _watchBlueprint();
    if (blueprint == null) {
      return const Loading(message: 'Loading Blueprint...');
    }

    final blueprintInfo = BlueprintInfo(
      blueprint: blueprint,
      textColor: Theme.of(context).colorScheme.onSecondary,
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

      _cardNameTextField = TextFormField(
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
              blueprintInfo,
              Padding(
                padding: DesignUtils.basicWidgetEdgeInsets(),
                child: _cardNameTextField,
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
      final modifyButton = _getModifyButton(blueprint);
      return AlertDialog(
        title: dialogTitle,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              blueprintInfo,
              if (modifyButton != null) modifyButton,
              backButton,
            ],
          ),
        ),
      );
    }
  }

  /// (Owner only) Generate <code>ElevatedButton</code> if blueprint's store is active.
  ElevatedButton? _getModifyButton(Blueprint blueprint) {
    if (blueprint.store == null || blueprint.store!.isInactive) {
      return null;
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
      ),
      onPressed: _onPressModify,
      child: Text(
        'Modify',
        textAlign: TextAlign.end,
        style:
            TextStyle(color: Theme.of(context).colorScheme.onTertiaryContainer),
      ),
    );
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
    required Blueprint blueprint,
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

    // Check max issues per customer
    Future<bool> numMaxIssuesPerCustomerTask;
    if (blueprint.numMaxIssuesPerCustomer == 0) {
      numMaxIssuesPerCustomerTask = Future.value(false);
    } else {
      numMaxIssuesPerCustomerTask = _violatedNumMaxIssuesPerCustomer(
        user: user,
        blueprint: blueprint,
      ).then((violated) {
        if (violated) {
          if (mounted) {
            setState(() {
              _issueStatus = _IssueStatus.notIssuable;
              _alertRows.add(
                const AlertRow(
                    text: 'Exceeded max number of issues per customer.'),
              );
            });
          }
        }
        return violated;
      }).onError((error, stackTrace) {
        if (error is Exception) {
          Carol.showExceptionSnackBar(
            error,
            contextMessage:
                'Failed to get number of issued cards per customer.',
          );
        }
        if (mounted) {
          setState(() {
            _issueStatus = _IssueStatus.notIssuable;
            _alertRows.add(
              const AlertRow(
                  text: 'Failed to get number of issued cards per customer.'),
            );
          });
        }
        return true;
      });
    }

    // Check max total issues
    Future<bool> numMaxTotalIssuesTask = _violatedNumMaxTotalIssues(
      blueprint: blueprint,
    ).then((violated) {
      if (violated) {
        if (mounted) {
          setState(() {
            _issueStatus = _IssueStatus.notIssuable;
            _alertRows.add(
              const AlertRow(text: 'Exceeded max total number of issues.'),
            );
          });
        }
      }
      return violated;
    }).onError((error, stackTrace) {
      if (error is Exception) {
        Carol.showExceptionSnackBar(
          error,
          contextMessage: 'Failed to get total number of issued cards.',
        );
      }
      if (mounted) {
        setState(() {
          _issueStatus = _IssueStatus.notIssuable;
          _alertRows.add(
            const AlertRow(text: 'Failed to get total number of issued cards.'),
          );
        });
      }
      return true;
    });

    final tasks = [
      numMaxIssuesPerCustomerTask,
      numMaxTotalIssuesTask,
    ];
    final violations = await Future.wait(tasks);
    if (violations.every((violated) => !violated)) {
      if (mounted) {
        setState(() {
          _issueStatus = _IssueStatus.issuable;
        });
      }
    }
  }

  Future<bool> _violatedNumMaxIssuesPerCustomer({
    required User user,
    required Blueprint blueprint,
  }) async {
    final numCustomerIssuedCards =
        await customer_apis.getNumCustomerIssuedCards(
      customerId: user.id,
      blueprintId: blueprint.id,
    );
    return blueprint.numMaxIssuesPerCustomer <= numCustomerIssuedCards;
  }

  Future<bool> _violatedNumMaxTotalIssues({
    required Blueprint blueprint,
  }) async {
    final numTotalIssuedCards = await customer_apis.getNumTotalIssuedCards(
      blueprintId: blueprint.id,
    );
    // 0: Infinite
    return blueprint.numMaxIssues != 0 &&
        blueprint.numMaxIssues <= numTotalIssuedCards;
  }

  void _onPressIssue() async {
    final currentUser = ref.read(currentUserProvider)!;
    final blueprint = ref.read(customerBlueprintDialogScreenBlueprintProvider);
    if (blueprint == null) return;

    setState(() {
      _issueStatus = _IssueStatus.issuing;
    });
    final newStampCard = await issueCard(
      user: currentUser,
      blueprint: blueprint,
    );

    if (newStampCard != null) {
      Carol.showTextSnackBar(
        text: 'Your card is ready!',
        level: SnackBarLevel.success,
      );
    } else {
      Carol.showTextSnackBar(
        text: 'Failed to issue card.',
        level: SnackBarLevel.error,
      );
    }

    if (!mounted) return;
    setState(() {
      _issueStatus = newStampCard == null
          ? _IssueStatus.issueFailed
          : _IssueStatus.issueSuccessful;
    });
    Navigator.of(context).pop();
  }

  Future<StampCard?> issueCard({
    required User user,
    required Blueprint blueprint,
  }) async {
    final customerCardsNotifier =
        ref.read(customerCardsListCardsProvider.notifier);

    // Post StampCard and receive location
    final stampCardDisplayName = _cardNameTextField.controller!.text;
    final stampCardToPost = StampCard.fromBlueprint(
      id: -1,
      customerId: user.id,
      blueprint: blueprint,
    ).copyWith(displayName: stampCardDisplayName);

    final int newStampCardId;
    try {
      newStampCardId =
          await customer_apis.postStampCard(stampCard: stampCardToPost);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to save new card.',
      );
      return null;
    }

    // Get StampCard
    final StampCard newCard;
    try {
      newCard = await customer_apis.getStampCard(id: newStampCardId);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to get newly created stamp card information.',
      );
      return null;
    }
    customerCardsNotifier.prepend(newCard);

    return newCard;
  }

  void _onPressBack() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _onPressModify() async {
    final storesNotifier = ref.read(ownerStoresListStoresProvider.notifier);
    final storeNotifier = ref.read(ownerStoreScreenStoreProvider.notifier);
    final blueprintNotifier =
        ref.read(ownerBlueprintDialogScreenBlueprintProvider.notifier);
    final blueprint = ref.read(ownerBlueprintDialogScreenBlueprintProvider);
    if (blueprint == null) return;

    if (blueprint.redeemRules != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return OwnerDesignBlueprintScreen(
            key: ValueKey(blueprint.id),
            designMode: BlueprintDesignMode.modify,
            blueprint: blueprint,
          );
        },
      ));
      return;
    }

    // await fetch redeemRules
    final Set<RedeemRule> redeemRules;
    try {
      redeemRules = await owner_apis.listRedeemRules(blueprintId: blueprint.id);
    } on Exception catch (e) {
      Carol.showExceptionSnackBar(
        e,
        contextMessage: 'Failed to get redeem rules information.',
      );
      return;
    }
    final blueprintToRefresh = blueprint.copyWith(redeemRules: redeemRules);
    // Propagate
    // ownerBlueprintDialogScreenBlueprintProvider
    blueprintNotifier.set(blueprintToRefresh);

    // ownerStoreScreenStoreProvider
    // ownerStoresListStoresProvider
    if (blueprint.store?.blueprints != null) {
      final oldStore = blueprint.store!;
      final oldBlueprints = oldStore.blueprints!;
      final newBlueprints = oldBlueprints.map((oldBlueprint) {
        if (oldBlueprint.id == blueprintToRefresh.id) {
          return blueprintToRefresh;
        }
        return oldBlueprint;
      }).toSet();
      final storeToRefresh = oldStore.copyWith(blueprints: newBlueprints);
      storeNotifier.set(storeToRefresh);
      storesNotifier.replaceOrPrepend(storeToRefresh);
    }

    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return OwnerDesignBlueprintScreen(
          key: ValueKey(blueprint.id),
          designMode: BlueprintDesignMode.modify,
          blueprint: blueprintToRefresh,
        );
      },
    ));
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
