import 'package:cj/models/StockItem.dart';
import 'package:cj/services/shop/StockItemService.dart';
import 'package:flutter/material.dart';


class ItemNameDropdown extends StatefulWidget {
  final TextEditingController controller;

  const ItemNameDropdown({Key? key, required this.controller}) : super(key: key);

  @override
  _ItemNameDropdownState createState() => _ItemNameDropdownState();
}

class _ItemNameDropdownState extends State<ItemNameDropdown> {
  List<StockItem> _stockItems = [];
  bool _isLoading = true;
  final StockItemService _stockItemService = StockItemService();

  @override
  void initState() {
    super.initState();
    _loadStockItems();
  }

  Future<void> _loadStockItems() async {
    try {
      List<StockItem> items = await _stockItemService.fetchStockItems();
      setState(() {
        _stockItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load item names: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_stockItems.isEmpty) {
          await _loadStockItems();
        }
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _stockItems.length,
                    itemBuilder: (context, index) {
                      final item = _stockItems[index];
                      return ListTile(
                        title: Center(child: Text(item.itemName)),
                        onTap: () {
                          widget.controller.text = item.itemName;
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
          },
        );
      },
      child: AbsorbPointer(
        child: TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: 'Item Name',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        ),
      ),
    );
  }
}
