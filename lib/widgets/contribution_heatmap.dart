import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

enum HeatmapViewType { week, month, year }

class ContributionHeatmap extends StatefulWidget {
  final Map<DateTime, int> data;
  final HeatmapViewType initialViewType;

  const ContributionHeatmap({
    super.key,
    required this.data,
    this.initialViewType = HeatmapViewType.month,
  });

  @override
  State<ContributionHeatmap> createState() => _ContributionHeatmapState();
}

class _ContributionHeatmapState extends State<ContributionHeatmap> {
  late HeatmapViewType _viewType;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewType = widget.initialViewType;

    // スクロールバーを右端に寄せるために少し遅れてスクロールする
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // セグメントコントロール（期間切り替え）
          _buildViewToggle(context),
          const SizedBox(height: 16),
          // ヒートマップ本体
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getViewTitle(context),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 曜日のラベル (Sun, Mon, Wed, Fri)
                    _buildDayLabels(context),
                    const SizedBox(width: 8),
                    // メインのグリッド（横スクロール可能）
                    Expanded(
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          child: _buildHeatmapGrid(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 凡例 (Less ... More)
                _buildLegend(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(context, l10n.heatmapWeek, HeatmapViewType.week),
          _buildToggleButton(context, l10n.heatmapMonth, HeatmapViewType.month),
          _buildToggleButton(context, l10n.heatmapYear, HeatmapViewType.year),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String label,
    HeatmapViewType type,
  ) {
    final isSelected = _viewType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _viewType = type;
          });
          // 切り替え後に右スクロール
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue[700] : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  String _getViewTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_viewType) {
      case HeatmapViewType.week:
        return l10n.heatmapTitleWeek;
      case HeatmapViewType.month:
        return l10n.heatmapTitleMonth;
      case HeatmapViewType.year:
        return l10n.heatmapTitleYear;
    }
  }

  Widget _buildDayLabels(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _dayLabel(l10n.daySun),
        _dayLabel(l10n.dayMon),
        _dayLabel(l10n.dayTue),
        _dayLabel(l10n.dayWed),
        _dayLabel(l10n.dayThu),
        _dayLabel(l10n.dayFri),
        _dayLabel(l10n.daySat),
      ],
    );
  }

  Widget _dayLabel(String label) {
    // 高さをセルの高さと余白に合わせる
    return Container(
      height: 14,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  Widget _buildHeatmapGrid(BuildContext context) {
    // 期間の計算
    // 日曜日始まりとする
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 今週の土曜日を終了日とする
    final daysUntilSaturday = 6 - (today.weekday % 7);
    final endOfWeek = today.add(Duration(days: daysUntilSaturday));

    DateTime startDate;
    switch (_viewType) {
      case HeatmapViewType.week:
        // 今週の日曜日
        startDate = endOfWeek.subtract(const Duration(days: 6));
        break;
      case HeatmapViewType.month:
        // 過去5週間（約1ヶ月）
        startDate = endOfWeek.subtract(const Duration(days: 7 * 5 - 1));
        break;
      case HeatmapViewType.year:
        // 過去52週間（約1年）
        startDate = endOfWeek.subtract(const Duration(days: 7 * 52 - 1));
        break;
    }

    final totalDays = endOfWeek.difference(startDate).inDays + 1;
    final totalColumns = totalDays ~/ 7;

    List<Widget> columns = [];

    // 正規化されたデータを準備
    // Mapのキー(DateTime)は時間を含んでいる可能性があるので、日付のみに揃える
    Map<DateTime, int> normalizedData = {};
    widget.data.forEach((key, value) {
      final dateOnly = DateTime(key.year, key.month, key.day);
      normalizedData[dateOnly] = (normalizedData[dateOnly] ?? 0) + value;
    });

    for (int col = 0; col < totalColumns; col++) {
      List<Widget> cells = [];
      for (int row = 0; row < 7; row++) {
        final currentDate = startDate.add(Duration(days: col * 7 + row));
        final count = normalizedData[currentDate] ?? 0;
        final isFuture = currentDate.isAfter(today);

        cells.add(
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            child: _buildHeatmapCell(context, currentDate, count, isFuture),
          ),
        );
      }
      columns.add(
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Column(children: cells),
        ),
      );
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: columns);
  }

  Widget _buildHeatmapCell(
    BuildContext context,
    DateTime date,
    int count,
    bool isFuture,
  ) {
    Color color;
    if (isFuture) {
      color = Colors.transparent;
    } else if (count == 0) {
      color = Colors.grey[200]!;
    } else if (count <= 2) {
      color = const Color(0xFF9BE9A8); // 薄い緑
    } else if (count <= 4) {
      color = const Color(0xFF40C463); // 緑
    } else if (count <= 6) {
      color = const Color(0xFF30A14E); // 濃い緑
    } else {
      color = const Color(0xFF216E39); // 最も濃い緑
    }

    final formattedDate = DateFormat('yyyy/MM/dd').format(date);
    final tooltipMessage = isFuture
        ? ''
        : AppLocalizations.of(context)!.heatmapTooltip(formattedDate, count);

    return Tooltip(
      message: tooltipMessage,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: isFuture ? Border.all(color: Colors.transparent) : null,
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          l10n.heatmapLess,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(width: 4),
        _legendCell(Colors.grey[200]!),
        _legendCell(const Color(0xFF9BE9A8)),
        _legendCell(const Color(0xFF40C463)),
        _legendCell(const Color(0xFF30A14E)),
        _legendCell(const Color(0xFF216E39)),
        const SizedBox(width: 4),
        Text(
          l10n.heatmapMore,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _legendCell(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
