import 'package:cashflo/screens/add_flo_screen.dart';
import 'package:cashflo/screens/join_flo_screen.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/create_flo_grid.dart';

class CreateFloScreen extends StatefulWidget {
  const CreateFloScreen({super.key});

  static const String id = "create_flo";

  @override
  State<CreateFloScreen> createState() => _CreateFloScreenState();
}

class _CreateFloScreenState extends State<CreateFloScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffF5F5F5),
        body: CreateFloGrid(),
        bottomNavigationBar: Container(
          color: Color(0xffF5F5F5),
          height: 79,
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => AddFloScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff087E8B),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    "Create",
                    style: kButtonTextStyle,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => JoinFloScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff087E8B),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    "Join",
                    style: kButtonTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
