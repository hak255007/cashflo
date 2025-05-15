import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'expense.dart';

final _firestore = FirebaseFirestore.instance;

class ExpenseStream extends StatelessWidget {
  final String floId;

  const ExpenseStream({super.key, required this.floId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection(kExpenseCollection)
            .where('flo_id', isEqualTo: floId)
            .orderBy('spending_date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }

          // TODO : Test the commented logic
          // if (snapshot.hasError) {
          //   return Center(child: Text('Something went wrong'));
          // }
          // if (snapshot.data!.docs.isEmpty) {
          //   return Center(child: Text('No expenses yet'));
          // }

          final messages = snapshot.data!.docs;
          List<Expense> messageBubbles = [];
          for (var message in messages) {
            final description = message.data()['description'];
            final double amount = message.data()['amount'];
            final DateTime spendDate = message['spending_date'].toDate();

            final messageWidget = Expense(
              description: description,
              amount: amount,
              spendingDate: spendDate,
              longPressCallBack: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Expense'),
                    content:
                        Text('Are you sure you want to delete this expense?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Cancel
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          message.reference.delete(); // Delete document
                          Navigator.pop(context); // Close dialog
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
            messageBubbles.add(messageWidget);
          }

          return ListView.builder(
            itemBuilder: (context, index) {
              return messageBubbles[index];
            },
            itemCount: messageBubbles.length,
          );
        });
  }
}
