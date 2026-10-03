import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/category_icons.dart';

enum _GroupBy { category, person }

/// Shows the total expenses for a given Flo as a donut chart, grouped either
/// by category or by person, with a detailed breakdown list.
class TotalExpensesPage extends StatefulWidget {
  static const String id = "total_expenses_page";

  final String floId;

  const TotalExpensesPage({super.key, required this.floId});

  @override
  State<TotalExpensesPage> createState() => _TotalExpensesPageState();
}

class _TotalExpensesPageState extends State<TotalExpensesPage> {
  static const Color _brand = Color(0xff087E8B);
  static const Color _background = Color(0xffF4F7F8);
  static const Color _ink = Color(0xff1A1A1A);

  // Used for the "By Person" view.
  static const List<Color> _palette = [
    Color(0xff087E8B),
    Color(0xffF2A65A),
    Color(0xffE84855),
    Color(0xff5DB8B8),
    Color(0xff8E6C88),
    Color(0xff4CAF50),
  ];

  // Style for expenses saved before categories existed.
  static const CategoryStyle _uncategorizedStyle =
      CategoryStyle(Icons.help_outline, Color(0xff9E9E9E));

  late final Stream<QuerySnapshot> _stream;
  _GroupBy _groupBy = _GroupBy.category;
  int _selected = -1;

  @override
  void initState() {
    super.initState();
    // Created once so that setState (selection, toggle) doesn't resubscribe.
    _stream = FirebaseFirestore.instance
        .collection(kExpenseCollection)
        .where('flo_id', isEqualTo: widget.floId)
        .snapshots();
  }

  // ---------------------------------------------------------------------------
  // Data
  // ---------------------------------------------------------------------------

  _Aggregates _aggregate(List<QueryDocumentSnapshot> docs) {
    final Map<String, _Slice> byCategory = {};
    final Map<String, _Slice> byUser = {};
    double total = 0.0;
    int count = 0;

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final rawAmount = data['amount'];
      if (rawAmount is! num) continue; // skip malformed expenses
      final amount = rawAmount.toDouble();

      final rawCategory = (data['category'] as String?)?.trim();
      final hasCategory = rawCategory != null && rawCategory.isNotEmpty;
      final categoryLabel = hasCategory ? rawCategory : 'Uncategorized';
      final style =
          hasCategory ? styleForCategory(rawCategory) : _uncategorizedStyle;

      final userId = data['user_id'] as String? ?? 'unknown';
      final username = data['username'] as String? ?? 'Unknown';

      total += amount;
      count++;

      byCategory
          .putIfAbsent(
            categoryLabel,
            () => _Slice(
                label: categoryLabel, color: style.color, icon: style.icon),
          )
          .add(amount);

      byUser
          .putIfAbsent(userId, () => _Slice(label: username, color: _brand))
          .add(amount);
    }

    final categories = byCategory.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final people = byUser.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    for (int i = 0; i < people.length; i++) {
      people[i].color = _palette[i % _palette.length];
    }

