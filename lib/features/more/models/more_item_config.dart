import 'package:flutter/material.dart';

class MoreItemConfig {
  final String title;
  final String? subtitle;
  final IconData icon;
  final WidgetBuilder destination;

  const MoreItemConfig({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.destination,
  });
}

class MoreSectionConfig {
  final String header;
  final List<MoreItemConfig> items;

  const MoreSectionConfig({
    required this.header,
    required this.items,
  });
}
