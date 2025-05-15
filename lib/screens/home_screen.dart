import 'package:cashflo/widgets/expense_stream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cashflo/screens/add_expense_screen.dart';

import '../constants.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "home_screen";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var currentAmount = 0;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String flo_id = args['flo_id'];

    return SafeArea(
        child: Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) => AddExpenseScreen(
                    floId: flo_id,
                  ));
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
                    .collection(kExpenseCollection)
                    .where('flo_id', isEqualTo: flo_id)
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
          Expanded(
            child: ExpenseStream(
              floId: flo_id,
            ),
          ),
        ],
      ),
    ));
  }
}
