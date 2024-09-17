import 'package:cj/components/ItemNameDropdown.dart';
import 'package:cj/models/AddStockRequest.dart';
import 'package:cj/models/StockItem.dart';
import 'package:cj/services/auth/auth_service.dart';
import 'package:cj/services/shop/StockService.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



class AddstockView extends StatefulWidget {
  const AddstockView({super.key});

  @override
  State<AddstockView> createState() => _AddstockViewState();
}

class _AddstockViewState extends State<AddstockView> {
  final _itemNameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();

  final List<StockItem> _items = [];
  final StockService _stockService = StockService();
  bool _isCompleting = false;

  void _addItem() {
    final itemName = _itemNameController.text;
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final rate = _rateController.text ?? "0.00";

    if (itemName.isEmpty || qty <= 0 || double.tryParse(rate)! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid item details')),
      );
      return;
    }

    setState(() {
      _items.add(StockItem(itemName: itemName, qty: qty, rate: rate));
      _itemNameController.clear();
      _qtyController.clear();
      _rateController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }


  Future<void> verfy() async {
    Map<String, String?> salesRepData = await AuthService.getSalesRepData();
    String? id = salesRepData['id'];
    bool iscredicle = await AuthService.verifySalesRep(id!);
    if (iscredicle) {
      print(true);
    }else{
      print(false);
      AuthService.applogout();
       GoRouter.of(context).pushReplacementNamed('login');
    }
  }

  void _completeAndAddStock() {
    setState(() {
      _isCompleting = true;
    });

    final request = AddStockRequest(
      verification: 'pending',
      items: _items,
    );

    print(request);



    _stockService.addStock(request).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stock added successfully')),
      );
      setState(() {
        _items.clear(); // Clear the list after successful submission
        _isCompleting = false;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add stock: $error')),
      );
      setState(() {
        _isCompleting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    verfy();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add Item",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(28.0),
          child: Column(
            children: [
              ItemNameDropdown(controller: _itemNameController),
              SizedBox(height: 20),
              TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Qty',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _rateController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Rate',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              MaterialButton(
                minWidth: double.infinity,
                color: Colors.green,
                height: 55,
                onPressed: _addItem,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      12.0), // Adjust the radius as needed
                ),
                child: Text("Add Item", style: TextStyle(fontSize: 26, color: Colors.white)),
              ),
              SizedBox(height: 20),
              if (_items.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return ListTile(
                        title: Text(item.itemName),
                        subtitle: Text('Qty: ${item.qty}, Rate: ${item.rate}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 20),
              MaterialButton(
                minWidth: double.infinity,
                color: Colors.green,
                height: 55,
                onPressed: _isCompleting ? null : _completeAndAddStock,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      12.0), // Adjust the radius as needed
                ),
                child: Text(
                  _isCompleting ? "Completing..." : "Complete",
                  style: TextStyle(fontSize: 26, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
