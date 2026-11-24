import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../core/session.dart';
import '../core/ui.dart';
import 'shop.dart';

class CartView extends StatelessWidget {
  const CartView({super.key, required this.checkout});
  final bool checkout;

  @override
  Widget build(BuildContext context) {
    final session = context.session;
    final empty = session.cart.isEmpty;
    return PageFrame(
      title: checkout ? 'Checkout' : 'Cart',
      padding: const EdgeInsets.fromLTRB(gutter, 25, gutter, 8),
      actions: [
        RoundIcon(
          Icons.search,
          tip: 'Search',
          onTap: () => context.open(Screen.search),
        ),
      ],
      body: listBody([
        _Steps(checkout ? 1 : 0),
        const SizedBox(height: 15),
        if (empty) ...[
          const Center(child: Art('cart-empty', height: 178)),
          const SizedBox(height: 6),
          heading('Your Cart is Empty', size: 22, align: TextAlign.center),
          const SizedBox(height: 9),
          label(
            'Find something you love and add it to your cart.',
            color: context.muted,
            align: TextAlign.center,
          ),
          const SizedBox(height: 24),
          heading('You May Also Like'),
          const SizedBox(height: 11),
          FoodGrid([foods[5], foods[3]]),
        ] else ...[
          if (checkout) ...[
            heading('Delivery To'),
            const SizedBox(height: 9),
            ChoiceTile(
              title: session.address.name,
              subtitle: session.address.street,
              icon: Icons.location_on,
              selected: true,
              showRadio: false,
              onTap: () => context.open(Screen.address),
            ),
            const SizedBox(height: 13),
          ],
          for (final entry in session.cart.entries)
            _CartLine(food: entry.key, amount: entry.value, mutable: !checkout),
          const SizedBox(height: 8),
          Divider(color: context.line),
          const SizedBox(height: 7),
          _CheckoutLink(
            icon: Icons.confirmation_number_outlined,
            text: session.voucherIndex == 0
                ? 'Use Voucher'
                : _voucherNames[session.voucherIndex],
            onTap: () => context.open(Screen.voucher),
          ),
          if (checkout)
            _CheckoutLink(
              icon: Icons.credit_card,
              text: 'Payment Method',
              onTap: () => context.open(Screen.payment),
            ),
        ],
      ]),
      bottom: empty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    label('Discount', color: context.muted),
                    label(money(session.discount), color: context.muted),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    heading('Total', size: 18),
                    heading(money(session.total), size: 18, color: green),
                  ],
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  checkout ? 'Order Now' : 'Proceed To Checkout',
                  () {
                    if (checkout) {
                      session.placeOrder();
                      context.root(Screen.success);
                    } else {
                      context.open(Screen.checkout);
                    }
                  },
                ),
              ],
            ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps(this.active);
  final int active;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final (index, name) in ['Cart', 'Checkout', 'Delivery'].indexed)
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: active == index ? green : context.line,
                  width: 2,
                ),
              ),
            ),
            child: heading(name, size: 12),
          ),
        ),
    ],
  );
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.food,
    required this.amount,
    required this.mutable,
  });
  final Food food;
  final int amount;
  final bool mutable;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 11),
    padding: const EdgeInsets.all(9),
    decoration: cardDecoration(context),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Art(food.image, width: 72, height: 74, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(food.name, size: 12),
              const SizedBox(height: 3),
              label(
                '1km  |  ⭐ 5.0 (1.3k)',
                color: context.muted,
                size: 9,
                lines: 1,
              ),
              const SizedBox(height: 4),
              heading(money(food.cents * amount), color: green, size: 15),
            ],
          ),
        ),
        if (mutable)
          Quantity(
            value: amount,
            change: (delta) => context.session.setQuantity(food, delta),
          ),
      ],
    ),
  );
}

class _CheckoutLink extends StatelessWidget {
  const _CheckoutLink({
    required this.icon,
    required this.text,
    required this.onTap,
  });
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: context.softGreen,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Material(
      type: MaterialType.transparency,
      child: ListTile(
        onTap: onTap,
        dense: true,
        minTileHeight: 40,
        leading: Icon(icon, color: green, size: 16),
        title: label(text, color: context.ink, size: 11),
        trailing: const Icon(Icons.chevron_right, color: green, size: 16),
      ),
    ),
  );
}

const _voucherNames = [
  'Free Shipping',
  'Discount 20%',
  'Discount 30%',
  'Buy 1 Get 1 Free',
  'Discount 50%',
];

