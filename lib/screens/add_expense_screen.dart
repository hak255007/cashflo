import 'package:cashflo/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = FirebaseFirestore.instance;

/// Expense categories. Keep the label stable since it's what gets stored
/// in Firestore. Add or remove entries here and the dropdown updates.
const List<String> kExpenseCategories = [
  'Groceries',
  'Rent',
  'Investments',
  'Fuel',
  'Food & Dining',
  'Hotels & Stay',
  'Travel & Transport',
  'Utilities & Bills',
  'Shopping',
  'Entertainment',
  'Health & Medical',
  'Education',
  'Insurance',
  'EMI & Loans',
  'Subscriptions',
  'Personal Care',
  'Gifts & Donations',
  'Other',
];

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

  String? _selectedCategory;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      // Read from cache only, so this never waits on a network round-trip
      // and stays instant/offline-friendly like the rest of this form.
      String? username;
      if (userId != null) {
        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(userId)
              .get(const GetOptions(source: Source.cache));
          username = userDoc.data()?['username'] as String?;
        } catch (_) {
          // Not cached (e.g. first-ever offline use before username was
          // fetched once) - proceed without blocking the add.
          username = null;
        }
      }

      // Do something with the input
      _firestore.collection(kExpenseCollection).add({
        'description': _descriptionController.text,
        'amount': double.tryParse(_amountController.text.trim()),
        'category': _selectedCategory,
        'spending_date': DateTime.timestamp(),
        'flo_id': widget.floId,
        'user_id': userId,
        'username': username,
      });

      // TODO : Data should be added in the flo_data array

      if (mounted) Navigator.pop(context);
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
        // Constrain the height manually (increased to fit the category field)
        height: 400,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
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
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
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
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Amount cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      menuMaxHeight: 300,
                      decoration: const InputDecoration(
                        icon: Icon(
                          Icons.category,
                          color: Color(0xff3C3C3C),
                        ),
                        labelText: 'Category *',
                      ),
                      hint: const Text('Select a category'),
                      items: kExpenseCategories
                          .map((category) => DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (String? value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  _submitForm();
                },
                style: TextButton.styleFrom(
                    backgroundColor: const Color(0xffFF5A5F)),
                child: const Text(
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
