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

Future<void> createAndSharePdf(List<InvoiceItem> items,String shopName,String paymentMethod) async {
  final pdf = pw.Document();
  

  // Get current date and time
  final now = DateTime.now();
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  final currentDateTime = dateFormat.format(now);
  Map<String, String?> salesRepData = await AuthService.getSalesRepData();
  final mobileNumber = salesRepData['mobileNumber'];
  final name = salesRepData['name'];

  // Prepare data for table
  List<List<dynamic>> rows = [];
  double totalPrice = 0;

  for (var item in items) {
    final double itemPrice = double.parse(item.price);
    final double itemDiscount = double.parse(item.discount);
    double discountAmount = (itemDiscount / 100 * itemPrice);
    String formattedDiscount = discountAmount.toStringAsFixed(2);

    double finalAmount = itemPrice * item.qty - double.parse(formattedDiscount) * item.qty;

    // Round to the nearest 0.001
    double roundedFinalAmount = (finalAmount * 1000).round() / 1000;

    // Convert to string and cut off the third decimal point
    String formattedFinalAmount = roundedFinalAmount
        .toStringAsFixed(3)
        .substring(0, roundedFinalAmount.toStringAsFixed(4).length - 1);

    rows.add([
      item.itemName,
      item.qty,
      "RS.${item.price}",
      "RS.${formattedDiscount} * ${item.qty}",
      "RS.${finalAmount.toStringAsFixed(2)}",
    ]);
    totalPrice += double.parse(formattedFinalAmount);
  }

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 2),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            padding: pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with company name and logo (simplified)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'CJ Food Products',
                      style: pw.TextStyle(
                          fontSize: 30,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.black),
                    ),
                    // You can add a logo here, for now it's omitted
                  ],
                ),
                pw.SizedBox(height: 20),

                // Sales Rep information
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: pw.EdgeInsets.all(10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Sales done by ${name ?? 'Unknown'}',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Mobile: ${mobileNumber ?? 'Unknown'}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Date: $currentDateTime',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                // Shop Name and Payment Method
                pw.Text(
                  'Shop Name: $shopName',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Payment Method: $paymentMethod',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),

                // Table of items
                pw.Table.fromTextArray(
                  headers: [
                    'Item Name',
                    'Qty',
                    'Price',
                    'Discount',
                    'Net Price'
                  ],
                  data: rows,
                  border: pw.TableBorder.all(color: PdfColors.grey, width: 1),
                  cellAlignment: pw.Alignment.center,
                  headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.white),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.black),
                  cellStyle: pw.TextStyle(fontSize: 9),
                  
                ),
                pw.SizedBox(height: 20),

                // Total Price Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black, width: 1),
                        borderRadius: pw.BorderRadius.circular(5),
                      ),
                      padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: pw.Text(
                        'Total: RS ${totalPrice.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Footer with company info or terms
                pw.Divider(),
                pw.SizedBox(height: 10),
                
              ],
            ),
          ),
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
