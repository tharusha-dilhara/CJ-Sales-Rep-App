import 'package:cj/components/customNavButton.dart';
import 'package:cj/models/invoice_model.dart';
import 'package:cj/services/pdf/invoicepdf.dart';
import 'package:flutter/material.dart';

class FinishinvoiceView extends StatefulWidget {
  final List<InvoiceItem> items;

  const FinishinvoiceView({Key? key, required this.items}) : super(key: key);

  @override
  State<FinishinvoiceView> createState() => _FinishinvoiceViewState();
}

class _FinishinvoiceViewState extends State<FinishinvoiceView> {
  String getItemAmount(InvoiceItem item) {
    // Parsing price and discount as double
    double price = double.parse(item.price);
    double discount = double.parse(item.discount);
    double discountAmount = discount/100 * price;

    double finalAmount = price - discountAmount;

// Round to the nearest 0.001
    double roundedFinalAmount = (finalAmount * 1000).round() / 1000;

// Convert to string and cut off the third decimal point
    String formattedFinalAmount = roundedFinalAmount
        .toStringAsFixed(3)
        .substring(0, roundedFinalAmount.toStringAsFixed(4).length - 1);

    print(formattedFinalAmount);

    return formattedFinalAmount;

  }

  double getTotalAmount() {
    return widget.items.fold(0, (sum, item) => sum + double.parse(getItemAmount(item))*(item.qty));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finish Invoice'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomListTile(
              leadingIcon: Icons.share,
              title: 'Share invoice',
              subtitle: 'print and share invoice',
              onTap: () {
                createAndSharePdf(widget.items);
              },
            ),
            const SizedBox(height: 30),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Qty')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Discount')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: widget.items.map((item) {
                  double itemAmount = double.parse(getItemAmount(item));
                  return DataRow(cells: [
                    DataCell(Text(item.itemName)),
                    DataCell(Text(item.qty.toString())),
                    DataCell(Text("RS ${item.price.toString()}")),
                    DataCell(Text(" ${item.discount.toString()} %")),
                    DataCell(Text("RS ${itemAmount.toStringAsFixed(2)}")),
                  ]);
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'Total Amount: ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "RS ${getTotalAmount().toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
