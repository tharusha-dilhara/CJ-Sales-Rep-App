import 'package:cj/models/invoice_model.dart';
import 'package:cj/services/auth/auth_service.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:math';

Future<void> createAndSharePdf(List<InvoiceItem> items) async {
  final pdf = pw.Document();

  // Get current date and time
  final now = DateTime.now();
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  final currentDateTime = dateFormat.format(now);
  Map<String, String?> salesRepData = await AuthService.getSalesRepData();
  final mobileNumber = salesRepData['mobileNumber'];
  final name = salesRepData['name'];
  print(name);

  // Prepare data for table
  List<List<dynamic>> rows = [];
  double totalPrice = 0;

  for (var item in items) {
    final double itemPrice = double.parse(item.price);
    final double itemDiscount = double.parse(item.discount);
    double discountAmount = itemDiscount/100 * itemPrice;

    double finalAmount = itemPrice - discountAmount;

// Round to the nearest 0.001
    double roundedFinalAmount = (finalAmount * 1000).round() / 1000;

// Convert to string and cut off the third decimal point
    String formattedFinalAmount = roundedFinalAmount
        .toStringAsFixed(3)
        .substring(0, roundedFinalAmount.toStringAsFixed(4).length - 1);
    

    rows.add([
      item.itemName,
      item.qty,
      "RS ${item.price}",
      "${item.discount} %",
      "RS ${formattedFinalAmount}",
    ]);
    totalPrice += double.parse(formattedFinalAmount);
  }

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CJ System',
              style: pw.TextStyle(fontSize: 38, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              name ?? 'Unknown',
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              mobileNumber ?? 'Unknown',
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Date and Time: $currentDateTime',
                style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                'Item Name',
                'Item Qty',
                'Item Price',
                'Item Discount',
                'Item Amount'
              ],
              data: rows,
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total Price: RS ${totalPrice.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  final random = Random();
  // Save the PDF to a file
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/${random.nextInt(100)}.pdf");
  await file.writeAsBytes(await pdf.save());

  // Share the PDF file
  await Share.shareFiles([file.path], text: 'Here is your PDF document.');
}
