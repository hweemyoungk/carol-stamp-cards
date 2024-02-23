import 'package:carol/main.dart';
import 'package:carol/models/customer_membership.dart';
import 'package:carol/models/membership.dart';
import 'package:carol/models/owner_membership.dart';
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerMemberships = {
  'customer-alpha': CustomerMembership(
    priority: 1,
    requiredRole: 'customer-alpha',
    isPublishing: true,
    isActive: false,
    displayName: 'Alpha',
    descriptions: [
      'Unlimited active cards',
      'Ads included',
    ],
    colorScheme: colorScheme,
    iconData: Icons.credit_card,
    monthlyPrice: null,
    numMaxAccumulatedTotalCards: -1,
    numMaxCurrentTotalCards: -1,
    numMaxCurrentActiveCards: -1,
  ),
  'customer-premium': CustomerMembership(
    priority: 2,
    requiredRole: 'customer-premium',
    isPublishing: false,
    isActive: false,
    displayName: 'Premium',
    descriptions: [
      'Unlimited active cards',
      'Ads removed',
    ],
    colorScheme: colorScheme,
    iconData: Icons.credit_score,
    monthlyPrice: '(Example) \$0.99',
    numMaxAccumulatedTotalCards: -1,
    numMaxCurrentTotalCards: -1,
    numMaxCurrentActiveCards: -1,
  ),
};
final ownerMemberships = {
  'owner-alpha': OwnerMembership(
    priority: 1,
    requiredRole: 'owner-alpha',
    isPublishing: true,
    isActive: false,
    displayName: 'Alpha',
    descriptions: [
      '1 active (2 total) store',
      '3 publishing (3 total) blueprints per store',
      '3 redeem rules per blueprint',
      'Ads included',
    ],
    colorScheme: colorScheme,
    iconData: Icons.house,
    monthlyPrice: null,
    numMaxAccumulatedTotalStores: -1,
    numMaxCurrentTotalStores: 2,
    numMaxCurrentActiveStores: 1,
    numMaxCurrentTotalBlueprintsPerStore: 3,
    numMaxCurrentActiveBlueprintsPerStore: 3,
    numMaxCurrentTotalRedeemRulesPerBlueprint: 3,
    numMaxCurrentActiveRedeemRulesPerBlueprint: 3,
  ),
  'owner-premium': OwnerMembership(
    priority: 2,
    requiredRole: 'owner-premium',
    isPublishing: false,
    isActive: false,
    displayName: 'Premium',
    descriptions: [
      '2 active (4 total) stores',
      '3 publishing (5 total) blueprint per store',
      '5 redeem rules per blueprint',
      'Ads removed',
    ],
    colorScheme: colorScheme,
    iconData: Icons.store,
    monthlyPrice: '(Example) \$4.50',
    numMaxAccumulatedTotalStores: -1,
    numMaxCurrentTotalStores: 4,
    numMaxCurrentActiveStores: 2,
    numMaxCurrentTotalBlueprintsPerStore: 5,
    numMaxCurrentActiveBlueprintsPerStore: 3,
    numMaxCurrentTotalRedeemRulesPerBlueprint: 5,
    numMaxCurrentActiveRedeemRulesPerBlueprint: 5,
  ),
  'owner-business': OwnerMembership(
    priority: 3,
    requiredRole: 'owner-business',
    isPublishing: false,
    isActive: false,
    displayName: 'Business',
    descriptions: [
      'Unlimited stores, blueprints and redeem rules',
      'Ads removed',
    ],
    colorScheme: colorScheme,
    iconData: Icons.business,
    monthlyPrice: '(Contact us)',
    numMaxAccumulatedTotalStores: -1,
    numMaxCurrentTotalStores: -1,
    numMaxCurrentActiveStores: -1,
    numMaxCurrentTotalBlueprintsPerStore: -1,
    numMaxCurrentActiveBlueprintsPerStore: -1,
    numMaxCurrentTotalRedeemRulesPerBlueprint: -1,
    numMaxCurrentActiveRedeemRulesPerBlueprint: -1,
  ),
};

class MembershipScreen extends ConsumerStatefulWidget {
  const MembershipScreen({super.key});

  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen> {
  int _activeBottomItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider)!;
    final memberships =
        _getMemberships().map((e) => e.checkUserRole(currentUser)).toList();
    final membershipsList = ListView.builder(
      itemCount: memberships.length,
      itemBuilder: (ctx, index) {
        final membership = memberships[index];
        return MembershipsListItem(membership: membership);
      },
    );
    final String appBarTitleText = _getAppBarTitleText();
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitleText),
      ),
      drawer: const MainDrawer(),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _activeBottomItemIndex,
          onTap: _onTapBottomItem,
          items: const [
            BottomNavigationBarItem(
              label: 'Customer',
              icon: Icon(Icons.emoji_people),
            ),
            BottomNavigationBarItem(
              label: 'Owner',
              icon: Icon(Icons.store),
            ),
          ]),
      body: membershipsList,
    );
  }

  void _onTapBottomItem(int value) {
    setState(() {
      _activeBottomItemIndex = value;
    });
  }

  List<Membership> _getMemberships() {
    switch (_activeBottomItemIndex) {
      case 0:
        return customerMemberships.values.toList();
      case 1:
        return ownerMemberships.values.toList();
      default:
        return [];
    }
  }

  String _getAppBarTitleText() {
    switch (_activeBottomItemIndex) {
      case 0:
        return 'Customer Membership';
      case 1:
        return 'Owner Membership';
      default:
        return 'UNKNOWN';
    }
  }
}

class MembershipsListItem extends StatelessWidget {
  const MembershipsListItem({
    super.key,
    required this.membership,
  });

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: membership.bgColor,
      margin: DesignUtils.basicWidgetEdgeInsets(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.hardEdge,
      elevation: 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: DesignUtils.basicWidgetEdgeInsets(),
            child: Column(
              children: [
                if (!membership.isPublishing)
                  Row(
                    children: [
                      Text(
                        'Coming soon...',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: membership.onBgColor),
                      ),
                    ],
                  ),
                if (membership.isActive)
                  Row(
                    children: [
                      Text(
                        'You are now',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(color: membership.onBgColor),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Icon(
                      membership.iconData,
                      size: 44,
                      color: membership.onBgColor,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      membership.displayName,
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium!
                          .copyWith(color: membership.onBgColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: DesignUtils.basicWidgetEdgeInsets(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...membership.descriptions.map(
                  (e) => MembershipListItemDesc(
                    description: e,
                    onBgColor: membership.onBgColor,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: DesignUtils.basicWidgetEdgeInsets(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  membership.monthlyPrice == null
                      ? 'Free'
                      : '${membership.monthlyPrice}/month',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: membership.onBgColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MembershipListItemDesc extends StatelessWidget {
  const MembershipListItemDesc({
    super.key,
    required this.description,
    required this.onBgColor,
  });

  final String description;
  final Color onBgColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        Icon(
          Icons.add,
          color: onBgColor,
        ),
        const SizedBox(width: 4),
        Text(
          description,
          style: TextStyle(
            color: onBgColor,
          ),
        ),
      ],
    );
  }
}
