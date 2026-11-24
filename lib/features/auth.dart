import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../core/session.dart';
import '../core/ui.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key, required this.hold});
  final bool hold;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer? timer;
  bool starting = false;

  @override
  void initState() {
    super.initState();
    if (!widget.hold) timer = Timer(const Duration(milliseconds: 1700), start);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void start() {
    if (starting) return;
    starting = true;
    context.replace(Screen.intro1);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusOverlay(context.dark),
      child: InkWell(
        onTap: start,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Art('splash-bg', fit: BoxFit.cover),
            const Center(
              child: Art('logo', width: 175, color: Color(0xffd1ff82)),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 21),
                  child: label(
                    'Food & Beverage App',
                    size: 13,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class IntroView extends StatelessWidget {
  const IntroView({super.key, required this.page});
  final int page;

  @override
  Widget build(BuildContext context) {
    const titles = [
      'The Taste That\nRhymes With Your\nCravings',
      'A Rhythmic\nPattern Of Food\nAnd Taste',
      'Making Dishes\nWonderful Again\nAnd Again',
      'Choose The\nQuality Of Food\nAlways',
    ];
    final next = page == 3
        ? Screen.signIn
        : Screen.values[Screen.intro1.index + page + 1];
    final suffix = context.dark ? '-dark' : '';
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: statusOverlay(true),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Art('intro${page + 1}-bg$suffix', fit: BoxFit.fill),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, size) {
                  final compact = size.maxHeight < 625;
                  return Center(
                    child: SizedBox(
                      width: 460,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          compact ? 5 : 20,
                          16,
                          compact ? 8 : 23,
                        ),
                        child: Column(
                          children: [
                            const Art('logo', width: 75, height: 53),
                            label(
                              'Food & Beverage',
                              color: Colors.white,
                              size: 10,
                            ),
                            Expanded(
                              child: Transform.scale(
                                scale: 1.08,
                                child: Art(
                                  'intro${page + 1}',
                                  width: double.infinity,
                                  alignment: const Alignment(0, -.24),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                              ),
                              child: label(
                                titles[page],
                                align: TextAlign.center,
                                size: compact ? 24 : 31,
                                color: Colors.white,
                                weight: FontWeight.w700,
                                height: 1.07,
                              ),
                            ),
                            SizedBox(height: compact ? 12 : 27),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < 4; i++)
                                  Container(
                                    width: i == page ? 23 : 6,
                                    height: 5,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: i == page
                                          ? Colors.white
                                          : Colors.white38,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: compact ? 15 : 38),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(27),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () =>
                                          context.replace(Screen.signIn),
                                      child: label(
                                        'Skip',
                                        color: Colors.white,
                                        weight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: PrimaryButton(
                                      'Next',
                                      () => context.replace(next),
                                      white: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthView extends StatefulWidget {
  const AuthView({super.key, required this.signUp});
  final bool signUp;

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final form = GlobalKey<FormState>();
  final password = TextEditingController();
  bool accepted = true;
  String email = '';

  @override
  void dispose() {
    password.dispose();
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    if (widget.signUp && !accepted) {
      feedback(context, 'Accept the terms to create an account.');
      return;
    }
    form.currentState!.save();
    if (widget.signUp) {
      context.session.update(() {
        context.session.verificationEmail = email;
        context.session.recovery = false;
      });
      context.open(Screen.verify);
    } else {
      context.root(Screen.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signUp = widget.signUp;
    final session = context.session;
    return Scaffold(
      backgroundColor: const Color(0xff251039),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: statusOverlay(!signUp || context.dark),
        child: SafeArea(
          top: false,
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.canvas,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                        child: Column(
                          children: [
                            if (signUp)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: MediaQuery.paddingOf(context).top + 14,
                                ),
                                child: Art(
                                  'logo',
                                  width: 75,
                                  height: 58,
                                  color: context.ink,
                                ),
                              )
                            else
                              Art(
                                context.dark
                                    ? 'signin-hero-dark'
                                    : 'signin-hero',
                                height: 260,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 480,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    gutter,
                                    13,
                                    gutter,
                                    signUp ? 29 : 36,
                                  ),
                                  child: Form(
                                    key: form,
                                    child: Column(
                                      children: [
                                        heading(
                                          signUp
                                              ? 'Create An Account'
                                              : 'Sign In',
                                          size: 29,
                                          align: TextAlign.center,
                                        ),
                                        const SizedBox(height: 5),
                                        label(
                                          signUp
                                              ? 'Create a commitment-free profile\nto explore products'
                                              : 'Access to your account',
                                          size: 12,
                                          color: context.muted,
                                          align: TextAlign.center,
                                        ),
                                        const SizedBox(height: 19),
                                        FormFieldBox(
                                          'Username',
                                          icon: Icons.person_outline,
                                          validator: requiredText,
                                        ),
                                        if (signUp)
                                          FormFieldBox(
                                            'Email Address',
                                            icon: Icons.mail_outline,
                                            validator: emailError,
                                            keyboard:
                                                TextInputType.emailAddress,
                                            onSaved: (value) =>
                                                email = value!.trim(),
                                          ),
                                        FormFieldBox(
                                          'Password',
                                          icon: Icons.lock_outline,
                                          secret: true,
                                          validator: passwordError,
                                          controller: password,
                                        ),
                                        if (signUp)
                                          FormFieldBox(
                                            'Confirm Password',
                                            icon: Icons.lock_outline,
                                            secret: true,
                                            validator: (value) =>
                                                value == password.text
                                                ? null
                                                : 'Passwords must match',
                                          ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 24,
                                              height: 30,
                                              child: Checkbox(
                                                value: signUp
                                                    ? accepted
                                                    : session.rememberMe,
                                                activeColor: green,
                                                visualDensity:
                                                    VisualDensity.compact,
                                                onChanged: (value) => signUp
                                                    ? setState(
                                                        () => accepted = value!,
                                                      )
                                                    : session.update(
                                                        () =>
                                                            session.rememberMe =
                                                                value!,
                                                      ),
                                              ),
                                            ),
                                            Flexible(
                                              child: label(
                                                signUp
                                                    ? 'I agree with the Terms of Services & Privacy Policy'
                                                    : 'Remember me',
                                                size: 10,
                                                color: context.muted,
                                              ),
                                            ),
                                            if (!signUp) ...[
                                              const Spacer(),
                                              TextButton(
                                                onPressed: () =>
                                                    context.open(Screen.forgot),
                                                child: label(
                                                  'Forgot Password',
                                                  color: context.muted,
                                                  size: 10,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        PrimaryButton(
                                          signUp ? 'Sign Up' : 'Sign In',
                                          submit,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        gutter,
                        10,
                        gutter,
                        24,
                      ),
                      child: Column(
                        children: [
                          label(
                            signUp ? 'Or Sign Up With' : 'Or Sign In With',
                            size: 10,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (final (name, icon, color) in [
                                ('Apple', Icons.apple, Colors.black),
                                (
                                  'Google',
                                  Icons.g_mobiledata,
                                  const Color(0xff4185f4),
                                ),
                                (
                                  'Facebook',
                                  Icons.facebook,
                                  const Color(0xff1877f2),
                                ),
                              ])
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: RoundIcon(
                                    icon,
                                    tip: name,
                                    background: Colors.white,
                                    color: color,
                                    size: 40,
                                    onTap: () => feedback(
                                      context,
                                      '$name sign-in is available in the connected service.',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: label(
                                  signUp
                                      ? 'Already Have An Account?'
                                      : 'Don’t Have An Account?',
                                  color: Colors.white,
                                  size: 11,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.replace(
                                  signUp ? Screen.signIn : Screen.signUp,
                                ),
                                child: label(
                                  signUp ? 'Sign in' : 'Sign up',
                                  color: const Color(0xff96e064),
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VerificationView extends StatefulWidget {
  const VerificationView({super.key, required this.filled});
  final bool filled;

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  late final TextEditingController code = TextEditingController(
    text: widget.filled ? '5290' : '',
  );
  final focus = FocusNode();

  @override
  void dispose() {
    code.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: '',
    padding: EdgeInsets.zero,
    body: LayoutBuilder(
      builder: (context, size) => listBody([
        Padding(
          padding: const EdgeInsets.fromLTRB(gutter, 36, gutter, 8),
          child: Column(
            children: [
              heading('Verification', size: 28),
              const SizedBox(height: 8),
              label(
                'We have sent the code verification to your email',
                color: context.muted,
                align: TextAlign.center,
              ),
              heading(context.session.verificationEmail, size: 12),
              const SizedBox(height: 29),
              GestureDetector(
                onTap: focus.requestFocus,
                child: Stack(
                  children: [
                    SizedBox(
                      height: 86,
                      child: TextField(
                        controller: code,
                        focusNode: focus,
                        autofocus: widget.filled,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        style: const TextStyle(color: Colors.transparent),
                        showCursor: false,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Verification code',
                          labelStyle: TextStyle(color: Colors.transparent),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    IgnorePointer(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (i) => Flexible(
                            child: Container(
                              width: 49,
                              height: 83,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              alignment: Alignment.center,
                              decoration: cardDecoration(
                                context,
                                radius: 28,
                                selected: code.text.length > i,
                              ),
                              child: label(
                                code.text.length > i ? code.text[i] : '',
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              PrimaryButton('Confirm', () {
                if (code.text.length != 4) {
                  feedback(context, 'Enter a four-digit demo code.');
                  return;
                }
                focus.unfocus();
                context.replace(
                  context.session.recovery
                      ? Screen.newPassword
                      : Screen.setupProfile,
                );
              }),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  label(
                    'Didn’t receive the code?',
                    color: context.muted,
                    size: 11,
                  ),
                  TextButton(
                    onPressed: () =>
                        feedback(context, 'Demo verification code: 5290'),
                    child: label(
                      'Resend',
                      color: green,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (size.maxHeight > 390)
          Align(
            alignment: Alignment.bottomCenter,
            child: Art(
              'verify-art',
              width: double.infinity,
              height: (size.maxHeight - 365).clamp(180, 390).toDouble(),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
      ]),
    ),
  );
}

class PasswordView extends StatefulWidget {
  const PasswordView({super.key, required this.reset});
  final bool reset;

  @override
  State<PasswordView> createState() => _PasswordViewState();
}

class _PasswordViewState extends State<PasswordView> {
  final form = GlobalKey<FormState>();
  final input = TextEditingController();

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void submit() {
    if (!form.currentState!.validate()) return;
    if (widget.reset) {
      if (context.session.recovery) {
        context.root(Screen.signIn);
      } else {
        context.close();
        feedback(context, 'Password updated for this demo.');
      }
      return;
    }
    context.session.update(() {
      context.session.verificationEmail = input.text.trim();
      context.session.recovery = true;
    });
    context.open(Screen.verify);
  }

  @override
  Widget build(BuildContext context) {
    final reset = widget.reset;
    return PageFrame(
      title: '',
      padding: EdgeInsets.zero,
      body: LayoutBuilder(
        builder: (context, size) => listBody([
          Padding(
            padding: const EdgeInsets.fromLTRB(gutter, 35, gutter, 12),
            child: Form(
              key: form,
              child: Column(
                children: [
                  heading(
                    reset ? 'Set New Password' : 'Forgot Password',
                    size: 27,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 7),
                  label(
                    reset
                        ? 'Set A New Password That Must Be Different\nFrom The Old Password'
                        : 'Enter Your E-Mail To Recover Password',
                    color: context.muted,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 23),
                  FormFieldBox(
                    reset ? 'Password' : 'Email Address',
                    icon: reset ? Icons.lock_outline : Icons.mail_outline,
                    secret: reset,
                    controller: input,
                    keyboard: reset ? null : TextInputType.emailAddress,
                    validator: reset ? passwordError : emailError,
                  ),
                  if (reset)
                    FormFieldBox(
                      'Confirm Password',
                      icon: Icons.lock_outline,
                      secret: true,
                      validator: (value) =>
                          value == input.text ? null : 'Passwords must match',
                    ),
                  PrimaryButton(
                    reset ? 'Change password' : 'Reset Password',
                    submit,
                  ),
                  if (!reset)
                    TextButton.icon(
                      onPressed: () => context.open(Screen.chat),
                      icon: const Icon(Icons.help, size: 18),
                      label: label('Need Help?', color: context.muted),
                    ),
                ],
              ),
            ),
          ),
          Container(
            height: (size.maxHeight - 255).clamp(200, 410).toDouble(),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(.5, .95),
                radius: 1,
                colors: [purple.withValues(alpha: .32), Colors.transparent],
              ),
            ),
            child: const Art(
              'reset-art',
              width: double.infinity,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ]),
      ),
    );
  }
}

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key, required this.edit});
  final bool edit;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final form = GlobalKey<FormState>();
  final values = <String, String>{};

  @override
  Widget build(BuildContext context) {
    final session = context.session;
    return PageFrame(
      title: widget.edit ? 'Edit Profile' : 'Setup Profile',
      body: Form(
        key: form,
        child: listBody([
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                if (widget.edit)
                  const ClipOval(child: Art('avatar', width: 100, height: 100))
                else
                  CircleAvatar(
                    radius: 51,
                    backgroundColor: context.subtle,
                    child: Icon(
                      Icons.person,
                      size: 82,
                      color: context.muted.withValues(alpha: .42),
                    ),
                  ),
                const CircleAvatar(
                  radius: 13,
                  backgroundColor: green,
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
          if (widget.edit) ...[
            const SizedBox(height: 11),
            Center(child: heading(session.profile['Full Name']!, size: 15)),
          ],
          const SizedBox(height: 22),
          for (final field in session.profile.keys)
            if (widget.edit)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: label(field, size: 11, color: context.muted),
                    ),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        key: ValueKey(field),
                        initialValue: session.profile[field],
                        decoration: InputDecoration(
                          isDense: true,
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: context.line),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        keyboardType: field == 'Email'
                            ? TextInputType.emailAddress
                            : null,
                        validator: field == 'Email'
                            ? emailError
                            : field == 'Full Name'
                            ? requiredText
                            : null,
                        onSaved: (value) => values[field] = value!.trim(),
                      ),
                    ),
                  ],
                ),
              )
            else
              FormFieldBox(
                field,
                initial: field == 'Full Name' ? session.profile[field] : null,
                highlighted: field == 'Full Name',
                icon: field == 'Date Of Birth'
                    ? Icons.calendar_today_outlined
                    : null,
                keyboard: field == 'Email' ? TextInputType.emailAddress : null,
                validator: field == 'Full Name' ? requiredText : null,
                onSaved: (value) {
                  if (value!.trim().isNotEmpty) values[field] = value.trim();
                },
              ),
        ]),
      ),
      bottom: PrimaryButton(widget.edit ? 'Update' : 'Continue', () {
        if (!form.currentState!.validate()) return;
        form.currentState!.save();
        session.update(() => session.profile.addAll(values));
        if (widget.edit) {
          context.close();
        } else {
          context.open(Screen.initialLocation);
        }
      }),
    );
  }
}
