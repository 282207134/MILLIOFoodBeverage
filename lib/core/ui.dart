import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import 'session.dart';

const green = Color(0xff61bf1b);
const purple = Color(0xff9031f7);
const yellow = Color(0xffffcf00);
const gutter = 25.0;

ThemeData mamamTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final surface = dark ? const Color(0xff0e0e0e) : Colors.white;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: 'Montserrat',
    scaffoldBackgroundColor: surface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: green,
      brightness: brightness,
    ).copyWith(primary: green, surface: surface),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: green),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: green),
  );
}

extension ColorsOfScreen on BuildContext {
  bool get dark => Theme.of(this).brightness == Brightness.dark;
  Color get canvas => Theme.of(this).scaffoldBackgroundColor;
  Color get ink => dark ? Colors.white : const Color(0xff171717);
  Color get muted => dark ? const Color(0xffa7a7a7) : const Color(0xff777777);
  Color get subtle => dark ? const Color(0xff202020) : const Color(0xfffafafa);
  Color get softGreen =>
      dark ? const Color(0xff213313) : const Color(0xffedf8e6);
  Color get line => dark ? const Color(0xff343434) : const Color(0xffececec);
}

Widget label(
  String text, {
  double size = 12,
  FontWeight weight = FontWeight.w500,
  Color? color,
  TextAlign? align,
  int? lines,
  double height = 1.35,
}) => Text(
  text,
  textAlign: align,
  maxLines: lines,
  overflow: lines == null ? null : TextOverflow.ellipsis,
  style: TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  ),
);

Widget heading(
  String text, {
  double size = 17,
  TextAlign? align,
  Color? color,
}) => label(
  text,
  size: size,
  weight: FontWeight.w700,
  align: align,
  color: color,
);

class Art extends StatelessWidget {
  const Art(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.color,
  });
  final String name;
  final double? width, height;
  final BoxFit fit;
  final Alignment alignment;
  final Color? color;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/$name.webp',
    width: width,
    height: height,
    fit: fit,
    alignment: alignment,
    color: color,
    filterQuality: FilterQuality.medium,
  );
}

class RoundIcon extends StatelessWidget {
  const RoundIcon(
    this.icon, {
    super.key,
    required this.tip,
    required this.onTap,
    this.background,
    this.color,
    this.size = 34,
  });
  final IconData icon;
  final String tip;
  final VoidCallback onTap;
  final Color? background, color;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onTap,
    tooltip: tip,
    style: IconButton.styleFrom(
      backgroundColor: background ?? context.subtle,
      foregroundColor: color ?? context.ink,
      minimumSize: Size.square(size),
      fixedSize: Size.square(size),
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    icon: Icon(icon, size: size > 44 ? 23 : 17),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.text,
    this.onTap, {
    super.key,
    this.soft = false,
    this.white = false,
  });
  final String text;
  final VoidCallback? onTap;
  final bool soft, white;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: white
            ? Colors.white
            : soft
            ? context.softGreen
            : green,
        foregroundColor: soft || white
            ? (context.dark && soft
                  ? const Color(0xff91da5e)
                  : const Color(0xff408813))
            : Colors.white,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: label(text, weight: FontWeight.w700, align: TextAlign.center),
    ),
  );
}

BoxDecoration cardDecoration(
  BuildContext context, {
  double radius = 12,
  Color? color,
  bool selected = false,
}) => BoxDecoration(
  color: color ?? (selected ? context.softGreen : context.canvas),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(
    color: selected
        ? green.withValues(alpha: .35)
        : context.line.withValues(alpha: .55),
  ),
  boxShadow: context.dark
      ? null
      : const [
          BoxShadow(
            color: Color(0x0c222222),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
);

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    this.title,
    this.actions = const [],
    this.dismiss = false,
    this.back = true,
    required this.body,
    this.bottom,
    this.tab,
    this.topColor,
    this.statusDark,
    this.padding = const EdgeInsets.fromLTRB(gutter, 25, gutter, 18),
  });
  final String? title;
  final List<Widget> actions;
  final bool dismiss, back;
  final Widget body;
  final Widget? bottom;
  final Screen? tab;
  final Color? topColor;
  final bool? statusDark;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusOverlay(statusDark ?? context.dark),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                if (title != null)
                  ColoredBox(
                    color: topColor ?? Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(gutter, 14, gutter, 6),
                      child: PageHeader(
                        title!,
                        actions: actions,
                        dismiss: dismiss,
                        back: back,
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(padding: padding, child: body),
                ),
                if (bottom != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(gutter, 6, gutter, 12),
                    child: bottom,
                  ),
                if (tab != null) BottomNav(tab!),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

SystemUiOverlayStyle statusOverlay(bool dark) => SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
  statusBarBrightness: dark ? Brightness.dark : Brightness.light,
  systemNavigationBarColor: dark ? const Color(0xff0e0e0e) : Colors.white,
  systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
  systemNavigationBarContrastEnforced: false,
);

