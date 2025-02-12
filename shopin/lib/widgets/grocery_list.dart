import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopin/data/categories.dart';
// import 'package:shopin/data/dummy_items.dart';
// import 'package:shopin/data/dummy_items.dart';
import 'package:shopin/models/grocery_items.dart';
import 'package:shopin/widgets/new_items.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItem = [];
  var _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url =
        Uri.https('shopin-cebf6-default-rtdb.firebaseio.com', 'shopin.json');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }
      //handling loading spinner state if list contains no data
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      // print(response.body); // to know the error if list contains no data
      final Map<String, dynamic> listedData = json.decode(response.body);
      List<GroceryItem> loadedItems = [];
      for (final item in listedData.entries) {
        final category = categories.entries
            .firstWhere(
              (categoryItem) =>
                  categoryItem.value.title == item.value['category'],
            )
            .value;
        loadedItems.add(
          GroceryItem(
              id: item.key,
              name: item.value['name'],
              quantity: item.value['quantity'],
              category: category),
        );
      }
      setState(() {
        _groceryItem = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later.';
      });
    }
  }

  void _addItems() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItems(),
      ),
    );

    //In case user pressed the back button
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItem.add(newItem);
    });

    // _loadItems();
  }

  void _removeList(GroceryItem item) async {
    final index = _groceryItem.indexOf(
        item); //if error ocurred thats why write this code otherwise we dont need async await in deletion
    setState(() {
      _groceryItem.remove(item);
    });
    final url = Uri.https(
        'shopin-cebf6-default-rtdb.firebaseio.com', 'shopin/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      //optional: show error message
      setState(() {
        _groceryItem.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet!'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (context, index) => Dismissible(
          onDismissed: (direction) {
            _removeList(_groceryItem[index]);
          },
          key: ValueKey(_groceryItem[index].id),
          child: ListTile(
            title: Text(_groceryItem[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItem[index].category.color,
            ),
            trailing: Text(
              _groceryItem[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "What's been up?",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _addItems();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
