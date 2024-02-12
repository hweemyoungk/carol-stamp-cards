import 'package:carol/main.dart';
import 'package:carol/models/membership.dart';
import 'package:carol/screens/auth_screen.dart';
import 'package:carol/utils.dart';
import 'package:carol/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerMemberships = [
  Membership(
    requiredRole: 'customer-starter',
    isPublishing: true,
    isActive: false,
    displayName: 'Starter',
    descriptions: [
      'Unlimited active cards',
      'Ads included',
    ],
    colorScheme: colorScheme,
    iconData: Icons.credit_card,
    monthlyPrice: null,
  ),
  Membership(
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
  ),
];
final ownerMemberships = [
  Membership(
    requiredRole: 'owner-starter',
    isPublishing: true,
    isActive: false,
    displayName: 'Starter',
    descriptions: [
      '1 active store',
      '1 publishing blueprint',
      '2 redeem rules',
      'Ads included',
    ],
    colorScheme: colorScheme,
    iconData: Icons.house,
    monthlyPrice: null,
  ),
  Membership(
    requiredRole: 'owner-premium',
    isPublishing: false,
    isActive: false,
    displayName: 'Premium',
    descriptions: [
      '2 active stores',
      '3 publishing blueprint per store',
      '5 redeem rules per blueprint',
      'Ads removed',
    ],
    colorScheme: colorScheme,
    iconData: Icons.store,
    monthlyPrice: '(Example) \$4.50',
  ),
  Membership(
    requiredRole: 'owner-business',
    isPublishing: false,
    isActive: false,
    displayName: 'Business',
    descriptions: [
      'Up to 5 active store',
      '5 publishing blueprint per store',
      '10 redeem rules per blueprint',
      'Ads removed',
    ],
    colorScheme: colorScheme,
    iconData: Icons.business,
    monthlyPrice: '(Example) \$9.90',
  ),
];

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
        return customerMemberships;
      case 1:
        return ownerMemberships;
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
