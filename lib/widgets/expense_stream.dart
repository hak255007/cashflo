import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'expense.dart';

final _firestore = FirebaseFirestore.instance;

class ExpenseStream extends StatelessWidget {
  const ExpenseStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection(kCollectionName)
            .orderBy('spending_date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final messages = snapshot.data!.docs.reversed;
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

          return Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return messageBubbles[index];
              },
              itemCount: messageBubbles.length,
            ),
          );
        });
  }
}
