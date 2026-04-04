import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Navigation/History_Kusaku/history_models.dart';

String tabLabel(HistoryTab tab) {
  switch (tab) {
    case HistoryTab.all:
      return 'Semua';
    case HistoryTab.income:
      return 'Pemasukan';
    case HistoryTab.expense:
      return 'Pengeluaran';
  }
}

String formatCurrency(int amount) {
  final raw = amount.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < raw.length; i++) {
    final reverseIndex = raw.length - i;
    buffer.write(raw[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }

  return buffer.toString();
}

String formatHistoryTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour.$minute WIB';
}

String formatHistoryDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}

bool isSameHistoryDate(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

DateTime historyDateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

bool isWithinHistoryRange(
  DateTime value, {
  required DateTime startDate,
  required DateTime endDate,
}) {
  final date = historyDateOnly(value);
  final start = historyDateOnly(startDate);
  final end = historyDateOnly(endDate);
  return !date.isBefore(start) && !date.isAfter(end);
}

String monthName(int month) {
  const names = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  return names[month - 1];
}

IconData resolveHistoryIcon(HistoryTransaction transaction) {
  switch (transaction.category?.toLowerCase()) {
    case 'qris':
      return Icons.qr_code_rounded;
    case 'fuel':
      return Icons.local_gas_station_outlined;
    case 'transfer':
      return transaction.isExpense
          ? Icons.account_balance_wallet_outlined
          : Icons.south_west_rounded;
    case 'coffee':
      return Icons.local_cafe_outlined;
    case 'transport':
      return Icons.directions_bus_outlined;
    case 'gift':
      return Icons.favorite_border;
    default:
      return transaction.isExpense
          ? Icons.arrow_upward_rounded
          : Icons.arrow_downward_rounded;
  }
}

List<HistorySection> buildHistorySections({
  required List<HistoryTransaction> transactions,
  required HistoryTab selectedTab,
  required DateTime startDate,
  required DateTime endDate,
  DateTime? referenceDate,
}) {
  final filtered = transactions.where((transaction) {
    if (!isWithinHistoryRange(
      transaction.occurredAt,
      startDate: startDate,
      endDate: endDate,
    )) {
      return false;
    }

    switch (selectedTab) {
      case HistoryTab.all:
        return true;
      case HistoryTab.income:
        return transaction.type == HistoryTransactionType.income;
      case HistoryTab.expense:
        return transaction.type == HistoryTransactionType.expense;
    }
  }).toList()
    ..sort((left, right) => right.occurredAt.compareTo(left.occurredAt));

  final Map<DateTime, List<HistoryTransaction>> grouped = {};
  for (final transaction in filtered) {
    final date = historyDateOnly(transaction.occurredAt);
    grouped.putIfAbsent(date, () => []).add(transaction);
  }

  final today = historyDateOnly(referenceDate ?? DateTime.now());
  final sortedDates = grouped.keys.toList()
    ..sort((left, right) => right.compareTo(left));

  return sortedDates
      .map(
        (date) => HistorySection(
          date: date,
          title: isSameHistoryDate(date, today)
              ? 'Hari ini'
              : formatHistoryDate(date),
          transactions: grouped[date]!,
        ),
      )
      .toList();
}
