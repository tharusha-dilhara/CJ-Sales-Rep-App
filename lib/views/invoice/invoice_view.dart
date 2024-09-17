import 'package:cj/components/customNavButton.dart';
import 'package:cj/models/Invoice.dart';
import 'package:cj/services/invoice/invoice_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InvoiceView extends StatefulWidget {
  const InvoiceView({super.key});

  @override
  _InvoiceViewState createState() => _InvoiceViewState();
}

class _InvoiceViewState extends State<InvoiceView> {
  late Future<List<Invoice>> invoices;

  @override
  void initState() {
    super.initState();
    invoices = InvoiceService.fetchInvoices();
  }

  Future<void> _refreshInvoices() async {
    setState(() {
      invoices = InvoiceService.fetchInvoices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: const Text('Invoice'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: RefreshIndicator( // Wrap the SingleChildScrollView with RefreshIndicator
          onRefresh: _refreshInvoices, // Provide the refresh callback
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomListTile(
                  leadingIcon: Icons.verified,
                  title: 'Create Invoice',
                  subtitle: 'Create new invoice',
                  onTap: () {
                    GoRouter.of(context).pushNamed('createInvoice');
                  },
                ),
                const SizedBox(height: 10),
                CustomListTile(
                  leadingIcon: Icons.verified,
                  title: 'Total Payment Of The Day',
                  subtitle: 'Total payment of the day',
                  onTap: () {
                    GoRouter.of(context).pushNamed('tpd');
                  },
                ),
                const SizedBox(height: 10),
                CustomListTile(
                  leadingIcon: Icons.verified,
                  title: 'Credit View',
                  subtitle: 'Credit View',
                  onTap: () {
                    GoRouter.of(context).pushNamed('creditView');
                  },
                ),
                const SizedBox(height: 20),
                Divider(),
                const SizedBox(height: 10),
                Center(child: Text("Invoices list of the day",style: TextStyle(fontSize: 21,fontWeight: FontWeight.bold) ,)),
                const SizedBox(height: 5),
                FutureBuilder<List<Invoice>>(
                  future: invoices,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No invoices data available'));
                    }

                    final List<Invoice> invoiceList = snapshot.data!;

                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: invoiceList.length,
                      itemBuilder: (context, index) {
                        final Invoice invoice = invoiceList[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shop Name: ${invoice.shopName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Branch: ${invoice.branchname}'),
                                Text('Amount: RS ${invoice.amount.toStringAsFixed(2)}'),
                                Text('Quantity: ${invoice.quantity}'),
                                const SizedBox(height: 8),
                                Text(
                                  'Items:',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                for (var item in invoice.items)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '- ${item.itemName}: ${item.qty} x RS ${item.price.toStringAsFixed(2)}',
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text('Payment Method: ${invoice.paymentMethod}'),
                                Text('Date: ${invoice.customDate} ${invoice.customTime}'),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
