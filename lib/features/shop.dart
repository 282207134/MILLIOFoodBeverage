import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../core/session.dart';
import '../core/ui.dart';

const _description =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna.';
const _categoryColors = [
  Color(0xffa6e852),
  Color(0xfff9e46d),
  Color(0xff75e5fa),
  Color(0xffb36af0),
  Color(0xffff8d8f),
  Color(0xff72efaa),
  Color(0xff8588fa),
  Color(0xffffa27b),
];

void showProduct(BuildContext context, Food food) =>
    context.open(Screen.product, food: food);

Future<void> _openFilters(
  BuildContext context, {
  bool showResults = true,
}) async {
  final applied = await context.open<bool>(Screen.filter);
  if (applied == true && showResults && context.mounted) {
    context.open(Screen.searchResults);
  }
}

Widget _cartAction(BuildContext context) => RoundIcon(
  Icons.shopping_bag_outlined,
  tip: 'Cart',
  onTap: () => context.open(
    context.session.cart.isEmpty ? Screen.cartEmpty : Screen.cart,
  ),
);

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) => PageFrame(
    tab: Screen.home,
    padding: EdgeInsets.zero,
    body: listBody([
      Padding(
        padding: const EdgeInsets.fromLTRB(gutter, 12, gutter, 0),
        child: Row(
          children: [
            RoundIcon(
              Icons.location_on_outlined,
              tip: 'Set location',
              background: context.softGreen,
              onTap: () => context.open(Screen.setLocation),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () => context.open(Screen.setLocation),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label('Location', color: context.muted, size: 10),
                    label(
                      context.session.location ?? 'San Jose, California',
                      size: 12,
                      weight: FontWeight.w700,
                      lines: 1,
                    ),
                  ],
                ),
              ),
            ),
            RoundIcon(
              Icons.notifications_none,
              tip: 'Notifications',
              onTap: () => context.open(Screen.notifications),
            ),
            const SizedBox(width: 5),
            _cartAction(context),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(gutter, 27, gutter, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading('What you want to\neat today? 🥗', size: 30),
            const SizedBox(height: 21),
            SearchBox(
              onTap: () => context.open(Screen.search),
              filter: () => _openFilters(context),
            ),
            const SizedBox(height: 19),
            const _OfferBanner(),
            const SizedBox(height: 25),
            _Section(
              'Categories',
              onTap: () => context.open(Screen.categories),
            ),
            const SizedBox(height: 16),
            const CategoryTiles(),
            const SizedBox(height: 23),
            _Section('Hot Deal Today', onTap: () => context.open(Screen.deal)),
            const SizedBox(height: 15),
            InkWell(
              onTap: () => context.open(Screen.deal),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: context.softGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Art('deal', height: 195),
                    heading('Seafood Som Tum', size: 16),
                    label(
                      r'$ 3.99 - $ 2.59',
                      size: 14,
                      color: green,
                      weight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 31),
            _Section(
              'Special Offers',
              onTap: () => context.open(Screen.offers),
            ),
            const SizedBox(height: 16),
            FoodGrid(foods.take(6).toList()),
            const SizedBox(height: 24),
            _Promotion(
              image: 'home-promotion',
              title: 'Video Promotion',
              onTap: () => context.open(Screen.description),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ]),
  );
}

class _OfferBanner extends StatelessWidget {
  const _OfferBanner();

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(17),
    onTap: () => context.open(Screen.offers),
    child: SizedBox(
      height: 197,
      child: Stack(
        children: [
          Positioned(
            top: 22,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xffad4afa),
                      Color(0xff7300ee),
                      Color(0xff9d21e7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: -50,
                      left: -23,
                      right: -22,
                      child: Transform.rotate(
                        angle: -.18,
                        child: Container(
                          height: 106,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .16),
                            borderRadius: BorderRadius.circular(130),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            right: 3,
            child: Art('burger', width: 107, height: 169),
          ),
          Positioned(
            left: 20,
            top: 43,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label(
                  'Sale Off 30%',
                  color: Colors.white,
                  weight: FontWeight.w700,
                ),
                const SizedBox(height: 6),
                Container(color: Colors.white, width: 29, height: 2),
                const SizedBox(height: 7),
                const Text(
                  'SPECIAL\nOFFERS',
                  style: TextStyle(
                    fontFamily: 'Luckiest Guy',
                    fontSize: 30,
                    height: .99,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.chevron_right, color: purple, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section(this.title, {this.onTap});
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: heading(title)),
      if (onTap != null)
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            decoration: BoxDecoration(
              color: context.softGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: label(
              'See all',
              color: green,
              size: 10,
              weight: FontWeight.w700,
            ),
          ),
        ),
    ],
  );
}

class CategoryTiles extends StatelessWidget {
  const CategoryTiles({super.key, this.large = false});
  final bool large;

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: large ? 2 : 4,
    crossAxisSpacing: large ? 15 : 7,
    mainAxisSpacing: large ? 15 : 14,
    childAspectRatio: large ? 1.10 : .85,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: [
      for (var i = 0; i < categories.length; i++)
        InkWell(
          onTap: () {
            context.session.update(() {
              context.session.filterCategory = i;
              context.session.query = '';
            });
            context.open(Screen.searchResults);
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: large
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [_categoryColors[i], context.canvas],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: large ? 67 : 53,
                  height: large ? 67 : 53,
                  padding: EdgeInsets.all(large ? 7 : 13),
                  decoration: large
                      ? null
                      : BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [_categoryColors[i], context.canvas],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                  child: Art(
                    'category$i',
                    color: large ? const Color(0xff272727) : context.ink,
                  ),
                ),
                const SizedBox(height: 4),
                label(
                  categories[i],
                  size: large ? 13 : 9,
                  align: TextAlign.center,
                  lines: 1,
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Categories',
    tab: Screen.home,
    body: listBody([const CategoryTiles(large: true)]),
  );
}

class OffersView extends StatelessWidget {
  const OffersView({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Special Offers',
    tab: Screen.offers,
    back: Navigator.of(context).canPop(),
    body: listBody([
      SearchBox(
        onTap: () => context.open(Screen.search),
        filter: () => _openFilters(context),
      ),
      const SizedBox(height: 25),
      FoodGrid(foods.take(6).toList()),
    ]),
  );
}

class FoodGrid extends StatelessWidget {
  const FoodGrid(this.items, {super.key});
  final List<Food> items;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      const spacing = 9.0;
      final width = (box.maxWidth - spacing) / 2;
      return Wrap(
        spacing: spacing,
        runSpacing: 15,
        children: [
          for (final food in items)
            SizedBox(
              width: width,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => showProduct(context, food),
                child: Container(
                  decoration: cardDecoration(context),
                  padding: const EdgeInsets.all(9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: AspectRatio(
                          aspectRatio: 1.23,
                          child: Art(food.image, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 11),
                      label(
                        food.name,
                        weight: FontWeight.w700,
                        size: 11,
                        lines: 1,
                      ),
                      const SizedBox(height: 5),
                      label(
                        '1km  |  ⭐ 5.0 (1.3k)',
                        color: context.muted,
                        size: 9,
                        lines: 1,
                      ),
                      const SizedBox(height: 7),
                      label(
                        money(food.cents),
                        size: 14,
                        weight: FontWeight.w700,
                        color: green,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

class DealView extends StatelessWidget {
  const DealView({super.key});

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Hot Deal Today',
    body: listBody([
      Container(
        height: 280,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.softGreen,
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Art('deal', height: 247),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(
                Icons.circle,
                size: i == 1 ? 7 : 5,
                color: i == 1 ? green : context.line,
              ),
            ),
        ],
      ),
      const SizedBox(height: 22),
      heading('Seafood\nSom Tum', size: 31),
      const SizedBox(height: 8),
      heading(r'$ 3.99 - $ 2.59', color: green, size: 22),
      const SizedBox(height: 9),
      label(_description, color: context.muted),
    ]),
    bottom: PrimaryButton('Add To Cart', () {
      context.session.setQuantity(foods.last, 1);
      context.open(Screen.cart);
    }),
  );
}

class ProductView extends StatefulWidget {
  const ProductView({super.key, required this.food});
  final Food food;
  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    final session = context.session;
    final food = widget.food;
    final favorite = session.favorites.contains(food);
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: statusOverlay(true),
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: LayoutBuilder(
                builder: (context, box) => listBody([
                  Stack(
                    children: [
                      Art(
                        food.hero ?? food.image,
                        width: double.infinity,
                        height: (box.maxHeight * .64)
                            .clamp(290, 540)
                            .toDouble(),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 14,
                        left: gutter,
                        right: gutter,
                        child: PageHeader(
                          '',
                          color: Colors.white,
                          actions: [
                            RoundIcon(
                              Icons.search,
                              tip: 'Search',
                              background: Colors.white,
                              color: Colors.black87,
                              onTap: () => context.open(Screen.search),
                            ),
                            const SizedBox(width: 7),
                            _cartAction(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -18),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.canvas,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(21),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(gutter, 17, gutter, 1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.restaurant_outlined,
                                size: 14,
                                color: purple,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: label(
                                  categories[food.category],
                                  size: 11,
                                  color: context.muted,
                                ),
                              ),
                              RoundIcon(
                                favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                tip: 'Wishlist',
                                color: favorite ? Colors.redAccent : null,
                                onTap: () => session.update(() {
                                  if (!session.favorites.add(food)) {
                                    session.favorites.remove(food);
                                  }
                                }),
                              ),
                            ],
                          ),
                          heading(food.name, size: 24),
                          const SizedBox(height: 5),
                          heading(money(food.cents), size: 21, color: green),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: green,
                                size: 15,
                              ),
                              label(' 1km', size: 10, color: context.muted),
                              const SizedBox(width: 10),
                              TextButton.icon(
                                onPressed: () =>
                                    context.open(Screen.reviews, food: food),
                                icon: const Icon(
                                  Icons.star_rounded,
                                  size: 17,
                                  color: yellow,
                                ),
                                label: label(
                                  '5.0 (34)',
                                  color: context.muted,
                                  size: 11,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Chat Box',
                                onPressed: () => context.open(Screen.chat),
                                icon: Icon(
                                  Icons.chat_bubble_outline,
                                  size: 17,
                                  color: context.muted,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => context.open(Screen.description),
                            child: Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 11,
                                  height: 1.55,
                                  color: context.muted,
                                ),
                                children: [
                                  const TextSpan(text: '$_description '),
                                  const TextSpan(
                                    text: 'Read More',
                                    style: TextStyle(
                                      color: green,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 19),
                          Row(
                            children: [
                              Quantity(
                                value: quantity,
                                change: (delta) => setState(() {
                                  quantity = (quantity + delta).clamp(1, 99);
                                }),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: PrimaryButton('Add To Cart', () {
                                  session.setQuantity(food, quantity);
                                  context.open(Screen.cart);
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Quantity extends StatelessWidget {
  const Quantity({super.key, required this.value, required this.change});
  final int value;
  final ValueChanged<int> change;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _button(context, Icons.remove, -1),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: label('$value', size: 11),
      ),
      _button(context, Icons.add, 1),
    ],
  );

  Widget _button(BuildContext context, IconData icon, int delta) => Semantics(
    button: true,
    label: delta < 0 ? 'Decrease quantity' : 'Increase quantity',
    child: InkWell(
      onTap: () => change(delta),
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 29,
        height: 29,
        decoration: BoxDecoration(
          color: context.softGreen,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 14, color: green),
      ),
    ),
  );
}

class _Promotion extends StatelessWidget {
  const _Promotion({required this.image, this.title, required this.onTap});
  final String image;
  final String? title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        alignment: title == null ? Alignment.center : Alignment.bottomLeft,
        children: [
          Art(image, width: double.infinity, height: 174, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 21,
                    color: Colors.black87,
                  ),
                ),
                if (title != null) ...[
                  const SizedBox(width: 10),
                  label(title!, color: Colors.white, weight: FontWeight.w700),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class DescriptionView extends StatelessWidget {
  const DescriptionView({super.key});

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Description',
    body: listBody([
      _Promotion(
        image: 'description-promotion',
        onTap: () => feedback(context, 'Promotion preview'),
      ),
      const SizedBox(height: 22),
      heading('Information'),
      const SizedBox(height: 5),
      label(
        '$_description Etiam tempor orci eu lobortis elementum.',
        color: context.muted,
      ),
      const SizedBox(height: 20),
      heading('Ingredients'),
      const SizedBox(height: 8),
      for (final (name, grams) in [
        ('Beef', 500),
        ('Garlic', 5),
        ('Onion', 73),
        ('Soy Sauce', 64),
        ('Basil', 3),
      ])
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              label(name, color: context.muted),
              label('$grams g', color: context.muted),
            ],
          ),
        ),
      const SizedBox(height: 11),
      const Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Art('description-art', width: 181),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Art('description-egg', width: 88),
          ),
        ],
      ),
    ]),
  );
}

class ReviewsView extends StatefulWidget {
  const ReviewsView({super.key, required this.food});
  final Food food;
  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  int? minimum;

  @override
  Widget build(BuildContext context) {
    final reviews = [
      ...?context.session.reviews[widget.food]?.reversed,
      const Review(
        'Nathan Cooper',
        'Massa enim nec dui nunc mattis enim ut. Odio eu feugiat pretium nibh ipsum consequat nisl vel pretium.',
        5,
      ),
      const Review(
        'Nathan Cooper',
        'Quam elementum pulvinar etiam non quam lacus suspendisse faucibus interdum. Pretium fusce id velit ut.',
        5,
      ),
      const Review(
        'Nathan Cooper',
        'Tellus cras adipiscing enim eu turpis egestas pretium. Volutpat blandit aliquam etiam erat.',
        5,
      ),
    ];
    final average =
        reviews.fold(0, (sum, review) => sum + review.rating) / reviews.length;
    return PageFrame(
      title: 'Reviews',
      body: listBody([
        Row(
          children: [
            SizedBox(
              width: 92,
              child: Column(
                children: [
                  heading(average.toStringAsFixed(1), size: 30),
                  const _Stars(5, size: 14),
                  label('(34 Reviews)', color: context.muted, size: 9),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                children: [
                  for (var i = 5; i >= 1; i--)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          label('$i', size: 10, color: context.muted),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value:
                                  reviews
                                      .where((review) => review.rating == i)
                                      .length /
                                  reviews.length,
                              minHeight: 5,
                              borderRadius: BorderRadius.circular(6),
                              backgroundColor: context.subtle,
                              color: yellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 7,
          children: [
            for (final item in [null, 5, 4, 3, 2, 1])
              ChoiceChip(
                visualDensity: VisualDensity.compact,
                label: label(item == null ? 'Sort By' : '★ $item', size: 10),
                showCheckmark: false,
                selected: minimum == item,
                onSelected: (_) => setState(() => minimum = item),
              ),
          ],
        ),
        for (final review in reviews.where(
          (review) => minimum == null || review.rating == minimum,
        ))
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ClipOval(child: Art('courier', width: 33)),
                    const SizedBox(width: 8),
                    Expanded(child: heading(review.author, size: 12)),
                    _Stars(review.rating, size: 12),
                  ],
                ),
                const SizedBox(height: 8),
                label(review.message, color: context.muted),
                const SizedBox(height: 5),
                label('3 day ago', color: context.muted, size: 10),
                const Divider(),
              ],
            ),
          ),
      ]),
      bottom: PrimaryButton(
        'Add A Review',
        () => context.open(Screen.addReview, food: widget.food),
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars(this.value, {required this.size, this.change});
  final int value;
  final double size;
  final ValueChanged<int>? change;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) {
      final star = Icon(
        i < value ? Icons.star_rounded : Icons.star_border_rounded,
        size: size,
        color: yellow,
      );
      return change == null
          ? star
          : IconButton(
              icon: star,
              tooltip: '${i + 1} stars',
              visualDensity: VisualDensity.compact,
              onPressed: () => change!(i + 1),
              padding: EdgeInsets.zero,
            );
    }),
  );
}

class AddReviewView extends StatefulWidget {
  const AddReviewView({super.key, required this.food});
  final Food food;
  @override
  State<AddReviewView> createState() => _AddReviewViewState();
}

class _AddReviewViewState extends State<AddReviewView> {
  int rating = 0;
  final message = TextEditingController();

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.session;
    return PageFrame(
      title: 'Add A Review',
      body: listBody([
        Center(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Art(
                  widget.food.image,
                  width: 99,
                  height: 99,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 15),
              heading(widget.food.name, size: 21),
              _Stars(
                rating,
                size: 34,
                change: (value) => setState(() => rating = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        heading('Rating Description'),
        const SizedBox(height: 10),
        FormFieldBox('Message', lines: 2, controller: message),
      ]),
      bottom: PrimaryButton('Submit', () {
        if (rating == 0 || message.text.trim().isEmpty) {
          feedback(context, 'Choose a rating and write a review.');
          return;
        }
        session.update(
          () => session.reviews
              .putIfAbsent(widget.food, () => [])
              .add(
                Review(
                  session.profile['Full Name']!,
                  message.text.trim(),
                  rating,
                ),
              ),
        );
        context.close();
      }),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});
  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final message = TextEditingController();
  final controller = ScrollController();

  @override
  void dispose() {
    message.dispose();
    controller.dispose();
    super.dispose();
  }

  void send() {
    if (message.text.trim().isEmpty) return;
    final session = context.session;
    session.update(() => session.messages.add(message.text.trim()));
    message.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Chat Box',
    actions: [
      RoundIcon(
        Icons.call_outlined,
        tip: 'Call',
        onTap: () => feedback(context, 'No courier call in this demo.'),
      ),
    ],
    body: ListView(
      controller: controller,
      children: [
        Center(child: label('Yesterday', color: context.muted, size: 10)),
        _bubble('Lorem ipsum dolor sit amet, consectetur adipiscing.', false),
        _bubble(
          'Ultrices dui sapien eget mi proin sed. Tempor nec feugiat nisl pretium fusce.',
          false,
        ),
        _bubble(
          'Tristique senectus et netus et. Euismod elementum nisi quis eleifend.',
          true,
        ),
        Center(child: label('Today', color: context.muted, size: 10)),
        _bubble(
          'Arcu odio ut sem nulla. Eros in cursus turpis massa tincidunt dui ut ornare.',
          false,
        ),
        _bubble('Auctor neque vitae tempus quam.', true),
        for (final text in context.session.messages) _bubble(text, true),
      ],
    ),
    bottom: Container(
      decoration: cardDecoration(context, radius: 25),
      child: TextField(
        controller: message,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => send(),
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: 'Type A Message...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(15, 13, 8, 10),
          suffixIcon: IconButton(
            tooltip: 'Send message',
            onPressed: send,
            icon: const Icon(Icons.send_outlined, size: 18, color: green),
          ),
        ),
      ),
    ),
  );

  Widget _bubble(String text, bool own) => Align(
    alignment: own ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      constraints: const BoxConstraints(maxWidth: 269),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: own ? green : context.subtle,
        borderRadius: BorderRadius.circular(11),
      ),
      child: label(text, color: own ? Colors.white : context.ink),
    ),
  );
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    this.onTap,
    this.controller,
    this.filter,
    this.onChange,
    this.onSubmit,
    this.focused = false,
  });
  final VoidCallback? onTap, filter;
  final TextEditingController? controller;
  final ValueChanged<String>? onChange, onSubmit;
  final bool focused;

  @override
  Widget build(BuildContext context) => Container(
    decoration: cardDecoration(context, radius: 24, selected: focused),
    child: TextField(
      readOnly: onTap != null,
      onTap: onTap,
      controller: controller,
      autofocus: focused,
      onChanged: onChange,
      onSubmitted: onSubmit,
      textInputAction: TextInputAction.search,
      style: TextStyle(fontSize: 12, color: context.ink),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        prefixIcon: Icon(Icons.search, size: 18, color: context.muted),
        suffixIcon: filter == null
            ? null
            : IconButton(
                tooltip: 'Filter',
                onPressed: filter,
                icon: Icon(Icons.tune, size: 17, color: context.muted),
              ),
        hintText: 'What are you craving?',
        hintStyle: TextStyle(color: context.muted, fontSize: 11),
      ),
    ),
  );
}

class SearchView extends StatefulWidget {
  const SearchView({super.key, required this.mode});
  final Screen mode;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final TextEditingController input;
  bool editing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (editing) return;
    editing = true;
    input = TextEditingController(
      text: switch (widget.mode) {
        Screen.searchRecommend => 'Burgers',
        Screen.searchResults => context.session.query,
        _ => '',
      },
    );
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void runSearch([String? search]) {
    FocusScope.of(context).unfocus();
    context.session.search(search ?? input.text);
    context.replace(Screen.searchResults);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.session;
    final mode = widget.mode;
    final focused =
        mode == Screen.searchRecent || mode == Screen.searchRecommend;
    final result = mode == Screen.searchResults;
    final shown = session.results;
    final text = input.text.trim().toLowerCase();
    final suggested = [
      ...foods.map((food) => food.name),
      'Angus Burgers',
      'Banquet Burgers',
      'California Burgers',
    ].where((item) => item.toLowerCase().contains(text)).toList();
    const recommendations = [1, 4, 3, 2];

    return PageFrame(
      title: 'Search',
      dismiss: true,
      body: listBody([
        SearchBox(
          controller: input,
          focused: focused,
          onTap: focused ? null : () => context.open(Screen.searchRecent),
          filter: () => _openFilters(context, showResults: !result),
          onChange: (_) => setState(() {}),
          onSubmit: runSearch,
        ),
        const SizedBox(height: 19),
        if (focused)
          for (final suggestion in text.isEmpty ? session.history : suggested)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
              dense: true,
              minTileHeight: 42,
              leading: text.isEmpty
                  ? const Icon(Icons.history, size: 16)
                  : null,
              title: label(suggestion, color: context.muted),
              onTap: () => runSearch(suggestion),
              trailing: text.isEmpty
                  ? IconButton(
                      tooltip: 'Remove $suggestion',
                      icon: const Icon(Icons.close, size: 15),
                      onPressed: () => session.update(
                        () => session.history.remove(suggestion),
                      ),
                    )
                  : null,
            )
        else if (result) ...[
          Row(
            children: [
              heading('Search Result'),
              const SizedBox(width: 5),
              label('(${shown.length} Items)', size: 10, color: green),
            ],
          ),
          const SizedBox(height: 14),
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 34),
              child: label(
                'No dishes matched this search.',
                color: context.muted,
                align: TextAlign.center,
              ),
            )
          else
            FoodGrid(shown),
        ] else ...[
          _Section('Categories', onTap: () => context.open(Screen.categories)),
          const SizedBox(height: 10),
          const CategoryTiles(),
          const SizedBox(height: 15),
          heading('You May Also Like'),
          const SizedBox(height: 12),
          FoodGrid([for (final i in recommendations) foods[i]]),
        ],
      ]),
      bottom: focused ? PrimaryButton('Search', runSearch) : null,
    );
  }
}

class FilterView extends StatefulWidget {
  const FilterView({super.key});
  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  late int? category = context.session.filterCategory;
  late double distance = context.session.distance;
  late double price = context.session.maximumPrice;

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Filter',
    dismiss: true,
    body: listBody([
      _panel(
        context,
        'Categories',
        Wrap(
          children: [
            for (var i = 0; i < categories.length; i++)
              SizedBox(
                width: 132,
                child: InkWell(
                  onTap: () =>
                      setState(() => category = category == i ? null : i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Expanded(child: label(categories[i], size: 11)),
                        Icon(
                          category == i
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          size: 14,
                          color: category == i ? green : context.line,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      _panel(
        context,
        'Location',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Slider(
              value: distance,
              min: 0,
              max: 5,
              divisions: 5,
              onChanged: (value) => setState(() => distance = value),
            ),
            label(
              'Distance: 0 - ${distance.round()}km',
              color: context.muted,
              size: 10,
            ),
          ],
        ),
      ),
      _panel(
        context,
        'Price',
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Slider(
              value: price,
              min: 0,
              max: 50,
              divisions: 50,
              onChanged: (value) => setState(() => price = value),
            ),
            label(
              'Filter Price: \$0 - \$${price.round()}',
              color: context.muted,
              size: 10,
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const SizedBox(
        height: 161,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Art('filter-fish', width: 91),
            ),
            Align(
              alignment: Alignment.center,
              child: Art('filter-egg', width: 46),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Art('filter-person', height: 161),
            ),
          ],
        ),
      ),
    ]),
    bottom: PrimaryButton('Apply Filters', () {
      final session = context.session;
      session.update(() {
        session.filterCategory = category;
        session.distance = distance;
        session.maximumPrice = price;
      });
      if (Navigator.of(context).canPop()) {
        context.close(true);
      } else {
        context.replace(Screen.searchResults);
      }
    }),
  );

  Widget _panel(BuildContext context, String title, Widget content) =>
      Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(13),
        decoration: cardDecoration(context, radius: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading(title, size: 16),
            const SizedBox(height: 6),
            content,
          ],
        ),
      );
}
