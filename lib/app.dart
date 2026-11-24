import 'package:flutter/material.dart';

import 'core/session.dart';
import 'core/ui.dart';
import 'features/account.dart';
import 'features/auth.dart';
import 'features/checkout.dart';
import 'features/shop.dart';

class MamamApp extends StatefulWidget {
  const MamamApp({
    super.key,
    this.initial = Screen.splash,
    this.session,
    this.holdSplash = false,
  });

  final Screen initial;
  final Session? session;
  final bool holdSplash;

  @override
  State<MamamApp> createState() => _MamamAppState();
}

class _MamamAppState extends State<MamamApp> {
  late final Session session = widget.session ?? Session();
  final lightTheme = mamamTheme(Brightness.light);
  final darkTheme = mamamTheme(Brightness.dark);

  @override
  void dispose() {
    if (widget.session == null) session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SessionScope(
    notifier: session,
    child: ListenableBuilder(
      listenable: session,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mamam Delivery',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: session.dark ? ThemeMode.dark : ThemeMode.light,
        home: ScreenView(widget.initial, holdSplash: widget.holdSplash),
      ),
    ),
  );
}

class SessionScope extends InheritedNotifier<Session> {
  const SessionScope({
    super.key,
    required super.notifier,
    required super.child,
  });
}

extension AppNavigation on BuildContext {
  Session get session =>
      dependOnInheritedWidgetOfExactType<SessionScope>()!.notifier!;

  Future<T?> open<T>(Screen screen, {Food? food}) =>
      Navigator.of(this).push<T>(_route<T>(screen, food: food));

  void replace(Screen screen) =>
      Navigator.of(this).pushReplacement(_route<void>(screen));

  void root(Screen screen) =>
      Navigator.of(this).pushAndRemoveUntil(_route<void>(screen), (_) => false);

  void close<T>([T? result]) => Navigator.of(this).pop(result);

  MaterialPageRoute<T> _route<T>(Screen screen, {Food? food}) =>
      MaterialPageRoute<T>(
        settings: RouteSettings(name: screen.name),
        builder: (_) => ScreenView(screen, food: food),
      );
}

class ScreenView extends StatelessWidget {
  const ScreenView(
    this.screen, {
    super.key,
    this.holdSplash = false,
    this.food,
  });
  final Screen screen;
  final bool holdSplash;
  final Food? food;

  @override
  Widget build(BuildContext context) => switch (screen) {
    Screen.splash => SplashView(hold: holdSplash),
    Screen.intro1 ||
    Screen.intro2 ||
    Screen.intro3 ||
    Screen.intro4 => IntroView(page: screen.index - Screen.intro1.index),
    Screen.signIn || Screen.signUp => AuthView(signUp: screen == Screen.signUp),
    Screen.verify ||
    Screen.verifyCode => VerificationView(filled: screen == Screen.verifyCode),
    Screen.forgot ||
    Screen.newPassword => PasswordView(reset: screen == Screen.newPassword),
    Screen.setupProfile ||
    Screen.editProfile => ProfileForm(edit: screen == Screen.editProfile),
    Screen.initialLocation || Screen.setLocation => LocationView(
      initial: screen == Screen.initialLocation,
    ),
    Screen.home => const HomeView(),
    Screen.categories => const CategoriesView(),
    Screen.deal => const DealView(),
    Screen.offers => const OffersView(),
    Screen.product => ProductView(food: food ?? foods[4]),
    Screen.description => const DescriptionView(),
    Screen.reviews => ReviewsView(food: food ?? foods[4]),
    Screen.addReview => AddReviewView(food: food ?? foods[4]),
    Screen.chat => const ChatView(),
    Screen.cartEmpty ||
    Screen.cart ||
    Screen.checkout => CartView(checkout: screen == Screen.checkout),
    Screen.voucher ||
    Screen.address ||
    Screen.payment => CheckoutOptions(screen: screen),
    Screen.addAddress => const AddAddressView(),
    Screen.addCard => const AddCardView(),
    Screen.tracking => const TrackingView(),
    Screen.scan => const ScanView(),
    Screen.success => const SuccessView(),
    Screen.account => const AccountView(),
    Screen.notifications || Screen.markNotifications => NotificationsView(
      selecting: screen == Screen.markNotifications,
    ),
    Screen.search ||
    Screen.searchRecent ||
    Screen.searchRecommend ||
    Screen.searchResults => SearchView(mode: screen),
    Screen.filter => const FilterView(),
  };
}
