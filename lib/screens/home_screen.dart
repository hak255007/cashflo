import 'package:flutter/material.dart';
import 'package:cashflo/screens/add_expense_screen.dart';
import 'package:cashflo/screens/expenses_page.dart';
import 'package:cashflo/screens/total_expenses_page.dart';

class HomeScreen extends StatefulWidget {
  static const String id = "home_screen";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String flo_id = args['flo_id'];

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xffF5F5F5),
        // Only show the add-expense FAB on the expenses page
        floatingActionButton: _currentPage == 0
            ? FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) => AddExpenseScreen(
                            floId: flo_id,
                          ));
                },
                backgroundColor: const Color(0xff087E8B),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              )
            : null,
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  ExpensesPage(floId: flo_id),
                  TotalExpensesPage(floId: flo_id),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildPageIndicator(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 20 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xff087E8B)
                : const Color(0xff087E8B).withOpacity(0.25),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
