class FoodCategory {
  final String id;
  final String name;
  final String icon;

  const FoodCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class BannerOffer {
  final String id;
  final String title;
  final String subtitle;
  final String code;
  final String colorHex;

  const BannerOffer({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.code,
    required this.colorHex,
  });
}

class MenuItem {
  final String id;
  final String name;
  final double price;
  final double? specialPrice;
  final String description;
  final double rating;
  final int reviewsCount;
  final String category;
  final bool isVeg;
  final int prepTimeMins;

  const MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.specialPrice,
    required this.description,
    required this.rating,
    required this.reviewsCount,
    required this.category,
    this.isVeg = true,
    required this.prepTimeMins,
  });
}

class Canteen {
  final String id;
  final String name;
  final double rating;
  final int ratingCount;
  final String prepTimeEstimate;
  final String priceForTwo;
  final bool isAvailable;
  final String tag;
  final List<MenuItem> menuItems;

  const Canteen({
    required this.id,
    required this.name,
    required this.rating,
    required this.ratingCount,
    required this.prepTimeEstimate,
    required this.priceForTwo,
    this.isAvailable = true,
    required this.tag,
    required this.menuItems,
  });
}

class CanteenData {
  static const List<FoodCategory> categories = [
    FoodCategory(id: 'cat_1', name: 'Momos', icon: '🥟'),
    FoodCategory(id: 'cat_2', name: 'Burgers', icon: '🍔'),
    FoodCategory(id: 'cat_3', name: 'Pasta', icon: '🍝'),
    FoodCategory(id: 'cat_4', name: 'Shakes & Drinks', icon: '🥤'),
    FoodCategory(id: 'cat_5', name: 'Rolls & Wraps', icon: '🌯'),
    FoodCategory(id: 'cat_6', name: 'Thali & Meals', icon: '🍱'),
    FoodCategory(id: 'cat_7', name: 'Snacks & Fries', icon: '🍟'),
  ];

  static const List<BannerOffer> banners = [
    BannerOffer(
      id: 'b1',
      title: 'FLAT ₹99 MEALS',
      subtitle: 'Exclusive student combo at Bunny\'s Kitchen',
      code: 'PIET99',
      colorHex: '0xFFFF6347',
    ),
    BannerOffer(
      id: 'b2',
      title: 'EXAM SNACK ATTACK',
      subtitle: 'Free Cold Coffee on orders above ₹149',
      code: 'STUDYHARD',
      colorHex: '0xFF4A90E2',
    ),
    BannerOffer(
      id: 'b3',
      title: 'ZERO DELIVERY FEE',
      subtitle: 'Student deliverers walking to Block A & B',
      code: 'WALK2EARN',
      colorHex: '0xFF28A745',
    ),
  ];

