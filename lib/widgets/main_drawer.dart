import 'package:carol/widgets/common/language_dropdown_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/params/backend.dart' as backend_params;
import 'package:carol/providers/active_drawer_item_notifier.dart';
import 'package:carol/providers/active_locale_notifier.dart';
import 'package:carol/screens/account_dialog_screen.dart';
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/customer_screen.dart';
import 'package:carol/screens/owner_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/common/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final activeDrawerItemProvider =
    StateNotifierProvider<ActiveDrawerItemNotifier, DrawerItemEnum>(
        (ref) => ActiveDrawerItemNotifier());
final activeLocaleProvider =
    StateNotifierProvider<ActiveLocaleNotifier, Locale>(
        (ref) => ActiveLocaleNotifier());

class MainDrawer extends ConsumerStatefulWidget {
  const MainDrawer({
    super.key,
  });

  @override
  ConsumerState<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends ConsumerState<MainDrawer> {
  late AppLocalizations _localizations;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);
    final localizations = AppLocalizations.of(context)!;
    if (currentUser == null) {
      // Can happen when signed out
      return Loading(
        message: _localizations.loadingUser,
      );
    }

    // Skip
    // final avatar = ClipRRect(
    //   borderRadius: BorderRadius.circular(25.0),
    //   child: currentUser.profileImageUrl == null
    //       ? Stack(
    //           children: [
    //             Image.memory(
    //               kTransparentImage,
    //               height: 50,
    //               width: 50,
    //               fit: BoxFit.cover,
    //             ),
    //             Positioned.fill(
    //               child: Align(
    //                 alignment: Alignment.center,
    //                 child: Text(
    //                   _localizations.noImage,
    //                   style: const TextStyle(
    //                     fontStyle: FontStyle.italic,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         )
    //       : Image.asset(
    //           currentUser.profileImageUrl!,
    //           height: 50,
    //           width: 50,
    //           fit: BoxFit.cover,
    //         ),
    // );
    // final profileIcon = Padding(
    //   padding: DesignUtils.basicWidgetEdgeInsets(),
    //   child: avatar,
    // );
    return Drawer(
      width: 250,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          DrawerHeader(
            child: TextButton(
              onPressed: () {
                // ref
                //     .read(activeDrawerItemProvider.notifier)
                //     .set(DrawerItemEnum.account);
                showDialog(
                  context: context,
                  builder: (ctx) {
                    return const AccountDialogScreen();
                  },
                );
              },
              child: Row(
                children: [
                  // profileIcon,
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      currentUser.displayName,
                      style:
                          Theme.of(context).textTheme.headlineLarge!.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DrawerItem(
                      text: localizations.customer,
                      drawerItemEnum: DrawerItemEnum.customer),
                  DrawerItem(
                    text: localizations.owner,
                    drawerItemEnum: DrawerItemEnum.owner,
                  ),
                  DrawerItem(
                    text: localizations.membership,
                    drawerItemEnum: DrawerItemEnum.membership,
                  ),
                  // Skip in phase 3
                  // DrawerItem(
                  //   text: 'Settings',
                  //   drawerItemEnum: DrawerItemEnum.settings,
                  // ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DrawerItem(
                    text: localizations.privacyPolicy,
                    drawerItemEnum: DrawerItemEnum.privacyPolicy,
                    onTap: _onTapPrivacyPolicy,
                  ),
                ],
              ),
              LanguageDropdownButton(
                textColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onTapPrivacyPolicy() async {
    final url = Uri.https(
      backend_params.appGateway,
      backend_params.publicPrivacyPolicyPath,
    );
    await launchInBrowserView(url);
  }
}

class LocaleDropdownMenuItem extends DropdownMenuItem {
  final SupportedLanguage language;

  LocaleDropdownMenuItem(this.language, {super.key})
      : super(
          value: language,
          child: Text(
            language.language,
          ),
        );
}

class DrawerItem extends ConsumerStatefulWidget {
  const DrawerItem({
    super.key,
    required this.text,
    required this.drawerItemEnum,
    this.onTap,
  });
  final String text;
  final DrawerItemEnum drawerItemEnum;
  final void Function()? onTap;

  @override
  ConsumerState<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends ConsumerState<DrawerItem> {
  late AppLocalizations _localizations;

  @override
  Widget build(BuildContext context) {
    _localizations = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: widget.onTap ??
          () {
            ref
                .read(activeDrawerItemProvider.notifier)
                .set(widget.drawerItemEnum);
            _initLoadEntities();
            Navigator.of(context).pop();
          },
      child: Padding(
        padding: DesignUtils.basicWidgetEdgeInsets(),
        child: Text(
          widget.text,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ),
    );
  }

  void _initLoadEntities() {
    if (widget.drawerItemEnum == DrawerItemEnum.customer) {
      if (isCustomerModelsInitLoaded(ref)) return;

      customer_apis.reloadCustomerModels(ref).onError(
        (error, stackTrace) {
          if (error is Exception) {
            Carol.showExceptionSnackBar(
              error,
              contextMessage: _localizations.failedToLoadCustomerModels,
              localizations: _localizations,
            );
          }
        },
      );
    } else if (widget.drawerItemEnum == DrawerItemEnum.owner) {
      if (isOwnerModelsInitLoaded(ref)) return;

      owner_apis.reloadOwnerModels(ref).onError(
        (error, stackTrace) {
          if (error is Exception) {
            Carol.showExceptionSnackBar(
              error,
              contextMessage: _localizations.failedToLoadOwnerModels,
              localizations: _localizations,
            );
          }
        },
      );
    } else if (widget.drawerItemEnum == DrawerItemEnum.membership) {
      // NOOP: contents are loaded from access token
    }
  }
}

enum DrawerItemEnum {
  customer,
  owner,
  membership,
  settings,
  termsOfUse,
  privacyPolicy,
}

enum SupportedLanguage {
  en(languageCode: 'en', language: 'English'),
  ko(languageCode: 'ko', language: '한국어'),
  ;

  final String languageCode;
  final String language;

  const SupportedLanguage({
    required this.languageCode,
    required this.language,
  });
}
