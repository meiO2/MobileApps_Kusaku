import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryTopSection extends StatelessWidget {
  final VoidCallback onFilterPressed;

  const HistoryTopSection({
    super.key,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF29459B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Mutasi KUSAKU',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onFilterPressed,
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const HistoryTabChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? const Color(0xFF2D79FF) : const Color(0xFFD1D5DB),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryTransactionList extends StatelessWidget {
  final List<HistorySection> sections;
  final bool isDimmed;
  final HistoryTab selectedTab;
  final ValueChanged<HistoryTab> onTabSelected;

  const HistoryTransactionList({
    super.key,
    required this.sections,
    required this.isDimmed,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isDimmed ? 0.4 : 1,
      child: IgnorePointer(
        ignoring: isDimmed,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
          itemCount: sections.length + 1,
          itemBuilder: (context, sectionIndex) {
            if (sectionIndex == 0) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: HistoryTabChip(
                        label: 'Semua',
                        isSelected: selectedTab == HistoryTab.all,
                        onTap: () => onTabSelected(HistoryTab.all),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: HistoryTabChip(
                        label: 'Pemasukan',
                        isSelected: selectedTab == HistoryTab.income,
                        onTap: () => onTabSelected(HistoryTab.income),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: HistoryTabChip(
                        label: 'Pengeluaran',
                        isSelected: selectedTab == HistoryTab.expense,
                        onTap: () => onTabSelected(HistoryTab.expense),
                      ),
                    ),
                  ],
                ),
              );
            }
            final section = sections[sectionIndex - 1];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
                  child: Text(
                    section.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ),
                for (final transaction in section.transactions)
                  HistoryTransactionTile(transaction: transaction),
              ],
            );
          },
        ),
      ),
    );
  }
}