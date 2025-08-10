import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final TabController controller;
  final List<String> categories;

  const CategoryTabs({
    Key? key,
    required this.controller,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 48,
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: controller,
        isScrollable: true,
        indicatorColor: theme.colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: categories.map((category) => Tab(text: category)).toList(),
      ),
    );
  }
}