import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Expense extends StatelessWidget {
  const Expense(
      {super.key,
      required this.description,
      required this.amount,
      required this.longPressCallBack,
      required this.spendingDate});

  final String description;
  final double amount;
  final DateTime spendingDate;
  final void Function() longPressCallBack;

  String _formatDate(DateTime date) {
    final day = date.day;
    final suffix = _getDaySuffix(day);
    final formatted = DateFormat("MMMM yyyy").format(date);
    return "$day$suffix $formatted";
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return "th";
    switch (day % 10) {
      case 1:
        return "st";
      case 2:
        return "nd";
      case 3:
        return "rd";
      default:
        return "th";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xffC9E4E7),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onLongPress: longPressCallBack,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(Icons.receipt_long, color: Color(0xff087E8B)),
        title: Text(
          description,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          _formatDate(spendingDate),
          style: TextStyle(
            color: Color(0xff3C3C3C),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        trailing: Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green[700],
          ),
        ),
      ),
    );
  }
}
