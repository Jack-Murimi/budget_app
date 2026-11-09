import 'package:flutter/material.dart';

class CategoryIconHelper {
  static IconData getIcon(String? iconName, {String? type}) {
    if (iconName == null || iconName.isEmpty || iconName == 'category') {
      return switch (type) {
        'income' => Icons.arrow_downward_rounded,
        'transfer' => Icons.swap_horiz_rounded,
        _ => Icons.arrow_upward_rounded,
      };
    }

    return switch (iconName) {
      'restaurant' => Icons.restaurant,
      'fastfood' => Icons.fastfood,
      'local_cafe' => Icons.local_cafe,
      'local_bar' => Icons.local_bar,
      'local_grocery_store' => Icons.local_grocery_store,
      'directions_car' => Icons.directions_car,
      'directions_bus' => Icons.directions_bus,
      'local_gas_station' => Icons.local_gas_station,
      'local_taxi' => Icons.local_taxi,
      'local_parking' => Icons.local_parking,
      'flight' => Icons.flight,
      'build' => Icons.build,
      'shopping_bag' => Icons.shopping_bag,
      'shopping_cart' => Icons.shopping_cart,
      'checkroom' => Icons.checkroom,
      'devices' => Icons.devices,
      'chair' => Icons.chair,
      'face' => Icons.face,
      'receipt_long' => Icons.receipt_long,
      'water_drop' => Icons.water_drop,
      'bolt' => Icons.bolt,
      'wifi' => Icons.wifi,
      'home' => Icons.home,
      'tv' => Icons.tv,
      'local_fire_department' => Icons.local_fire_department,
      'phone_android' => Icons.phone_android,
      'security' => Icons.security,
      'movie' => Icons.movie,
      'theaters' => Icons.theaters,
      'sports_soccer' => Icons.sports_soccer,
      'videogame_asset' => Icons.videogame_asset,
      'theater_comedy' => Icons.theater_comedy,
      'music_note' => Icons.music_note,
      'favorite' => Icons.favorite,
      'medication' => Icons.medication,
      'local_hospital' => Icons.local_hospital,
      'fitness_center' => Icons.fitness_center,
      'school' => Icons.school,
      'work' => Icons.work,
      'savings' => Icons.savings,
      'attach_money' => Icons.attach_money,
      'more_horiz' => Icons.more_horiz,
      'swap_horiz' => Icons.swap_horiz,
      'send' => Icons.send,
      'sync' => Icons.sync,
      'handshake' => Icons.handshake_outlined,
      'account_balance' => Icons.account_balance,
      _ => Icons.category_outlined,
    };
  }

  /// Maps category name to its intended default icon when icon is 'category'
  static String defaultIconForName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('grocer')) return 'local_grocery_store';
    if (lower.contains('restaurant') || lower.contains('food') || lower.contains('dining')) return 'restaurant';
    if (lower.contains('cafe') || lower.contains('coffee')) return 'local_cafe';
    if (lower.contains('fast food')) return 'fastfood';
    if (lower.contains('bar') || lower.contains('alcohol')) return 'local_bar';
    if (lower.contains('fuel') || lower.contains('petrol')) return 'local_gas_station';
    if (lower.contains('car') || lower.contains('transport')) return 'directions_car';
    if (lower.contains('bus') || lower.contains('matatu')) return 'directions_bus';
    if (lower.contains('taxi') || lower.contains('uber')) return 'local_taxi';
    if (lower.contains('flight') || lower.contains('travel')) return 'flight';
    if (lower.contains('parking')) return 'local_parking';
    if (lower.contains('repair')) return 'build';
    if (lower.contains('shop') || lower.contains('clothing') || lower.contains('electronic')) return 'shopping_bag';
    if (lower.contains('bill') || lower.contains('utilit')) return 'receipt_long';
    if (lower.contains('water')) return 'water_drop';
    if (lower.contains('electricity') || lower.contains('kplc') || lower.contains('power')) return 'bolt';
    if (lower.contains('wifi') || lower.contains('internet')) return 'wifi';
    if (lower.contains('rent') || lower.contains('home')) return 'home';
    if (lower.contains('tv') || lower.contains('dstv')) return 'tv';
    if (lower.contains('entertain') || lower.contains('movie')) return 'movie';
    if (lower.contains('sport')) return 'sports_soccer';
    if (lower.contains('health') || lower.contains('hospital')) return 'local_hospital';
    if (lower.contains('pharmacy') || lower.contains('medication')) return 'medication';
    if (lower.contains('educat') || lower.contains('school')) return 'school';
    if (lower.contains('saving')) return 'savings';
    if (lower.contains('income') || lower.contains('salary')) return 'attach_money';
    if (lower.contains('loan')) return 'handshake';
    if (lower.contains('transfer')) return 'swap_horiz';
    return 'category';
  }
}
