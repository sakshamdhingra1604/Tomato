import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final int prepTimeMins;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.prepTimeMins,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
        'menuItemId': id,
        'quantity': quantity,
      };
}

class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final Map<String, CartItem> _items = {};
  String? _currentVendorId;
  String? _currentVendorName;

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  Map<String, CartItem> get items => _items;
  String? get vendorId => _currentVendorId;
  String? get vendorName => _currentVendorName;

  int get totalItems {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _items.values.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  void addItem({
    required String id,
    required String name,
    required double price,
    required String description,
    required int prepTimeMins,
    required String vendorId,
    required String vendorName,
  }) {
    if (_currentVendorId != null && _currentVendorId != vendorId) {
      _items.clear();
    }
    _currentVendorId = vendorId;
    _currentVendorName = vendorName;

    if (_items.containsKey(id)) {
      _items[id]!.quantity += 1;
    } else {
      _items[id] = CartItem(
        id: id,
        name: name,
        price: price,
        description: description,
        prepTimeMins: prepTimeMins,
        quantity: 1,
      );
    }
    _notifyListeners();
  }

  void removeItem(String id) {
    if (_items.containsKey(id)) {
      if (_items[id]!.quantity > 1) {
        _items[id]!.quantity -= 1;
      } else {
        _items.remove(id);
      }
    }
    if (_items.isEmpty) {
      _currentVendorId = null;
      _currentVendorName = null;
    }
    _notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _currentVendorId = null;
    _currentVendorName = null;
    _notifyListeners();
  }
}
