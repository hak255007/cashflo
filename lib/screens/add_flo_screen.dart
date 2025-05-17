import 'package:cashflo/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final _firestore = FirebaseFirestore.instance;

class AddFloScreen extends StatefulWidget {
  const AddFloScreen({super.key});

  @override
  State<AddFloScreen> createState() => _AddFloScreenState();
}

class _AddFloScreenState extends State<AddFloScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      // Generate a v4 (random) UUID
      String uuid = Uuid().v4();

      // Do something with the input
      _firestore.collection(kFloCollection).add({
        'flo_title': _descriptionController.text,
        'flo_created_at': DateTime.timestamp(),
        'flo_id': uuid,
        'flo_created_by': user?.uid,
        'flo_users': [user?.uid]
      });
      Navigator.pop(context);
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
                'Create New Flo',
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
                      labelText: 'Flo Title *',
                    ),
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
                    },
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Flo title cannot be empty';
                      }
                      if (value.length > 15) {
                        return 'Max length 15 characters.';
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
                  'Create Flo',
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