  static final List<Canteen> canteens = [
    Canteen(
      id: 'c1',
      name: "Bunny's Kitchen",
      rating: 4.6,
      ratingCount: 340,
      prepTimeEstimate: '10-12 mins',
      priceForTwo: '₹150 for two',
      tag: 'Best Combos',
      menuItems: const [
        MenuItem(
          id: 'm1',
          name: 'Crispy Veg Burger + Fries',
          price: 99,
          description: 'Loaded crunchy patty burger served with seasoned peri-peri fries.',
          rating: 4.7,
          reviewsCount: 120,
          category: 'Burgers',
          prepTimeMins: 10,
        ),
        MenuItem(
          id: 'm2',
          name: 'Steam Paneer Momos (8 pcs)',
          price: 110,
          description: 'Fresh paneer stuffed momos served with fiery red chilli sauce.',
          rating: 4.8,
          reviewsCount: 210,
          category: 'Momos',
          prepTimeMins: 8,
        ),
        MenuItem(
          id: 'm3',
          name: 'Cheese White Sauce Pasta',
          price: 130,
          description: 'Creamy penne pasta infused with oregano, chilli flakes & mozzarella.',
          rating: 4.5,
          reviewsCount: 95,
          category: 'Pasta',
          prepTimeMins: 12,
        ),
        MenuItem(
          id: 'm4',
          name: 'Oreo Thick Shake',
          price: 80,
          description: 'Rich chocolate milkshake blended with crunchy Oreo cookies.',
          rating: 4.6,
          reviewsCount: 150,
          category: 'Shakes & Drinks',
          prepTimeMins: 5,
        ),
      ],
    ),
    Canteen(
      id: 'c2',
      name: 'Froot Shoot',
      rating: 4.7,
      ratingCount: 420,
      prepTimeEstimate: '5-10 mins',
      priceForTwo: '₹120 for two',
      tag: 'Fresh Juices & Shakes',
      menuItems: const [
        MenuItem(
          id: 'm5',
          name: 'Cold Coffee with Ice Cream',
          price: 70,
          description: 'Classic brewed cold coffee topped with thick vanilla ice cream.',
          rating: 4.9,
          reviewsCount: 310,
          category: 'Shakes & Drinks',
          prepTimeMins: 5,
        ),
        MenuItem(
          id: 'm6',
          name: 'Fresh Mango Smoothie',
          price: 90,
          description: 'Seasonal thick mango puree blended with chilled milk.',
          rating: 4.7,
          reviewsCount: 180,
          category: 'Shakes & Drinks',
          prepTimeMins: 5,
        ),
        MenuItem(
          id: 'm7',
          name: 'Fruit Salad Bowl',
          price: 85,
          description: 'Assorted seasonal fresh fruits topped with chat masala & lemon juice.',
          rating: 4.4,
          reviewsCount: 88,
          category: 'Snacks & Fries',
          prepTimeMins: 6,
        ),
      ],
    ),
    Canteen(
      id: 'c3',
      name: 'One Stop',
      rating: 4.3,
      ratingCount: 210,
      prepTimeEstimate: '10-15 mins',
      priceForTwo: '₹180 for two',
      tag: 'Quick Snacks & Rolls',
      menuItems: const [
        MenuItem(
          id: 'm8',
          name: 'Paneer Kathi Roll',
          price: 120,
          description: 'Spiced marinated paneer tikka wrapped in a crisp paratha.',
          rating: 4.6,
          reviewsCount: 140,
          category: 'Rolls & Wraps',
          prepTimeMins: 10,
        ),
        MenuItem(
          id: 'm9',
          name: 'Chilli Garlic Noodles',
          price: 110,
          description: 'Wok tossed hakka noodles with spicy garlic seasoning.',
          rating: 4.2,
          reviewsCount: 95,
          category: 'Meals',
          prepTimeMins: 12,
        ),
      ],
    ),
    Canteen(
      id: 'c4',
      name: 'College Cafe',
      rating: 4.1,
      ratingCount: 180,
      prepTimeEstimate: '15-20 mins',
      priceForTwo: '₹200 for two',
      tag: 'Hangout Spot',
      menuItems: const [
        MenuItem(
          id: 'm10',
          name: 'Executive Veg Thali',
          price: 140,
          description: 'Paneer butter masala, dal makhani, 3 rotis, rice & salad.',
          rating: 4.4,
          reviewsCount: 230,
          category: 'Thali & Meals',
          prepTimeMins: 15,
        ),
        MenuItem(
          id: 'm11',
          name: 'Stuffed Aloo Paratha with Curd',
          price: 75,
          description: '2 hot crispy aloo parathas served with fresh curd & pickle.',
          rating: 4.5,
          reviewsCount: 190,
          category: 'Thali & Meals',
          prepTimeMins: 12,
        ),
      ],
    ),
    Canteen(
      id: 'c5',
      name: 'Cafe14',
      rating: 4.6,
      ratingCount: 290,
      prepTimeEstimate: '10-15 mins',
      priceForTwo: '₹160 for two',
      tag: 'Top Rated Pizza',
      menuItems: const [
        MenuItem(
          id: 'm12',
          name: 'Farmhouse Special Pizza (7 inch)',
          price: 160,
          description: 'Capsicum, onion, tomato, corn & extra cheese blend.',
          rating: 4.8,
          reviewsCount: 175,
          category: 'Snacks & Fries',
          prepTimeMins: 14,
        ),
        MenuItem(
          id: 'm13',
          name: 'Garlic Breadstix with Dip',
          price: 99,
          description: 'Freshly baked garlic bread sticks with cheesy jalapeño dip.',
          rating: 4.6,
          reviewsCount: 110,
          category: 'Snacks & Fries',
          prepTimeMins: 10,
        ),
      ],
    ),
    Canteen(
      id: 'c6',
      name: 'Nescafe',
      rating: 4.2,
      ratingCount: 150,
      prepTimeEstimate: '8-12 mins',
      priceForTwo: '₹100 for two',
      tag: 'Quick Coffee & Maggi',
      menuItems: const [
        MenuItem(
          id: 'm14',
          name: 'Butter Cheese Maggi',
          price: 60,
          description: 'Double maggi cooked with extra butter, cheese slice & oregano.',
          rating: 4.5,
          reviewsCount: 220,
          category: 'Snacks & Fries',
          prepTimeMins: 8,
        ),
        MenuItem(
          id: 'm15',
          name: 'Hot Espresso Coffee',
          price: 40,
          description: 'Frothy hot coffee to keep you active during classes.',
          rating: 4.3,
          reviewsCount: 140,
          category: 'Shakes & Drinks',
          prepTimeMins: 5,
        ),
      ],
    ),
    Canteen(
      id: 'c7',
      name: 'Old Canteen',
      rating: 4.0,
      ratingCount: 310,
      prepTimeEstimate: '12-18 mins',
      priceForTwo: '₹110 for two',
      tag: 'Budget Student Eats',
      menuItems: const [
        MenuItem(
          id: 'm16',
          name: 'Chole Bhature (2 pcs)',
          price: 90,
          description: 'Authentic spicy chole served with fluffy hot bhature.',
          rating: 4.4,
          reviewsCount: 290,
          category: 'Thali & Meals',
          prepTimeMins: 12,
        ),
        MenuItem(
          id: 'm17',
          name: 'Samosa Chat (2 pcs)',
          price: 45,
          description: 'Crushed samosas topped with chole, sweet chutney & curd.',
          rating: 4.3,
          reviewsCount: 180,
          category: 'Snacks & Fries',
          prepTimeMins: 5,
        ),
      ],
    ),
    Canteen(
      id: 'c8',
      name: "Deepak's Cafe",
      rating: 4.4,
      ratingCount: 195,
      prepTimeEstimate: '10-15 mins',
      priceForTwo: '₹140 for two',
      tag: 'Popular Sandwich Hub',
      menuItems: const [
        MenuItem(
          id: 'm18',
          name: 'Grilled Cheese Corn Sandwich',
          price: 85,
          description: 'Golden toasted bread stuffed with sweet corn and melted cheese.',
          rating: 4.6,
          reviewsCount: 165,
          category: 'Snacks & Fries',
          prepTimeMins: 10,
        ),
        MenuItem(
          id: 'm19',
          name: 'Veg Club Sandwich',
          price: 110,
          description: '3-layer loaded sandwich with cucumber, tomato, paneer & mayo.',
          rating: 4.4,
          reviewsCount: 105,
          category: 'Snacks & Fries',
          prepTimeMins: 12,
        ),
      ],
    ),
    Canteen(
      id: 'c9',
      name: 'College Mess',
      rating: 3.8,
      ratingCount: 90,
      prepTimeEstimate: 'N/A',
      priceForTwo: '₹100 for two',
      isAvailable: false, // Marked as Unavailable
      tag: 'Hostel Mess (Coming Soon)',
      menuItems: const [],
    ),
  ];

  static List<MenuItem> get topPicks {
    final List<MenuItem> items = [];
    for (var c in canteens) {
      if (c.isAvailable && c.menuItems.isNotEmpty) {
        items.add(c.menuItems.first);
      }
    }
    return items;
  }
}
