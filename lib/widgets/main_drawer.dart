import 'package:carol/apis/customer_apis.dart' as customer_apis;
import 'package:carol/apis/owner_apis.dart' as owner_apis;
import 'package:carol/apis/utils.dart';
import 'package:carol/main.dart';
import 'package:carol/params/auth.dart';
import 'package:carol/providers/active_drawer_item_notifier.dart';
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/screens/customer_screen.dart';
import 'package:carol/screens/owner_screen.dart';
import 'package:carol/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

final activeDrawerItemProvider =
    StateNotifierProvider<ActiveDrawerItemNotifier, DrawerItemEnum>(
        (ref) => ActiveDrawerItemNotifier());

class MainDrawer extends ConsumerWidget {
  const MainDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider)!;
    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: currentUser.profileImageUrl == null
          ? Stack(
              children: [
                Image.memory(
                  kTransparentImage,
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
                const Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'No Image',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Image.asset(
              currentUser.profileImageUrl!,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
    );
    final profileIcon = Padding(
      padding: DesignUtils.basicWidgetEdgeInsets(),
      child: avatar,
    );
    return Drawer(
      width: 250,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        children: [
          DrawerHeader(
            child: TextButton(
              onPressed: _onPressAccount,
              child: Row(
                children: [
                  profileIcon,
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
          const Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DrawerItem(
                      text: 'Customer',
                      drawerItemEnum: DrawerItemEnum.customer),
                  DrawerItem(
                    text: 'Owner',
                    drawerItemEnum: DrawerItemEnum.owner,
                  ),
                  DrawerItem(
                    text: 'Membership',
                    drawerItemEnum: DrawerItemEnum.membership,
                  ),
                  DrawerItem(
                    text: 'Settings',
                    drawerItemEnum: DrawerItemEnum.settings,
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DrawerItem(
                    text: 'Terms of Use',
                    drawerItemEnum: DrawerItemEnum.termsOfUse,
                  ),
                  DrawerItem(
                    text: 'Privacy Policy',
                    drawerItemEnum: DrawerItemEnum.privacyPolicy,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onPressAccount() async {
    // final url = Uri.http(keycloakHostname, accountPath);
    final url = Uri.https(keycloakHostname, accountPath);
    await launchInBrowserView(url);
  }
}

class DrawerItem extends ConsumerStatefulWidget {
  const DrawerItem({
    super.key,
    required this.text,
    required this.drawerItemEnum,
  });
  final String text;
  final DrawerItemEnum drawerItemEnum;

  @override
  ConsumerState<DrawerItem> createState() => _DrawerItemState();
}

class _DrawerItemState extends ConsumerState<DrawerItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ref.read(activeDrawerItemProvider.notifier).set(widget.drawerItemEnum);
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
              contextMessage: 'Failed to load customer models.',
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
              contextMessage: 'Failed to load owner models.',
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
  ;
}
