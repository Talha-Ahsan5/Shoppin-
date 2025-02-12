import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopin/data/categories.dart';
// import 'package:shopin/data/dummy_items.dart';
import 'package:shopin/models/category.dart';
// import 'package:shopin/models/grocery_items.dart';
import 'package:http/http.dart' as http;
import 'package:shopin/models/grocery_items.dart';

class NewItems extends StatefulWidget {
  const NewItems({super.key});
  @override
  State<NewItems> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItems> {
  final _formkey = GlobalKey<FormState>();
  var _getName = '';
  var _getQuantity = 1;
  var _getcategories = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url =
          Uri.https('shopin-cebf6-default-rtdb.firebaseio.com', 'shopin.json');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'Application/json'},
        body: json.encode(
          {
            'name': _getName,
            'quantity': _getQuantity,
            'category': _getcategories.title,
          },
        ),
      );

      if (!context.mounted) {
        return;
      }

      final Map<String, dynamic> resbodyforid = json.decode(response.body);
      // print(response.body);
      // print(response.statusCode);

      // Navigator.of(context).pop(
      //   GroceryItem(
      //       id: DateTime.now().toString(),
      //       name: _getName,
      //       quantity: _getQuantity,
      //       category: _getcategories!),
      // );
      Navigator.of(context).pop(
        GroceryItem(
            id: resbodyforid["name"],
            name: _getName,
            quantity: _getQuantity,
            category: _getcategories),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Items"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text("Name"),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Name must be valid or 1 till 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  // if(Value == null){
                  //   _getName = Value!;
                  // }
                  _getName = value!;
                },
              ), //instead of textField
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text("Quantity"),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Quantity must be positive or cannot be leave empty";
                        }
                        return null;
                      },
                      initialValue: _getQuantity.toString(),
                      onSaved: (value) {
                        _getQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _getcategories,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (values) {
                        setState(() {
                          _getcategories = values!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formkey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Save Item'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
