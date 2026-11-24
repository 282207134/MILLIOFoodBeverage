import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../core/session.dart';
import '../core/ui.dart';
import 'shop.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.session;
    final options = [
      (
        'Preferences',
        Icons.settings_outlined,
        const Color(0xffc59e18),
        () => _preferences(context),
      ),
      (
        'Payment',
        Icons.credit_card_outlined,
        const Color(0xff219bbb),
        () => context.open(Screen.payment),
      ),
      ('Wishlist', Icons.favorite_border, purple, () => _wishlist(context)),
      (
        'Addresses',
        Icons.location_on_outlined,
        const Color(0xffd58152),
        () => context.open(Screen.address),
      ),
      (
        'Privacy Setting',
        Icons.privacy_tip_outlined,
        const Color(0xff25ae76),
        () => _privacy(context),
      ),
      (
        'Change Password',
        Icons.lock_outline,
        const Color(0xff6351d9),
        () {
          session.update(() => session.recovery = false);
          context.open(Screen.newPassword);
        },
      ),
      (
        'Sign Out',
        Icons.logout,
        const Color(0xffdf5c58),
        () => _signOut(context),
      ),
    ];
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: statusOverlay(context.dark),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Expanded(
                    child: listBody([
                      Stack(
                        children: [
                          Container(
                            height: 144,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: context.dark
                                  ? context.softGreen
                                  : const Color(0xffd0ecbf),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.elliptical(75, 30),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              gutter,
                              13,
                              gutter,
                              0,
                            ),
                            child: Column(
                              children: [
                                PageHeader(
                                  'Account',
                                  back: Navigator.of(context).canPop(),
                                  actions: [
                                    RoundIcon(
                                      Icons.notifications_outlined,
                                      tip: 'Notifications',
                                      onTap: () =>
                                          context.open(Screen.notifications),
                                      background: context.canvas,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                InkWell(
                                  onTap: () => context.open(Screen.editProfile),
                                  borderRadius: BorderRadius.circular(55),
                                  child: const ClipOval(
                                    child: Art('avatar', width: 77),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => context.open(Screen.editProfile),
                                  child: heading(
                                    session.profile['Full Name']!,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                label(
                                  session.profile['Email']!,
                                  color: context.muted,
                                  size: 11,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 23),
                      for (final (name, icon, color, onTap) in options)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: gutter,
                          ),
                          child: ListTile(
                            dense: true,
                            minTileHeight: 53,
                            contentPadding: EdgeInsets.zero,
                            onTap: onTap,
                            leading: CircleAvatar(
                              radius: 17,
                              backgroundColor: color.withValues(alpha: .18),
                              child: Icon(icon, color: color, size: 17),
                            ),
                            title: heading(name, size: 12),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: context.muted,
                              size: 17,
                            ),
                          ),
                        ),
                    ]),
                  ),
                  const BottomNav(Screen.account),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _preferences(BuildContext context) {
    final session = context.session;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (dialog) => SafeArea(
        child: ListenableBuilder(
          listenable: session,
          builder: (context, _) => Padding(
            padding: const EdgeInsets.fromLTRB(gutter, 0, gutter, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Preferences', size: 20),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: label('Dark mode', size: 14),
                  value: session.dark,
                  onChanged: (value) =>
                      session.update(() => session.dark = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _privacy(BuildContext context) {
    final session = context.session;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (dialog) => SafeArea(
        child: ListenableBuilder(
          listenable: session,
          builder: (context, _) => Padding(
            padding: const EdgeInsets.fromLTRB(gutter, 0, gutter, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Privacy Setting', size: 20),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: label('Allow push notifications', size: 14),
                  value: session.privacy,
                  onChanged: (value) =>
                      session.update(() => session.privacy = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _wishlist(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .63,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(gutter, 0, gutter, 20),
            child: listBody([
              heading('Wishlist', size: 20),
              const SizedBox(height: 15),
              if (context.session.favorites.isEmpty)
                label(
                  'Save a dish using the heart button on its product page.',
                  color: context.muted,
                )
              else
                FoodGrid(context.session.favorites.toList()),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('End this demo session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.session.signOut();
      context.root(Screen.signIn);
    }
  }
}

const _notifications = [
  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod',
  'Tellus cras adipiscing enim eu turpis egestas pretium. Volutpat blandit',
  'Tortor id aliquet lectus proin. Purus gravida quis blandit turpis cursus',
  'Sed cras ornare arcu dui vivamus arcu felis bibendum ut',
  'Ac tortor dignissim convallis aenean et tortor at. At augue eget arcu dictum',
  'Nisi vitae suscipit tellus mauris. Vitae auctor eu augue ut lectus arcu bibendum at',
];

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key, required this.selecting});
  final bool selecting;

  @override
  Widget build(BuildContext context) {
    final session = context.session;
    return PageFrame(
      title: 'Notification',
      actions: [
        RoundIcon(
          Icons.more_horiz,
          tip: selecting ? 'Select all' : 'Select notifications',
          onTap: () {
            if (selecting) {
              session.update(
                () => session.notificationSelection.addAll(
                  List.generate(_notifications.length, (index) => index),
                ),
              );
            } else {
              context.open(Screen.markNotifications);
            }
          },
        ),
      ],
      body: listBody([
        for (var i = 0; i < _notifications.length; i++)
          Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                minTileHeight: 75,
                onTap: selecting
                    ? () => session.update(() {
                        if (!session.notificationSelection.add(i)) {
                          session.notificationSelection.remove(i);
                        }
                      })
                    : null,
                leading: CircleAvatar(
                  backgroundColor: context.softGreen,
                  radius: 22,
                  child: Icon(
                    i == 0 ? Icons.group_outlined : Icons.notifications_none,
                    size: 20,
                    color: const Color(0xff5f9260),
                  ),
                ),
                title: label(
                  _notifications[i],
                  size: 11,
                  color: session.readNotifications.contains(i)
                      ? context.muted
                      : context.ink,
                  weight: FontWeight.w600,
                ),
                subtitle: label('2 hour ago', size: 9, color: context.muted),
                trailing: selecting
                    ? Icon(
                        session.notificationSelection.contains(i)
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        size: 17,
                        color: green,
                      )
                    : !session.readNotifications.contains(i)
                    ? const Icon(Icons.circle, color: Colors.redAccent, size: 7)
                    : null,
              ),
              Divider(height: 1, color: context.line),
            ],
          ),
      ]),
      bottom: selecting
          ? PrimaryButton('Mark As Read', () {
              session.update(() {
                session.readNotifications.addAll(session.notificationSelection);
                session.notificationSelection.clear();
              });
              Navigator.of(context).maybePop();
            })
          : null,
    );
  }
}