class CheckoutOptions extends StatefulWidget {
  const CheckoutOptions({super.key, required this.screen});
  final Screen screen;

  @override
  State<CheckoutOptions> createState() => _CheckoutOptionsState();
}

class _CheckoutOptionsState extends State<CheckoutOptions> {
  bool get address => widget.screen == Screen.address;
  bool get payment => widget.screen == Screen.payment;
  late int selection = address
      ? context.session.addressIndex
      : payment
      ? context.session.paymentIndex
      : context.session.voucherIndex;

  @override
  Widget build(BuildContext context) {
    final session = context.session;
    final names = address
        ? session.addresses.map((item) => item.name).toList()
        : payment
        ? session.payments
        : _voucherNames;
    const paymentIcons = [
      Icons.credit_card,
      Icons.paypal,
      Icons.credit_card,
      Icons.apple,
      Icons.payments_outlined,
    ];
    return PageFrame(
      title: address
          ? 'Address'
          : payment
          ? 'Payment Method'
          : 'Voucher',
      actions: payment
          ? [
              RoundIcon(
                Icons.qr_code_scanner,
                tip: 'Scan QR Code',
                onTap: () => context.open(Screen.scan),
              ),
            ]
          : [],
      body: listBody([
        for (var i = 0; i < names.length; i++)
          ChoiceTile(
            title: names[i],
            subtitle: address
                ? session.addresses[i].street
                : payment
                ? null
                : 'Lorem ipsum dolor sit amet',
            icon: address
                ? Icons.location_on_outlined
                : payment
                ? paymentIcons[i < paymentIcons.length ? i : 0]
                : Icons.confirmation_number_outlined,
            color: selection == i
                ? green
                : payment
                ? const Color(0xff5476b5)
                : context.muted,
            selected: selection == i,
            onTap: () => setState(() => selection = i),
          ),
      ]),
      bottom: Column(
        children: [
          if (address || payment) ...[
            PrimaryButton(
              address ? 'Add New Address' : 'Add New Card',
              () async {
                final index = await context.open<int>(
                  address ? Screen.addAddress : Screen.addCard,
                );
                if (index != null && mounted) setState(() => selection = index);
              },
              soft: true,
            ),
            const SizedBox(height: 8),
          ],
          PrimaryButton('Apply', () {
            session.update(() {
              if (address) {
                session.addressIndex = selection;
              } else if (payment) {
                session.paymentIndex = selection;
              } else {
                session.voucherIndex = selection;
              }
            });
            Navigator.of(context).maybePop();
          }),
        ],
      ),
    );
  }
}

class LocationView extends StatefulWidget {
  const LocationView({super.key, required this.initial});
  final bool initial;
  @override
  State<LocationView> createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  late final location = TextEditingController(
    text: context.session.location ?? demoLocation,
  );
  Alignment pin = Alignment.center;

