import 'package:cashflo/widgets/expense_stream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cashflo/screens/add_expense_screen.dart';

import '../constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<double> getTotalAmount() async {
  double totalAmount = 0;
  final snapshot =
      await FirebaseFirestore.instance.collection(kCollectionName).get();

  for (var doc in snapshot.docs) {
    totalAmount += (doc['amount'] as num).toDouble();
  }

  return totalAmount;
}

class _HomeScreenState extends State<HomeScreen> {
  var currentAmount = 0;
  var totalAmount = FutureBuilder<double>(
    future: getTotalAmount(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text(
          'OOPS!!!',
          style: kTotalAmountTextWidgetStyle,
        );
      } else {
        return Text(
          '₹${snapshot.data!.toStringAsFixed(2)}',
          style: kTotalAmountTextWidgetStyle,
        );
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) => AddExpenseScreen());
        },
        backgroundColor: Color(0xff087E8B),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xffF5F5F5),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 60, left: 30, right: 30, bottom: 30),
            color: Color(0xff087E8B),
            child: Center(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(kCollectionName)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
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
          ExpenseStream()
        ],
      ),
    ));
  }
}
