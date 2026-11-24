import 'package:flutter/foundation.dart';

enum Screen {
  splash,
  intro1,
  intro2,
  intro3,
  intro4,
  signIn,
  signUp,
  verify,
  verifyCode,
  forgot,
  newPassword,
  setupProfile,
  initialLocation,
  home,
  categories,
  deal,
  offers,
  product,
  description,
  reviews,
  addReview,
  chat,
  cartEmpty,
  cart,
  checkout,
  voucher,
  address,
  addAddress,
  setLocation,
  payment,
  addCard,
  tracking,
  scan,
  success,
  account,
  editProfile,
  notifications,
  markNotifications,
  search,
  searchRecent,
  searchRecommend,
  searchResults,
  filter,
}

class Food {
  const Food(
    this.name,
    this.image,
    this.category, [
    this.cents = 399,
    this.hero,
  ]);
  final String name, image;
  final int category, cents;
  final String? hero;
}

const foods = [
  Food('Buffalo Chicken Dip', 'buffalo', 2),
  Food('Baked Spaghetti', 'spaghetti', 3),
  Food('Maltesers Tiramisu', 'tiramisu', 0),
  Food('Backyard Burgers', 'backyard', 6),
  Food('Sirloin steak', 'steak', 3, 399, 'steak-hero'),
  Food('Canadian Lobster', 'lobster', 7),
  Food('Seafood Som Tum', 'deal', 7, 259),
];

const categories = [
  'Dessert',
  'Lunch',
  'Appetizers',
  'Main Course',
  'Drink',
  'Vegetable',
  'Fast Food',
  'Sea Food',
];

const demoLocation = '6391 Elgin St. Celina, Delaware 10299';

String money(int cents) => '\$ ${(cents / 100).toStringAsFixed(2)}';

class Address {
  const Address(this.name, this.street);
  final String name, street;
}

class Review {
  const Review(this.author, this.message, this.rating);
  final String author, message;
  final int rating;
}

class DemoOrder {
  const DemoOrder(this.number, this.total);
  final int number, total;
}

class Session extends ChangeNotifier {
  Session({this.dark = false});

  bool dark;
  bool recovery = false;
  bool rememberMe = true;
  bool privacy = true;
  int addressIndex = 0, paymentIndex = 0, voucherIndex = 0;
  int? filterCategory;
  double distance = 5, maximumPrice = 50;
  String query = '';
  String verificationEmail = 'kenzi.lawson@example.com';
  String? location;

  final profile = <String, String>{
    'Full Name': 'Adan Lauzon',
    'Nick Name': 'Lauzonn123',
    'Email': 'Tim.jennings@example.com',
    'Date Of Birth': 'Aug 21, 1992',
    'Gender': 'Men',
    'Region': 'United States',
  };
  final addresses = <Address>[
    const Address('Home', '2715 Ash Dr. San Jose, South Dakota'),
    const Address('My Office', '3517 W. Gray St. Utica, Pennsylvania'),
    const Address('Parent’s House', demoLocation),
    const Address('Home 02', '2972 Westheimer Rd. Santa Ana, Illinois'),
    const Address(
      'Brother’s Home',
      '4517 Washington Ave. Manchester, Kentucky',
    ),
  ];
  final payments = [
    'Master Card',
    'PayPal',
    'Visa',
    'ApplePay',
    'Payment on delivery',
  ];
  final history = [
    'Backyard Burgers',
    'Sirloin steak',
    'Baked Spaghetti',
    'Maltesers Tiramisu',
  ];
  final messages = <String>[];
  final reviews = <Food, List<Review>>{};
  final favorites = <Food>{};
  final readNotifications = <int>{3, 4};
  final notificationSelection = <int>{};
  final cart = <Food, int>{};
  DemoOrder? order;

  Address get address => addresses[addressIndex];
  int get subtotal =>
      cart.entries.fold(0, (total, row) => total + row.key.cents * row.value);
  int get discount => switch (voucherIndex) {
    1 => (subtotal * .2).round(),
    2 => (subtotal * .3).round(),
    3 => cart.entries.fold(
      0,
      (total, row) => total + row.key.cents * (row.value ~/ 2),
    ),
    4 => (subtotal * .5).round(),
    _ => 0,
  };
  int get total => subtotal - discount;

  List<Food> get results {
    final search = query.trim().toLowerCase();
    return foods
        .where(
          (item) =>
              (item.name.toLowerCase().contains(search) ||
                  categories[item.category].toLowerCase().contains(search)) &&
              (filterCategory == null || item.category == filterCategory) &&
              item.cents <= maximumPrice * 100 &&
              distance >= 1,
        )
        .toList();
  }

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  void setQuantity(Food item, int delta) => update(() {
    final quantity = (cart[item] ?? 0) + delta;
    if (quantity <= 0) {
      cart.remove(item);
    } else {
      cart[item] = quantity;
    }
  });

  void search(String value) => update(() {
    query = value.trim();
    if (query.isEmpty) return;
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
    history.insert(0, query);
  });

  void placeOrder() {
    if (cart.isEmpty) return;
    update(() {
      order = DemoOrder((order?.number ?? 1234566) + 1, total);
      cart.clear();
      voucherIndex = 0;
    });
  }

  void signOut() => update(() {
    cart.clear();
    favorites.clear();
    messages.clear();
    reviews.clear();
    notificationSelection.clear();
    order = null;
    query = '';
    filterCategory = null;
    voucherIndex = 0;
    distance = 5;
    maximumPrice = 50;
  });
}
