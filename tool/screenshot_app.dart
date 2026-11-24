import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mamam_delivery/app.dart';
import 'package:mamam_delivery/core/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final screen = ValueNotifier((Screen.splash, false, 0));
  runApp(
    ValueListenableBuilder(
      valueListenable: screen,
      builder: (context, value, _) => _CaptureApp(
        key: ValueKey(value.$3),
        screen: value.$1,
        dark: value.$2,
      ),
    ),
  );

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 37455);
  await for (final request in server) {
    final parts = request.uri.pathSegments;
    final index = parts.length == 2 ? int.tryParse(parts[1]) : null;
    final response = request.response;
    if (request.method != 'GET') {
      response.statusCode = HttpStatus.methodNotAllowed;
    } else if (request.uri.path == '/ready') {
      response.write('ready');
    } else if (index == null ||
        index < 1 ||
        index > Screen.values.length ||
        !['light', 'dark'].contains(parts.first)) {
      response.statusCode = HttpStatus.notFound;
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      screen.value = (
        Screen.values[index - 1],
        parts.first == 'dark',
        screen.value.$3 + 1,
      );
      await WidgetsBinding.instance.endOfFrame;
      response.write('ok');
    }
    await response.close();
  }
}

class _CaptureApp extends StatefulWidget {
  const _CaptureApp({super.key, required this.screen, required this.dark});
  final Screen screen;
  final bool dark;

  @override
  State<_CaptureApp> createState() => _CaptureAppState();
}

class _CaptureAppState extends State<_CaptureApp> {
  late final session = Session(dark: widget.dark);

  @override
  void initState() {
    super.initState();
    switch (widget.screen) {
      case Screen.cart || Screen.checkout:
        session.cart.addAll({foods[0]: 1, foods[4]: 1, foods[2]: 1});
      case Screen.success || Screen.tracking:
        session.order = const DemoOrder(1234567, 1197);
      case Screen.markNotifications:
        session.notificationSelection.add(0);
      case Screen.searchResults:
        session.query = 'Backyard Burgers';
      case Screen.filter:
        session.filterCategory = 0;
      default:
        break;
    }
  }

  @override
  void dispose() {
    session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      MamamApp(initial: widget.screen, session: session, holdSplash: true);
}