class PageHeader extends StatelessWidget {
  const PageHeader(
    this.title, {
    super.key,
    this.actions = const [],
    this.dismiss = false,
    this.back = true,
    this.color,
    this.onBack,
  });
  final String title;
  final List<Widget> actions;
  final bool dismiss, back;
  final Color? color;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: Row(
      children: [
        if (back) ...[
          RoundIcon(
            dismiss ? Icons.close : Icons.chevron_left,
            tip: dismiss ? 'Close' : 'Back',
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            background: color?.withValues(alpha: .2),
            color: color,
          ),
          const SizedBox(width: 13),
        ],
        Expanded(child: heading(title, size: 18, color: color)),
        ...actions,
      ],
    ),
  );
}

class BottomNav extends StatelessWidget {
  const BottomNav(this.active, {super.key});
  final Screen active;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (Screen.home, Icons.home_rounded, 'Home'),
      (Screen.offers, Icons.local_offer_outlined, 'Offers'),
      (Screen.cart, Icons.shopping_bag_outlined, 'Cart'),
      (Screen.account, Icons.person_outline_rounded, 'Account'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 3, 10, 8),
      decoration: BoxDecoration(
        color: context.dark ? const Color(0xff232323) : const Color(0xff161616),
        borderRadius: BorderRadius.circular(35),
      ),
      height: 55,
      child: Row(
        children: [
          for (final (screen, icon, title) in tabs)
            Expanded(
              child: Tooltip(
                message: title,
                child: InkResponse(
                  onTap: () {
                    if (screen == active) return;
                    if (screen == Screen.cart) {
                      context.open(
                        context.session.cart.isEmpty
                            ? Screen.cartEmpty
                            : Screen.cart,
                      );
                    } else {
                      context.root(screen);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 21,
                        color: screen == active ? Colors.white : Colors.white54,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: screen == active
                              ? Colors.white
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FormFieldBox extends StatefulWidget {
  const FormFieldBox(
    this.hint, {
    super.key,
    this.icon,
    this.initial,
    this.onSaved,
    this.validator,
    this.keyboard,
    this.secret = false,
    this.highlighted = false,
    this.lines = 1,
    this.controller,
    this.limit,
  });
  final String hint;
  final IconData? icon;
  final String? initial;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboard;
  final bool secret, highlighted;
  final int lines;
  final TextEditingController? controller;
  final int? limit;

  @override
  State<FormFieldBox> createState() => _FormFieldBoxState();
}

class _FormFieldBoxState extends State<FormFieldBox> {
  bool visible = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DecoratedBox(
      decoration: cardDecoration(
        context,
        radius: widget.lines > 1 ? 16 : 27,
        selected: widget.highlighted,
      ),
      child: TextFormField(
        controller: widget.controller,
        initialValue: widget.initial,
        onSaved: widget.onSaved,
        validator: widget.validator,
        obscureText: widget.secret && !visible,
        keyboardType: widget.keyboard,
        maxLines: widget.lines,
        maxLength: widget.limit,
        inputFormatters: widget.keyboard == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        style: TextStyle(fontSize: 12, color: context.ink),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(fontSize: 12, color: context.muted),
          counterText: '',
          prefixIcon: widget.icon == null
              ? null
              : Icon(widget.icon, size: 16, color: context.muted),
          suffixIcon: widget.secret
              ? IconButton(
                  tooltip: visible ? 'Hide password' : 'Show password',
                  icon: Icon(
                    visible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 16,
                  ),
                  onPressed: () => setState(() => visible = !visible),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          isDense: true,
          border: InputBorder.none,
          errorStyle: const TextStyle(fontSize: 10),
        ),
      ),
    ),
  );
}

String? requiredText(String? value) =>
    value == null || value.trim().isEmpty ? 'Required' : null;

String? emailError(String? value) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value ?? '')
    ? null
    : 'Enter a valid email';

String? passwordError(String? value) =>
    (value?.length ?? 0) >= 6 ? null : 'Use at least 6 characters';

void feedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
}

class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.color = green,
    this.selected = false,
    this.showRadio = true,
    this.trailing,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool selected, showRadio;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: cardDecoration(context, selected: selected),
    child: Material(
      type: MaterialType.transparency,
      child: ListTile(
        minTileHeight: 61,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 13),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: selected ? .95 : .12),
          child: Icon(icon, size: 17, color: selected ? Colors.white : color),
        ),
        title: heading(title, size: 12),
        subtitle: subtitle == null
            ? null
            : label(subtitle!, color: context.muted, size: 10, lines: 1),
        trailing:
            trailing ??
            (showRadio
                ? Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? green : context.line,
                    size: 14,
                  )
                : const Icon(Icons.chevron_right, size: 16)),
      ),
    ),
  );
}

Widget listBody(List<Widget> children, {EdgeInsets? padding}) =>
    ListView(padding: padding ?? EdgeInsets.zero, children: children);
