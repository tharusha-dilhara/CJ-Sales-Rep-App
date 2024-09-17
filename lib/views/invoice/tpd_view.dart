import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cj/services/ptd/ptd_service.dart';

class TpdView extends StatefulWidget {
  const TpdView({super.key});

  @override
  State<TpdView> createState() => _TpdViewState();
}

class _TpdViewState extends State<TpdView> {
  final InvoiceService _invoiceService = InvoiceService();
  Future<Map<String, double>>? _paymentDetails;

  @override
  void initState() {
    super.initState();
    _loadSalesRepId();
  }

  Future<void> _loadSalesRepId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesRepId = prefs.getString('salesRepId');

    if (salesRepId != null && salesRepId.isNotEmpty) {
      setState(() {
        _paymentDetails =
            _invoiceService.getCombinedTotalBySalesRep(salesRepId);
      });
    } else {
      setState(() {
        _paymentDetails = Future.error('Sales Rep ID not found');
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadSalesRepId(); // Reload data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Total Payment Of The Day'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData, // Pull-to-refresh action
        child: FutureBuilder<Map<String, double>>(
          future: _paymentDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final paymentData = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  // Use ListView for RefreshIndicator to work
                  children: [
                    _buildPaymentDetailCard(
                      title: 'Total Cash to Deposit',
                      amount: paymentData['totalCashAmount'] ?? 0,
                    ),
                    SizedBox(height: 16),
                    _buildPaymentDetailCard(
                      title: 'Total Credit Balance',
                      amount: paymentData['totalCreditAmount'] ?? 0,
                    ),
                    SizedBox(height: 32),
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rs.${paymentData['combinedTotal']?.toStringAsFixed(2) ?? '0.00'}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildPaymentDetailCard(
      {required String title, required double amount}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Price\nRs. ${amount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
