import 'package:cj/components/customNavButton.dart';
import 'package:cj/models/invoice_model.dart';
import 'package:cj/services/pdf/invoicepdf.dart';
import 'package:flutter/material.dart';

class FinishinvoiceView extends StatefulWidget {
  final List<InvoiceItem> items;
  final String shopName;
  final String paymentMethod;

  const FinishinvoiceView({
    Key? key,
    required this.items,
    required this.shopName,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  State<FinishinvoiceView> createState() => _FinishinvoiceViewState();
}

class _FinishinvoiceViewState extends State<FinishinvoiceView> {
  String getItemAmount(InvoiceItem item) {
    double price = double.parse(item.price);
    double discount = double.parse(item.discount);
    double discountAmount = discount / 100 * price;
    double finalAmount = (price * item.qty) - (discountAmount * item.qty);

    double roundedFinalAmount = (finalAmount * 1000).round() / 1000;
    String formattedFinalAmount = roundedFinalAmount
        .toStringAsFixed(3)
        .substring(0, roundedFinalAmount.toStringAsFixed(4).length - 1);

    return formattedFinalAmount;
  }

  double getTotalAmount() {
    return widget.items.fold(0, (sum, item) => sum + double.parse(getItemAmount(item)));
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
              subtitle: 'Print and share invoice',
              onTap: () {
                createAndSharePdf(
                  widget.items,
                  widget.shopName,
                  widget.paymentMethod,
                );
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
                  DataColumn(label: Text('Discount %')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: widget.items.map((item) {
                  double itemAmount = double.parse(getItemAmount(item));
                  return DataRow(cells: [
                    DataCell(Text(item.itemName)),
                    DataCell(Text(item.qty.toString())),
                    DataCell(Text("RS ${item.price.toString()}")),
                    DataCell(Text("${item.discount.toString()} %")),
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
