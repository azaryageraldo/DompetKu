import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryIcon extends StatelessWidget {
  final Category category;
  final double size;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 40,
  });

  IconData _getIconData(String iconName) {
    final iconMap = {
      'card_giftcard': Icons.card_giftcard,
      'account_balance_wallet': Icons.account_balance_wallet,
      'star': Icons.star,
      'redeem': Icons.redeem,
      'restaurant': Icons.restaurant,
      'local_cafe': Icons.local_cafe,
      'directions_car': Icons.directions_car,
      'phone_android': Icons.phone_android,
      'movie': Icons.movie,
      'shopping_bag': Icons.shopping_bag,
      'home': Icons.home,
      'school': Icons.school,
      'medical_services': Icons.medical_services,
      'fitness_center': Icons.fitness_center,
      'pets': Icons.pets,
      'flight': Icons.flight,
      'hotel': Icons.hotel,
      'shopping_cart': Icons.shopping_cart,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Color _getColor(String colorHex) {
    try {
      return Color(int.parse('0xFF$colorHex'));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _getColor(category.color).withOpacity(0.1),
      child: Icon(
        _getIconData(category.icon),
        color: _getColor(category.color),
        size: size * 0.5,
      ),
    );
  }
}
