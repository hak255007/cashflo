import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

final _firestore = FirebaseFirestore.instance;

class DeleteFloButton extends StatelessWidget {
  const DeleteFloButton({super.key, required this.docId});

  final String docId;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete_rounded, color: Color(0xffFF5A5F)),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Flo?'),
            content: Text('Are you sure you want to delete this Flo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await _firestore.collection(kFloCollection).doc(docId).delete();
        }
      },
    );
  }
}
