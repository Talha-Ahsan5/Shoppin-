import 'package:shopin/data/categories.dart';
import 'package:shopin/models/grocery_items.dart';
import 'package:shopin/models/category.dart';

 final groceryItems = [
  GroceryItem(
      id: 'a',
      name: 'Appliances',
      quantity: 10,
      category: categories[Categories.dairy]!),
  GroceryItem(
      id: 'b',
      name: 'Clothes',
      quantity: 20,
      category: categories[Categories.fruit]!),
  GroceryItem(
      id: 'c',
      name: 'Music',
      quantity: 75,
      category: categories[Categories.meat]!),
];
