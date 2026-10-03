import 'package:cashflo/widgets/expense_stream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

/// Shows the running total header and the scrollable list of expenses
/// for a given Flo. Used as the first page inside HomeScreen's PageView.
class ExpensesPage extends StatelessWidget {
  static const String id = "expenses_page";

  final String floId;

  const ExpensesPage({super.key, required this.floId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding:
              const EdgeInsets.only(top: 60, left: 30, right: 30, bottom: 30),
          color: const Color(0xff087E8B),
          child: Center(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(kExpenseCollection)
                  .where('flo_id', isEqualTo: floId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snapshot.data!.docs;
                double total = 0.0;

                for (var doc in docs) {
                  total += (doc['amount'] as num).toDouble();
                }

                return Text(
                  '₹${total.toStringAsFixed(2)}',
                  style: kTotalAmountTextWidgetStyle,
                );
              },
            ),
          ),
        ),
        Expanded(
          child: ExpenseStream(
            floId: floId,
          ),
        ),
      ],
    );
  }
}
