import 'package:cashflo/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _user = FirebaseAuth.instance.currentUser;

class JoinFloScreen extends StatefulWidget {
  const JoinFloScreen({super.key});

  @override
  State<JoinFloScreen> createState() => _JoinFloScreenState();
}

Future<void> findFloById(String floId, BuildContext context) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection(kFloCollection) // Replace with your actual collection name
      .where('flo_id', isEqualTo: floId)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    String docId = querySnapshot.docs.first.id;
    await FirebaseFirestore.instance
        .collection(kFloCollection)
        .doc(docId)
        .update({
      'flo_users': FieldValue.arrayUnion([_user!.uid])
    });

    if (!context.mounted) return;

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text(
              'Success!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'You have successfully joined the Flo.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xff087E8B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          )
        ],
      ),
    );
  } else {
    if (!context.mounted) return; // 👈 this avoids the error
    // Show message to the user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text(
              'Failure!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Failed to join the flo. Please enter correct flo ID.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xff087E8B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          )
        ],
      ),
    );
  }
}

class _JoinFloScreenState extends State<JoinFloScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Do something with the input
      findFloById(_descriptionController.text, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
// Constrain the height manually
        height: 250, // or use MediaQuery.of(context).size.height * 0.3
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join Existing Flo',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, color: Color(0xff087E8B)),
              ),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.rocket_launch,
                        color: Color(0xff3C3C3C),
                      ),
                      hintText: 'This will be the title for your Flo?',
                      labelText: 'Enter Unique Flo ID *',
                    ),
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
                    },
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'A valid Flo ID must be passed to join';
                      }
                      return null;
                    },
                  )),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              TextButton(
                onPressed: () {
                  _submitForm();
                },
                style: TextButton.styleFrom(backgroundColor: Color(0xffFF5A5F)),
                child: Text(
                  'Join Flo',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
