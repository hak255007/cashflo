// lib/category_icons.dart
import 'package:flutter/material.dart';

class CategoryStyle {
  final IconData icon;
  final Color color;
  const CategoryStyle(this.icon, this.color);
}

const Map<String, CategoryStyle> kCategoryStyles = {
  'Groceries': CategoryStyle(Icons.shopping_basket, Color(0xff43A047)),
  'Rent': CategoryStyle(Icons.home, Color(0xff6D4C41)),
  'Investments': CategoryStyle(Icons.trending_up, Color(0xff00897B)),
  'Fuel': CategoryStyle(Icons.local_gas_station, Color(0xffF4511E)),
  'Food & Dining': CategoryStyle(Icons.restaurant, Color(0xffFB8C00)),
  'Hotels & Stay': CategoryStyle(Icons.hotel, Color(0xff8E24AA)),
  'Travel & Transport': CategoryStyle(Icons.directions_bus, Color(0xff1E88E5)),
  'Utilities & Bills': CategoryStyle(Icons.receipt_long, Color(0xff546E7A)),
  'Shopping': CategoryStyle(Icons.shopping_bag, Color(0xffD81B60)),
  'Entertainment': CategoryStyle(Icons.movie, Color(0xff5E35B1)),
  'Health & Medical': CategoryStyle(Icons.medical_services, Color(0xffE53935)),
  'Education': CategoryStyle(Icons.school, Color(0xff3949AB)),
  'Insurance': CategoryStyle(Icons.verified_user, Color(0xff039BE5)),
  'EMI & Loans': CategoryStyle(Icons.account_balance, Color(0xff795548)),
  'Subscriptions': CategoryStyle(Icons.subscriptions, Color(0xff00ACC1)),
  'Personal Care': CategoryStyle(Icons.spa, Color(0xffEC407A)),
  'Gifts & Donations': CategoryStyle(Icons.card_giftcard, Color(0xffFFB300)),
  'Other': CategoryStyle(Icons.category, Color(0xff757575)),
};

/// Fallback for old expenses with no category, or unknown categories.
const CategoryStyle kDefaultCategoryStyle =
    CategoryStyle(Icons.receipt_long, Color(0xff087E8B));

CategoryStyle styleForCategory(String? category) =>
    kCategoryStyles[category] ?? kDefaultCategoryStyle;
