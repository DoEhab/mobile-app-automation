import 'package:app_automation/features/categories/presentation/category_links_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_automation/features/Categories/presentation/widgets/category_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<String> categories = [
    'Lifestyle',
    'Makeup',
    'Home Essentials',
    'Books',
    'Fashion',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            return CategoryCard(
              title: categories[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CategoryLinksScreen(categoryName: categories[index]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
