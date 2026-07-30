import 'dart:math';

class VendorMenuItem {
  final String id;
  String name;
  double price;
  double? specialPrice;
  String description;
  int prepTimeMins;
  String priceCategory;
  String cuisineCategory;
  bool isOutOfStock;
  bool isTodaysSpecial;
  double rating;
  int reviewCount;

  VendorMenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.specialPrice,
    required this.description,
    required this.prepTimeMins,
    required this.priceCategory,
    required this.cuisineCategory,
    this.isOutOfStock = false,
    this.isTodaysSpecial = false,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  static String generateId() => Random().nextInt(99999).toString();
}

List<VendorMenuItem> getSampleMenuItems() => [
  VendorMenuItem(
    id: 'v1',
    name: 'Paneer Tikka Sandwich',
    price: 80,
    specialPrice: 65,
    description: 'Grilled paneer with fresh veggies in toasted bread',
    prepTimeMins: 10,
    priceCategory: 'Under ₹99',
    cuisineCategory: 'North Indian',
    isTodaysSpecial: true,
    rating: 4.5,
    reviewCount: 120,
  ),
  VendorMenuItem(
    id: 'v2',
    name: 'Cold Coffee with Ice Cream',
    price: 70,
    description: 'Chilled blended coffee topped with vanilla ice cream',
    prepTimeMins: 5,
    priceCategory: 'Under ₹99',
    cuisineCategory: 'Beverages',
    isTodaysSpecial: true,
    rating: 4.8,
    reviewCount: 210,
  ),
  VendorMenuItem(
    id: 'v3',
    name: 'Cheese Burst Pizza',
    price: 140,
    specialPrice: 120,
    description: 'Loaded with mozzarella cheese and fresh garden veggies',
    prepTimeMins: 15,
    priceCategory: 'Under ₹149',
    cuisineCategory: 'Italian',
    rating: 4.3,
    reviewCount: 85,
  ),
  VendorMenuItem(
    id: 'v4',
    name: 'Aloo Tikki Burger',
    price: 70,
    description: 'Crispy potato patty with tangy chutney and fresh veggies',
    prepTimeMins: 8,
    priceCategory: 'Under ₹99',
    cuisineCategory: 'Fast Food',
    isOutOfStock: true,
    rating: 4.1,
    reviewCount: 67,
  ),
  VendorMenuItem(
    id: 'v5',
    name: 'Veg Hakka Noodles',
    price: 90,
    description: 'Wok tossed noodles with crisp seasonal vegetables',
    prepTimeMins: 12,
    priceCategory: 'Under ₹99',
    cuisineCategory: 'Chinese',
    rating: 4.4,
    reviewCount: 95,
  ),
  VendorMenuItem(
    id: 'v6',
    name: 'Masala Dosa',
    price: 80,
    specialPrice: 60,
    description: 'Crispy dosa with spiced potato filling and coconut chutney',
    prepTimeMins: 10,
    priceCategory: 'Under ₹99',
    cuisineCategory: 'South Indian',
    rating: 4.6,
    reviewCount: 140,
  ),
];
