import 'package:flutter/material.dart';

enum HistoryTab { all, income, expense }

enum HistoryTransactionType { income, expense }

enum ActiveDatePicker { none, start, end }

class HistoryTransaction {
  final String title;
  final String timeLabel;
  final int amount;
  final String dateLabel;
  final HistoryTransactionType type;
  final IconData icon;

  const HistoryTransaction({
    required this.title,
    required this.timeLabel,
    required this.amount,
    required this.dateLabel,
    required this.type,
    required this.icon,
  });
}

class HistorySection {
  final String title;
  final List<HistoryTransaction> transactions;

  const HistorySection({
    required this.title,
    required this.transactions,
  });
}

class HistoryFilterDraft {
  final HistoryTab category;
  final String startDate;
  final String endDate;
  final ActiveDatePicker activePicker;
  final DateTime focusedMonth;

  const HistoryFilterDraft({
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.activePicker,
    required this.focusedMonth,
  });

  factory HistoryFilterDraft.initial() {
    return HistoryFilterDraft(
      category: HistoryTab.all,
      startDate: '28/02/2026',
      endDate: '28/02/2026',
      activePicker: ActiveDatePicker.none,
      focusedMonth: DateTime(2026, 2),
    );
  }

  HistoryFilterDraft copyWith({
    HistoryTab? category,
    String? startDate,
    String? endDate,
    ActiveDatePicker? activePicker,
    DateTime? focusedMonth,
  }) {
    return HistoryFilterDraft(
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      activePicker: activePicker ?? this.activePicker,
      focusedMonth: focusedMonth ?? this.focusedMonth,
    );
  }
}
