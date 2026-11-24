import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mamam_delivery/app.dart';
import 'package:mamam_delivery/core/session.dart';

Future<void> launch(WidgetTester tester, Screen screen, Session session) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(375, 812);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(session.dispose);
  await tester.pumpWidget(MamamApp(initial: screen, session: session));
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, String text) async {
  final button = find.widgetWithText(FilledButton, text);
  final target = button.evaluate().isEmpty ? find.text(text) : button;
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Each board renders at the design width in both themes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final dark in [false, true]) {
      for (final screen in Screen.values) {
        final session = Session(dark: dark);
        if (screen == Screen.cart || screen == Screen.checkout) {
          session.cart.addAll({foods[0]: 1, foods[4]: 1, foods[2]: 1});
        }
        await tester.pumpWidget(
          MamamApp(initial: screen, session: session, holdSplash: true),
        );
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${screen.name}, dark=$dark',
        );
        await tester.pumpWidget(const SizedBox.shrink());
        session.dispose();
      }
    }
  });

  testWidgets('Sign-in validates fields and opens the home screen', (
    tester,
  ) async {
    await launch(tester, Screen.signIn, Session());
    await tap(tester, 'Sign In');
    expect(find.text('Required'), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'demo');
    await tester.enterText(fields.at(1), 'sample-password');
    await tap(tester, 'Sign In');
    expect(find.text('What you want to\neat today? 🥗'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cart discounts and order history agree', (tester) async {
    final session = Session()..cart.addAll({foods[0]: 2, foods[2]: 1});
    await launch(tester, Screen.cart, session);
    await tap(tester, 'Use Voucher');
    await tap(tester, 'Discount 20%');
    await tap(tester, 'Apply');
    expect(session.discount, 239);
    await tap(tester, 'Proceed To Checkout');
    await tap(tester, 'Order Now');
    expect(session.order?.total, 958);
    expect(session.cart, isEmpty);
    expect(find.text('Thanks For Your Order'), findsOneWidget);
    expect(find.text(r'$ 9.58'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Search returns matching items and remembers the query', (
    tester,
  ) async {
    final session = Session();
    await launch(tester, Screen.search, session);
    final search = find.byType(TextField);
    await tester.tap(search);
    await tester.pumpAndSettle();
    await tester.enterText(search.last, 'steak');
    await tap(tester, 'Search');
    expect(find.text('Search Result'), findsOneWidget);
    expect(find.text('Sirloin steak'), findsOneWidget);
    expect(find.text('Backyard Burgers'), findsNothing);
    expect(session.history.first, 'steak');
  });

  testWidgets('Dark mode immediately updates the account theme', (
    tester,
  ) async {
    final session = Session();
    await launch(tester, Screen.account, session);
    await tap(tester, 'Preferences');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(session.dark, isTrue);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  test('Removing the last unit deletes the cart row', () {
    final session = Session();
    addTearDown(session.dispose);
    final food = foods.first;
    session.setQuantity(food, 2);
    session.setQuantity(food, -2);
    expect(session.cart, isEmpty);
    expect(session.total, 0);
  });
}
