import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Navigation/History_Kusaku/history_dummy_data.dart';
import 'package:frontend_kusaku/Navigation/History_Kusaku/history_models.dart';
import 'package:frontend_kusaku/Navigation/History_Kusaku/history_utils.dart';
import 'package:frontend_kusaku/Widgets/history_widgets.dart';

class HistoryPage extends StatefulWidget {
  final List<HistoryTransaction>? transactions;

  const HistoryPage({super.key, this.transactions});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryTab _selectedTab = HistoryTab.all;
  bool _showFilterOverlay = false;
  late HistoryFilterDraft _appliedFilter;
  late HistoryFilterDraft _filterDraft;

  List<HistoryTransaction> get _transactions =>
      widget.transactions ?? historyDummyTransactions;

  List<HistorySection> get _visibleSections => buildHistorySections(
    transactions: _transactions,
    selectedTab: _selectedTab,
    startDate: _appliedFilter.startDate,
    endDate: _appliedFilter.endDate,
  );

  DateTime get _latestTransactionDate {
    if (_transactions.isEmpty) {
      return DateTime.now();
    }

    final sorted = [..._transactions]
      ..sort((left, right) => right.occurredAt.compareTo(left.occurredAt));
    return sorted.first.occurredAt;
  }

  @override
  void initState() {
    super.initState();
    final initialFilter = HistoryFilterDraft.initial(now: _latestTransactionDate);
    _appliedFilter = initialFilter;
    _filterDraft = initialFilter;
  }

  void _handleTabChange(HistoryTab tab) {
    setState(() {
      _selectedTab = tab;
      _appliedFilter = _appliedFilter.copyWith(category: tab);
    });
  }

  void _openFilter() {
    setState(() {
      _filterDraft = _appliedFilter.copyWith(
        category: _selectedTab,
        activePicker: ActiveDatePicker.none,
      );
      _showFilterOverlay = true;
    });
  }

  void _closeFilter() {
    setState(() {
      _showFilterOverlay = false;
      _filterDraft = _appliedFilter.copyWith(activePicker: ActiveDatePicker.none);
    });
  }

  void _selectCategory(HistoryTab tab) {
    setState(() {
      _filterDraft = _filterDraft.copyWith(category: tab);
    });
  }

  void _openDatePicker(ActiveDatePicker picker) {
    setState(() {
      final selectedDate = picker == ActiveDatePicker.end
          ? _filterDraft.endDate
          : _filterDraft.startDate;
      _filterDraft = _filterDraft.copyWith(
        activePicker: picker,
        focusedMonth: DateTime(selectedDate.year, selectedDate.month),
      );
    });
  }

  void _changeCalendarMonth(int delta) {
    setState(() {
      _filterDraft = _filterDraft.copyWith(
        focusedMonth: DateTime(
          _filterDraft.focusedMonth.year,
          _filterDraft.focusedMonth.month + delta,
          1,
        ),
      );
    });
  }

  void _selectCalendarDay(DateTime day) {
    setState(() {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      if (_filterDraft.activePicker == ActiveDatePicker.start) {
        final nextEndDate = normalizedDay.isAfter(_filterDraft.endDate)
            ? normalizedDay
            : _filterDraft.endDate;
        _filterDraft = _filterDraft.copyWith(
          startDate: normalizedDay,
          endDate: nextEndDate,
        );
      } else if (_filterDraft.activePicker == ActiveDatePicker.end) {
        final nextStartDate = normalizedDay.isBefore(_filterDraft.startDate)
            ? normalizedDay
            : _filterDraft.startDate;
        _filterDraft = _filterDraft.copyWith(
          startDate: nextStartDate,
          endDate: normalizedDay,
        );
      }
    });
  }

  void _cancelDatePicker() {
    setState(() {
      _filterDraft = _filterDraft.copyWith(activePicker: ActiveDatePicker.none);
    });
  }

  void _applyFilter() {
    setState(() {
      _selectedTab = _filterDraft.category;
      _appliedFilter = _filterDraft.copyWith(
        activePicker: ActiveDatePicker.none,
      );
      _showFilterOverlay = false;
      _filterDraft = _appliedFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                HistoryTopSection(
                  onFilterPressed: _openFilter,
                ),
                Expanded(
                  child: HistoryTransactionList(
                    sections: _visibleSections,
                    isDimmed: _showFilterOverlay,
                    selectedTab: _selectedTab,
                    onTabSelected: _handleTabChange,
                  ),
                ),
              ],
            ),
            if (_showFilterOverlay)
              Positioned.fill(
                child: HistoryFilterOverlay(
                  draft: _filterDraft,
                  onClose: _closeFilter,
                  onSubmit: _applyFilter,
                  onCategorySelected: _selectCategory,
                  onDateFieldTap: _openDatePicker,
                  onDatePickerCancelled: _cancelDatePicker,
                  onMonthChanged: _changeCalendarMonth,
                  onDaySelected: _selectCalendarDay,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
