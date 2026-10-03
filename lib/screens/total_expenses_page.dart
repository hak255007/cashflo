import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

/// Shows the total expenses for a given Flo as a donut chart, broken down
/// per user, with a legend listing each user's share.
class TotalExpensesPage extends StatelessWidget {
  static const String id = "total_expenses_page";

  final String floId;

  const TotalExpensesPage({super.key, required this.floId});

  // A small fixed palette so colors stay consistent and readable.
  static const List<Color> _palette = [
    Color(0xff087E8B),
    Color(0xffF2A65A),
    Color(0xffE84855),
    Color(0xff5DB8B8),
    Color(0xff8E6C88),
    Color(0xff4CAF50),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(kExpenseCollection)
            .where('flo_id', isEqualTo: floId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Couldn't load expenses."));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No expenses yet."),
            );
          }

          // Group amounts by user_id, keeping a display username alongside.
          final Map<String, _UserTotal> totals = {};
          double grandTotal = 0.0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final amount = (data['amount'] as num).toDouble();
            final userId = data['user_id'] as String? ?? 'unknown';
            final username = data['username'] as String? ?? 'Unknown';

            grandTotal += amount;

            totals.update(
              userId,
              (existing) => existing..amount += amount,
              ifAbsent: () => _UserTotal(username: username, amount: amount),
            );
          }

          final entries = totals.values.toList()
            ..sort((a, b) => b.amount.compareTo(a.amount));

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                SizedBox(
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 70,
                          sections: List.generate(entries.length, (i) {
                            final entry = entries[i];
                            final color = _palette[i % _palette.length];
                            return PieChartSectionData(
                              value: entry.amount,
                              color: color,
                              radius: 45,
                              showTitle: false,
                            );
                          }),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Total Spent",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xff1A1A1A),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Breakdown",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(entries.length, (i) {
                  final entry = entries[i];
                  final color = _palette[i % _palette.length];
                  final percent =
                      grandTotal == 0 ? 0.0 : (entry.amount / grandTotal) * 100;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.username,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          '₹${entry.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${percent.toStringAsFixed(0)}%)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UserTotal {
  final String username;
  double amount;

  _UserTotal({required this.username, required this.amount});
}
