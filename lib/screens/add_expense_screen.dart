import 'package:cashflo/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = FirebaseFirestore.instance;

class AddExpenseScreen extends StatefulWidget {
  final String floId;
  const AddExpenseScreen({super.key, required this.floId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Do something with the input
      _firestore.collection(kExpenseCollection).add({
        'description': _descriptionController.text,
        'amount': double.tryParse(_amountController.text.trim()),
        'spending_date': DateTime.timestamp(),
        'flo_id': widget.floId
      });

      // TODO : Data should be added in the flo_data array

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
        height: 320, // or use MediaQuery.of(context).size.height * 0.3
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Expense',
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
                        Icons.description,
                        color: Color(0xff3C3C3C),
                      ),
                      hintText: 'Enter details of your expense?',
                      labelText: 'Description *',
                    ),
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
                    },
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description cannot be empty';
                      }
                      return null;
                    },
                  )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    controller: _amountController,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.currency_rupee,
                        color: Color(0xff3C3C3C),
                      ),
                      hintText: 'Enter Amount?',
                      labelText: 'Amount *',
                    ),
                    onSaved: (String? value) {
                      // This optional block of code can be used to run
                      // code when the user saves the form.
                    },
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Amount cannot be empty';
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
                  'Add',
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