  @override
  void dispose() {
    location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: widget.initial ? 'Set Your Location' : 'Set Location',
    padding: const EdgeInsets.only(top: 19),
    body: listBody([
      LayoutBuilder(
        builder: (context, box) => GestureDetector(
          onTapDown: (event) => setState(() {
            pin = Alignment(
              (event.localPosition.dx / box.maxWidth * 2 - 1).clamp(-.94, .94),
              (event.localPosition.dy / 385 * 2 - 1).clamp(-.94, .94),
            );
          }),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              const Art(
                'map',
                height: 385,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: Align(
                  alignment: pin,
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: green,
                    size: 60,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(gutter, 21, gutter, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading('Choose a place on the map', size: 15),
            const SizedBox(height: 14),
            FormFieldBox(
              'Delivery location',
              controller: location,
              highlighted: true,
              icon: Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    ]),
    bottom: PrimaryButton(
      widget.initial ? 'Go To Shopping' : 'Confirm Location',
      () {
        final value = location.text.trim();
        if (value.isEmpty) {
          feedback(context, 'Enter a delivery location.');
          return;
        }
        context.session.update(() => context.session.location = value);
        if (widget.initial) {
          context.root(Screen.home);
        } else {
          Navigator.of(context).maybePop(value);
        }
      },
    ),
  );
}

class AddAddressView extends StatefulWidget {
  const AddAddressView({super.key});
  @override
  State<AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<AddAddressView> {
  final form = GlobalKey<FormState>();
  final street = TextEditingController();
  String title = '';
  bool preferred = true;

  @override
  void dispose() {
    street.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Add New Address',
    body: Form(
      key: form,
      child: listBody([
        FormFieldBox(
          'Type Address Title',
          validator: requiredText,
          icon: Icons.label_outline,
          onSaved: (value) => title = value!.trim(),
        ),
        InkWell(
          onTap: () async {
            final value = await context.open<String>(Screen.setLocation);
            if (value != null && mounted) street.text = value;
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: cardDecoration(context, selected: true),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const SizedBox(
                  height: 140,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Art('map', fit: BoxFit.cover),
                      Center(
                        child: Icon(
                          Icons.location_on_outlined,
                          color: green,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: heading('Set My Location', size: 12)),
                      const Icon(Icons.more_horiz, size: 19),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const FormFieldBox(
          'Full Name',
          icon: Icons.person_outline,
          validator: requiredText,
        ),
        const FormFieldBox('Country/Region', icon: Icons.flag_outlined),
        FormFieldBox(
          'Street Address',
          controller: street,
          icon: Icons.location_on_outlined,
          validator: requiredText,
        ),
        const FormFieldBox('Town/City', icon: Icons.location_city_outlined),
        const FormFieldBox(
          'Phone Number',
          icon: Icons.phone_outlined,
          keyboard: TextInputType.phone,
        ),
        const FormFieldBox(
          'Email Address',
          icon: Icons.mail_outline,
          keyboard: TextInputType.emailAddress,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: label('Set Default Address'),
          value: preferred,
          onChanged: (value) => setState(() => preferred = value),
        ),
      ]),
    ),
    bottom: PrimaryButton('Save Address', () {
      if (!form.currentState!.validate()) return;
      form.currentState!.save();
      final session = context.session;
      session.update(() {
        session.addresses.add(Address(title, street.text.trim()));
        if (preferred) session.addressIndex = session.addresses.length - 1;
      });
      context.close(session.addresses.length - 1);
    }),
  );
}

class AddCardView extends StatefulWidget {
  const AddCardView({super.key});
  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  final form = GlobalKey<FormState>();
  final number = TextEditingController();
  bool preferred = true;

  @override
  void dispose() {
    number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Add New Card',
    body: Form(
      key: form,
      child: listBody([
        Container(
          width: double.infinity,
          height: 175,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xffb7eca1), Color(0xffd8eab7), Color(0xff9cbe96)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.apple, color: Color(0xff121a12), size: 24),
                  heading(
                    '•••• •••• •••• 6173',
                    color: const Color(0xff121a12),
                    size: 12,
                  ),
                ],
              ),
              const Spacer(),
              label('Balance', color: const Color(0xff121a12), size: 11),
              heading(r'$ 9821.42', size: 27, color: const Color(0xff121a12)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  label('Change Name', color: const Color(0xff121a12)),
                  label('08/30', color: const Color(0xff121a12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 17),
        const FormFieldBox(
          'Full Name',
          icon: Icons.person_outline,
          validator: requiredText,
        ),
        FormFieldBox(
          'Card Number',
          icon: Icons.credit_card,
          keyboard: TextInputType.number,
          limit: 16,
          controller: number,
          validator: (value) =>
              value?.length == 16 ? null : 'Enter a 16-digit demo number',
        ),
        FormFieldBox(
          'CVV',
          icon: Icons.password,
          keyboard: TextInputType.number,
          limit: 4,
          secret: true,
          validator: (value) =>
              (value?.length ?? 0) >= 3 ? null : 'Enter a demo CVV',
        ),
        FormFieldBox(
          'Exp Date',
          icon: Icons.calendar_today_outlined,
          limit: 5,
          validator: (value) =>
              RegExp(r'^(0[1-9]|1[0-2])/\d{2}$').hasMatch(value ?? '')
              ? null
              : 'Use MM/YY',
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: label('Set Default Card'),
          value: preferred,
          onChanged: (value) => setState(() => preferred = value),
        ),
        label(
          'Use fictional card details in this demo.',
          color: context.muted,
          size: 10,
        ),
      ]),
    ),
    bottom: PrimaryButton('Add Card', () {
      if (!form.currentState!.validate()) return;
      final session = context.session;
      session.update(() {
        session.payments.add('Demo card •••• ${number.text.substring(12)}');
        if (preferred) session.paymentIndex = session.payments.length - 1;
      });
      context.close(session.payments.length - 1);
    }),
  );
}

class SuccessView extends StatelessWidget {
  const SuccessView({super.key});
  @override
  Widget build(BuildContext context) {
    final session = context.session;
    final order = session.order;
    return PageFrame(
      title: '',
      actions: [
        RoundIcon(
          Icons.local_shipping_outlined,
          tip: 'Order Tracking',
          background: context.softGreen,
          onTap: () => context.open(Screen.tracking),
        ),
      ],
      padding: EdgeInsets.zero,
      body: listBody([
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: 164,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.softGreen,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.elliptical(240, 148),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 27),
              child: Column(
                children: [
                  const Art('order-success', width: 224, height: 188),
                  const SizedBox(height: 15),
                  heading('Thanks For Your Order', size: 21),
                  const SizedBox(height: 8),
                  Container(width: 25, height: 2, color: green),
                  const SizedBox(height: 9),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: gutter),
                    child: label(
                      'Order details for ${session.profile['Email']}.',
                      align: TextAlign.center,
                      color: context.muted,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.open(Screen.tracking),
                    child: label(
                      'Track Order',
                      color: green,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
      bottom: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: cardDecoration(context, selected: true),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Order Detail', size: 13, color: green),
                Divider(color: context.line),
                _detail(
                  'Order Number:',
                  order == null ? '—' : '#${order.number}',
                ),
                const SizedBox(height: 5),
                _detail('Amount Paid:', money(order?.total ?? 0)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          PrimaryButton('Continue Shopping', () => context.root(Screen.home)),
        ],
      ),
    );
  }

  Widget _detail(String text, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [label(text, size: 11), heading(value, size: 11)],
  );
}

class TrackingView extends StatelessWidget {
  const TrackingView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusOverlay(false),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const Art(
                      'tracking-map',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                    Positioned(
                      left: gutter,
                      right: gutter,
                      top: MediaQuery.paddingOf(context).top + 14,
                      child: PageHeader(
                        'Order Tracking',
                        color: const Color(0xff171717),
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -8),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xff161616),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  width: double.infinity,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 17),
                        heading(
                          'Estimated Delivery Time Is 5 Min',
                          size: 12,
                          color: Colors.white,
                        ),
                        label(
                          'Your order is already on its way to you',
                          size: 10,
                          color: Colors.white60,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: gutter,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.fact_check_outlined,
                                color: green,
                                size: 20,
                              ),
                              Expanded(
                                child: Container(height: 1, color: green),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(7),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  color: green,
                                  size: 20,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white38,
                                ),
                              ),
                              const Icon(
                                Icons.check_box,
                                color: Colors.white,
                                size: 19,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 11),
                        Container(
                          color: const Color(0xff292929),
                          padding: const EdgeInsets.fromLTRB(
                            gutter,
                            14,
                            gutter,
                            13,
                          ),
                          child: Row(
                            children: [
                              const ClipOval(child: Art('courier', width: 48)),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    heading(
                                      'Serenity Fisher',
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    label(
                                      'Courier',
                                      size: 10,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                              ),
                              RoundIcon(
                                Icons.call_outlined,
                                tip: 'Call courier',
                                background: green,
                                color: Colors.white,
                                onTap: () => feedback(
                                  context,
                                  'No courier call in this demo.',
                                ),
                              ),
                              const SizedBox(width: 6),
                              RoundIcon(
                                Icons.chat_bubble_outline,
                                tip: 'Chat with courier',
                                background: green,
                                color: Colors.white,
                                onTap: () => context.open(Screen.chat),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ScanView extends StatelessWidget {
  const ScanView({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xff54313e),
    body: AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusOverlay(true),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Art('qr-preview', fit: BoxFit.cover),
          const ColoredBox(color: Color(0x4020192c)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, box) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(gutter, 14, gutter, 9),
                    child: const PageHeader(
                      'Scan QR Code',
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: (box.maxWidth - 2 * gutter)
                            .clamp(120, 380)
                            .toDouble(),
                        height: box.maxHeight * .53,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70, width: 2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Container(height: 2, color: Colors.white60),
                      ),
                    ),
                  ),
                  RoundIcon(
                    Icons.flashlight_on_outlined,
                    tip: 'Preview scanner',
                    size: 57,
                    background: Colors.white30,
                    color: Colors.white,
                    onTap: () =>
                        feedback(context, 'This is a QR scanner preview.'),
                  ),
                  SizedBox(height: box.maxHeight * .08),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