    return _Aggregates(
      categories: categories,
      people: people,
      total: total,
      count: count,
    );
  }

  void _toggleSelected(int index) {
    setState(() => _selected = _selected == index ? -1 : index);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _background,
      child: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _MessageState(
                icon: Icons.cloud_off_rounded,
                message: "Couldn't load expenses.",
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: _brand),
              );
            }

            final agg = _aggregate(snapshot.data!.docs);

            if (agg.count == 0) {
              return const _MessageState(
                icon: Icons.account_balance_wallet_outlined,
                message: "No expenses yet.",
              );
            }

            final slices =
                _groupBy == _GroupBy.category ? agg.categories : agg.people;
            final selected =
                _selected >= 0 && _selected < slices.length ? _selected : -1;
            final top = agg.categories.first;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  _SummaryCard(
                    total: agg.total,
                    count: agg.count,
                    topLabel: top.label,
                    topIcon: top.icon ?? Icons.category,
                  ),
                  const SizedBox(height: 20),
                  _GroupToggle(
                    value: _groupBy,
                    onChanged: (mode) => setState(() {
                      _groupBy = mode;
                      _selected = -1;
                    }),
                  ),
                  const SizedBox(height: 20),
                  _buildChartCard(slices, agg.total, selected),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Text(
                        "Breakdown",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _groupBy == _GroupBy.category
                            ? '${slices.length} ${slices.length == 1 ? 'category' : 'categories'}'
                            : '${slices.length} ${slices.length == 1 ? 'person' : 'people'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey(_groupBy),
                      children: List.generate(slices.length, (i) {
                        final slice = slices[i];
                        final percent =
                            agg.total == 0 ? 0.0 : slice.amount / agg.total;
                        return _SliceTile(
                          slice: slice,
                          percent: percent,
                          selected: i == selected,
                          onTap: () => _toggleSelected(i),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartCard(List<_Slice> slices, double total, int selected) {
    final hasSelection = selected >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        height: 270,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 78,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    final index =
                        response?.touchedSection?.touchedSectionIndex ?? -1;
                    if (event is FlTapUpEvent && index >= 0) {
                      _toggleSelected(index);
                    }
                  },
                ),
                sections: List.generate(slices.length, (i) {
                  final slice = slices[i];
                  final isSelected = i == selected;
                  final percent = total == 0 ? 0.0 : slice.amount / total;
                  final dimmed = hasSelection && !isSelected;

                  return PieChartSectionData(
                    value: slice.amount,
                    color: dimmed
                        ? slice.color.withValues(alpha: 0.35)
                        : slice.color,
                    radius: isSelected ? 54 : 46,
                    showTitle: false,
                    // Only badge slices big enough to hold one.
                    badgeWidget:
                        percent >= 0.07 ? _SliceBadge(slice: slice) : null,
                    badgePositionPercentageOffset: 0.5,
                  );
                }),
              ),
            ),
            SizedBox(
              width: 140,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: hasSelection
                    ? _CenterLabel(
                        key: ValueKey('sel-$selected-$_groupBy'),
                        title: slices[selected].label,
                        amount: slices[selected].amount,
                        footer:
                            '${(total == 0 ? 0 : slices[selected].amount / total * 100).toStringAsFixed(0)}% of total',
                        color: slices[selected].color,
                      )
                    : _CenterLabel(
                        key: const ValueKey('total'),
                        title: 'Total',
                        amount: total,
                        footer: 'Tap a slice for details',
                        color: _ink,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Models
// -----------------------------------------------------------------------------

class _Slice {
  final String label;
  final IconData? icon; // null -> show the first letter (used for people)
  Color color;
  double amount = 0.0;
  int count = 0;

  _Slice({required this.label, required this.color, this.icon});

  void add(double value) {
    amount += value;
    count++;
  }
}

class _Aggregates {
  final List<_Slice> categories;
  final List<_Slice> people;
  final double total;
  final int count;

  _Aggregates({
    required this.categories,
    required this.people,
    required this.total,
    required this.count,
  });
}

// -----------------------------------------------------------------------------
// Widgets
// -----------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  final double total;
  final int count;
  final String topLabel;
  final IconData topIcon;

  const _SummaryCard({
    required this.total,
    required this.count,
    required this.topLabel,
    required this.topIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff087E8B), Color(0xff0FA3B1)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff087E8B).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Spent",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _inr(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _StatChip(
                icon: Icons.receipt_long,
                text: '$count ${count == 1 ? 'expense' : 'expenses'}',
              ),
              const SizedBox(width: 10),
              Flexible(
                child: _StatChip(icon: topIcon, text: 'Top: $topLabel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupToggle extends StatelessWidget {
  final _GroupBy value;
  final ValueChanged<_GroupBy> onChanged;

  const _GroupToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _ToggleItem(
            label: 'By Category',
            icon: Icons.category_rounded,
            selected: value == _GroupBy.category,
            onTap: () => onChanged(_GroupBy.category),
          ),
          _ToggleItem(
            label: 'By Person',
            icon: Icons.people_alt_rounded,
            selected: value == _GroupBy.person,
            onTap: () => onChanged(_GroupBy.person),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xff087E8B) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : Colors.black45,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterLabel extends StatelessWidget {
  final String title;
  final double amount;
  final String footer;
  final Color color;

  const _CenterLabel({
    super.key,
    required this.title,
    required this.amount,
    required this.footer,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _inr(amount),
            style: const TextStyle(
              color: Color(0xff1A1A1A),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          footer,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black45, fontSize: 11.5),
        ),
      ],
    );
  }
}

class _SliceBadge extends StatelessWidget {
  final _Slice slice;

  const _SliceBadge({required this.slice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: slice.icon != null
          ? Icon(slice.icon, size: 15, color: slice.color)
          : Text(
              _initial(slice.label),
              style: TextStyle(
                color: slice.color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

class _SliceTile extends StatelessWidget {
  final _Slice slice;
  final double percent; // 0..1
  final bool selected;
  final VoidCallback onTap;

  const _SliceTile({
    required this.slice,
    required this.percent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = slice.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? color.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: selected ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: slice.icon != null
                      ? Icon(slice.icon, color: color, size: 24)
                      : Text(
                          _initial(slice.label),
                          style: TextStyle(
                            color: color,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slice.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${slice.count} ${slice.count == 1 ? 'expense' : 'expenses'}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _inr(slice.amount),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(percent * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xff087E8B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: const Color(0xff087E8B)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

String _initial(String name) =>
    name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

/// Formats an amount in rupees with Indian digit grouping, e.g. ₹1,23,456.00
String _inr(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final intPart = parts[0];
  String grouped = intPart;

  if (intPart.length > 3) {
    final last3 = intPart.substring(intPart.length - 3);
    var rest = intPart.substring(0, intPart.length - 3);
    final chunks = <String>[];
    while (rest.length > 2) {
      chunks.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) chunks.insert(0, rest);
    grouped = '${chunks.join(',')},$last3';
  }

  return '₹$grouped.${parts[1]}';
}
