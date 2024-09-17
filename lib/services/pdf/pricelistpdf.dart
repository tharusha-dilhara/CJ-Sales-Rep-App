import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // For date formatting

Future<void> createAndSharePriceListPdf(List<dynamic> items) async {
  final pdf = pw.Document();

  // Get current date and time
  final now = DateTime.now();
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
  final currentDateTime = dateFormat.format(now);

  List<List<String>> rows = items.map((item) {
    return [
      item['itemName'].toString(),
      item['price'].toString(),
    ];
  }).toList();

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
              'Date and Time: $currentDateTime',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Item Name', 'Item Price'],
              data: rows,
            ),
            pw.SizedBox(height: 20),
          ],
        );
      },
    ),
  );

  // Save the PDF to a file
  final output = await getTemporaryDirectory();
  final file = File("${output.path}/price_list.pdf");
  await file.writeAsBytes(await pdf.save());

  // Share the PDF file
  await Share.shareFiles([file.path], text: 'Here is your PDF document.');
}