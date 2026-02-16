import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:day_tracker/features/day_rating/data/models/diary_day.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/dashboard/data/models/week_stats.dart';
import 'package:day_tracker/features/dashboard/data/models/streak_data.dart';
import 'package:day_tracker/features/dashboard/data/models/insight.dart';
import 'package:day_tracker/features/dashboard/data/repositories/dashboard_repository.dart';

/// Generates PDF reports from diary data
class PdfReportGenerator {
  final List<DiaryDay> diaryDays;
  final List<Note> notes;
  final String username;
  final DateTime startDate;
  final DateTime endDate;

  late final DashboardRepository _repository;
  late final pw.Document _pdf;
  late final PdfColor _primaryColor;
  late final PdfColor _secondaryColor;

  PdfReportGenerator({
    required this.diaryDays,
    required this.notes,
    required this.username,
    required this.startDate,
    required this.endDate,
    PdfColor? primaryColor,
    PdfColor? secondaryColor,
  }) {
    _repository = DashboardRepository();
    _pdf = pw.Document();
    _primaryColor = primaryColor ?? PdfColors.purple;
    _secondaryColor = secondaryColor ?? PdfColors.grey700;
  }

  /// Generate the complete PDF report
  Future<Uint8List> generate() async {
    // Filter data to date range
    final filteredDays = _filterByDateRange(diaryDays);
    final filteredNotes = _filterNotesByDateRange(notes);

    // Calculate statistics for the date range
    final rangeStats = _calculateRangeStats(filteredDays, filteredNotes);
    final streak = _repository.calculateStreak(diaryDays); // Full data for streak
    final topActivities = _extractTopActivities(filteredNotes);

    // Generate insights
    final dashboardStats = _repository.generateDashboardStats(filteredDays, filteredNotes);
    final insights = dashboardStats.insights;

    // Build PDF pages
    _pdf.addPage(_buildCoverPage());
    _pdf.addPage(_buildSummaryPage(rangeStats, streak, topActivities, insights));
    _addChartsAndBreakdownPages(rangeStats);
    _addDiaryPages(filteredDays);

    return _pdf.save();
  }

  List<DiaryDay> _filterByDateRange(List<DiaryDay> days) {
    return days.where((day) {
      return !day.day.isBefore(startDate) && !day.day.isAfter(endDate);
    }).toList()
      ..sort((a, b) => b.day.compareTo(a.day));
  }

  List<Note> _filterNotesByDateRange(List<Note> notesList) {
    return notesList.where((note) {
      return !note.from.isBefore(startDate) && !note.from.isAfter(endDate);
    }).toList();
  }

  /// Calculate statistics for the custom date range
  WeekStats _calculateRangeStats(List<DiaryDay> days, List<Note> notesList) {
    if (days.isEmpty) {
      return WeekStats(
        averageScore: 0,
        completedDays: 0,
        categoryAverages: {},
        dailyScores: [],
      );
    }

    // Calculate average score and category totals
    double totalScore = 0;
    Map<String, double> categoryTotals = {};
    Map<String, int> categoryCounts = {};

    for (var day in days) {
      totalScore += day.overallScore;
      for (var rating in day.ratings) {
        final category = rating.dayRating.name;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + rating.score;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
    }

    final averageScore = totalScore / days.length;

    // Calculate category averages
    Map<String, double> categoryAverages = {};
    categoryTotals.forEach((category, total) {
      categoryAverages[category] = total / (categoryCounts[category] ?? 1);
    });

    // Create daily scores for all days in the range
    List<DayScore> dailyScores = [];
    DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final endDateNormalized = DateTime(endDate.year, endDate.month, endDate.day);

    while (!currentDate.isAfter(endDateNormalized)) {
      final dayData = days.where((d) =>
        d.day.year == currentDate.year &&
        d.day.month == currentDate.month &&
        d.day.day == currentDate.day
      ).firstOrNull;

      if (dayData != null) {
        Map<String, int> categoryScores = {};
        for (var rating in dayData.ratings) {
          categoryScores[rating.dayRating.name] = rating.score;
        }

        final dayNotes = notesList.where((note) =>
          note.from.year == currentDate.year &&
          note.from.month == currentDate.month &&
          note.from.day == currentDate.day
        ).length;

        dailyScores.add(DayScore(
          date: currentDate,
          totalScore: dayData.overallScore,
          categoryScores: categoryScores,
          noteCount: dayNotes,
          isComplete: dayData.ratings.isNotEmpty,
        ));
      } else {
        dailyScores.add(DayScore(
          date: currentDate,
          totalScore: 0,
          categoryScores: {},
          noteCount: 0,
          isComplete: false,
        ));
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return WeekStats(
      averageScore: averageScore,
      completedDays: days.length,
      categoryAverages: categoryAverages,
      dailyScores: dailyScores,
    );
  }

  List<String> _extractTopActivities(List<Note> notesList) {
    final categoryCount = <String, int>{};
    for (var note in notesList) {
      final category = note.noteCategory.title;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    final sorted = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) => e.key).toList();
  }

  /// Cover page with title and date range
  pw.Page _buildCoverPage() {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Diary Report',
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                username,
                style: pw.TextStyle(
                  fontSize: 24,
                  color: _secondaryColor,
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _primaryColor, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Report Period',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: _secondaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '${DateFormat('MMMM d, yyyy').format(startDate)} - ${DateFormat('MMMM d, yyyy').format(endDate)}',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 60),
              pw.Text(
                'Generated on ${DateFormat('MMMM d, yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Summary page with key statistics
  pw.Page _buildSummaryPage(
    WeekStats weekStats,
    StreakData streak,
    List<String> topActivities,
    List<dynamic> insights,
  ) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Summary'),
            pw.SizedBox(height: 20),

            // Stats grid
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildStatCard(
                    'Current Streak',
                    '${streak.currentStreak} days',
                    PdfColors.orange,
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: _buildStatCard(
                    'Longest Streak',
                    '${streak.longestStreak} days',
                    PdfColors.green,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Row(
              children: [
                pw.Expanded(
                  child: _buildStatCard(
                    'Average Score',
                    weekStats.averageScore.toStringAsFixed(1),
                    _primaryColor,
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: _buildStatCard(
                    'Days Logged',
                    '${weekStats.completedDays}',
                    PdfColors.blue,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Category averages
            if (weekStats.categoryAverages.isNotEmpty) ...[
              _buildSectionHeader('Category Averages'),
              pw.SizedBox(height: 16),
              ...weekStats.categoryAverages.entries.map((entry) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8),
                  child: _buildCategoryBar(
                    entry.key,
                    entry.value,
                    _getCategoryColor(entry.key),
                  ),
                );
              }),
              pw.SizedBox(height: 30),
            ],

            // Top activities
            if (topActivities.isNotEmpty) ...[
              _buildSectionHeader('Top Activities'),
              pw.SizedBox(height: 16),
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topActivities.take(5).map((activity) {
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(16),
                    ),
                    child: pw.Text(activity, style: const pw.TextStyle(fontSize: 11)),
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 30),
            ],

            // Mood Patterns & Insights
            if (insights.isNotEmpty) ...[
              _buildSectionHeader('Mood Patterns & Insights'),
              pw.SizedBox(height: 16),
              ...insights.take(5).map((insight) {
                final insightObj = insight as Insight;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: _getInsightColor(insightObj.type),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(
                      color: _getInsightBorderColor(insightObj.type),
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        insightObj.title,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: _getInsightBorderColor(insightObj.type),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        insightObj.description,
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }

  /// Charts and daily breakdown pages
  void _addChartsAndBreakdownPages(WeekStats weekStats) {
    final dailyScores = weekStats.dailyScores;

    // Split daily scores into weekly chunks for chart rendering
    final chartChunks = <List<DayScore>>[];
    if (dailyScores.length <= 10) {
      chartChunks.add(dailyScores);
    } else {
      // Group by week (7 days per chart)
      for (var i = 0; i < dailyScores.length; i += 7) {
        final end = (i + 7 > dailyScores.length) ? dailyScores.length : i + 7;
        chartChunks.add(dailyScores.sublist(i, end));
      }
    }

    // Charts page(s) using MultiPage
    _pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Mood Trends',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey500,
                ),
              ),
            ],
          ),
        ),
        build: (context) {
          final widgets = <pw.Widget>[];

          // Charts
          if (dailyScores.isNotEmpty) {
            for (var i = 0; i < chartChunks.length; i++) {
              if (chartChunks.length > 1) {
                final startDate = DateFormat('MMM d').format(chartChunks[i].first.date);
                final endDate = DateFormat('MMM d').format(chartChunks[i].last.date);
                widgets.add(pw.Text(
                  'Daily Scores ($startDate - $endDate)',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ));
              } else {
                widgets.add(pw.Text(
                  'Daily Scores',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ));
              }
              widgets.add(pw.SizedBox(height: 12));
              widgets.add(_buildLineChart(chartChunks[i]));
              widgets.add(pw.SizedBox(height: 20));
            }
          }

          // Daily breakdown table
          widgets.add(_buildSectionHeader('Daily Breakdown'));
          widgets.add(pw.SizedBox(height: 16));
          widgets.add(_buildDailyTable(dailyScores));

          return widgets;
        },
      ),
    );
  }

  /// Add pages for diary entries
  void _addDiaryPages(List<DiaryDay> days) {
    if (days.isEmpty) return;

    // Group entries by week
    final groupedByWeek = <String, List<DiaryDay>>{};
    for (final day in days) {
      final weekKey = _getWeekKey(day.day);
      groupedByWeek.putIfAbsent(weekKey, () => []).add(day);
    }

    _pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Diary Entries',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber}',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey500,
                ),
              ),
            ],
          ),
        ),
        build: (context) {
          final widgets = <pw.Widget>[];

          for (final entry in groupedByWeek.entries) {
            // Week header
            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
                padding: const pw.EdgeInsets.all(8),
                color: PdfColors.grey200,
                child: pw.Text(
                  entry.key,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );

            // Days in week
            for (final day in entry.value) {
              widgets.add(_buildDayEntry(day));
            }
          }

          return widgets;
        },
      ),
    );
  }

  pw.Widget _buildDayEntry(DiaryDay day) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Date header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                DateFormat('EEEE, MMMM d').format(day.day),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: _getScoreColor(day.overallScore),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(
                  'Score: ${day.overallScore}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Ratings row
          if (day.ratings.isNotEmpty)
            pw.Row(
              children: day.ratings.map((rating) {
                return pw.Expanded(
                  child: pw.Container(
                    margin: const pw.EdgeInsets.only(right: 8),
                    padding: const pw.EdgeInsets.all(4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          _formatRatingName(rating.dayRating.name),
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                        pw.Text(
                          '${rating.score}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

          // Notes
          if (day.notes.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 4),
            ...day.notes.map((note) => _buildNoteEntry(note)),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildNoteEntry(Note note) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 8,
            height: 8,
            margin: const pw.EdgeInsets.only(top: 4, right: 8),
            decoration: pw.BoxDecoration(
              color: _noteCategoryColor(note.noteCategory.title),
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        note.title.isNotEmpty
                            ? note.title
                            : note.noteCategory.title,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          fontStyle: note.title.isEmpty
                              ? pw.FontStyle.italic
                              : null,
                        ),
                      ),
                    ),
                    pw.Text(
                      note.isAllDay
                          ? 'All day'
                          : '${DateFormat('HH:mm').format(note.from)} - ${DateFormat('HH:mm').format(note.to)}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
                if (note.description.isNotEmpty)
                  pw.Text(
                    note.description,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                    maxLines: 3,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets and methods

  pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 2),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  pw.Widget _buildStatCard(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color, width: 2),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCategoryBar(String category, double value, PdfColor color) {
    final percentage = (value / 5.0).clamp(0.0, 1.0);
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            _formatRatingName(category),
            style: const pw.TextStyle(fontSize: 11),
          ),
        ),
        pw.Expanded(
          child: pw.LayoutBuilder(
            builder: (context, constraints) {
              return pw.Stack(
                children: [
                  pw.Container(
                    height: 16,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                  ),
                  pw.Container(
                    width: constraints!.maxWidth * percentage,
                    height: 16,
                    decoration: pw.BoxDecoration(
                      color: color,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          value.toStringAsFixed(1),
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildLineChart(List<DayScore> scores) {
    if (scores.isEmpty) {
      return pw.Container(
        height: 150,
        child: pw.Center(child: pw.Text('No data available')),
      );
    }

    // Collect all category names for consistent ordering
    final allCategories = <String>{};
    for (var score in scores) {
      allCategories.addAll(score.categoryScores.keys);
    }
    final categoryList = allCategories.toList()..sort();

    final maxScore = 20.0;
    final chartHeight = 140.0;
    final yLabelWidth = 30.0;
    final chartWidth = 420.0;
    final pointWidth = chartWidth / scores.length;
    const ySteps = [0, 5, 10, 15, 20];

    return pw.Container(
      height: chartHeight + 55, // Extra space for labels + legend
      child: pw.Column(
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Y-axis labels
              pw.SizedBox(
                width: yLabelWidth,
                height: chartHeight,
                child: pw.Stack(
                  children: ySteps.map((value) {
                    final y = chartHeight - (value / maxScore) * chartHeight - 4;
                    return pw.Positioned(
                      top: y,
                      left: 0,
                      child: pw.Text(
                        '$value',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Chart area
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.SizedBox(
                      height: chartHeight,
                      child: pw.CustomPaint(
                        size: PdfPoint(chartWidth, chartHeight),
                        painter: (canvas, size) {
                          // Draw horizontal grid lines
                          for (final value in ySteps) {
                            final y = (value / maxScore) * chartHeight;
                            canvas
                              ..setStrokeColor(PdfColors.grey300)
                              ..setLineWidth(0.5)
                              ..drawLine(0, y, chartWidth, y)
                              ..strokePath();
                          }

                          // Draw stacked bars per category
                          for (int i = 0; i < scores.length; i++) {
                            final score = scores[i];
                            if (score.totalScore == 0) continue;
                            final x = i * pointWidth + pointWidth * 0.15;
                            final width = pointWidth * 0.7;

                            if (score.categoryScores.isNotEmpty) {
                              // Stacked bar: each category stacked on top
                              double currentY = 0;
                              for (final cat in categoryList) {
                                final catScore = score.categoryScores[cat];
                                if (catScore == null || catScore == 0) continue;
                                final segmentHeight = (catScore / maxScore) * chartHeight;
                                final color = _getCategoryColor(cat);
                                canvas
                                  ..setFillColor(color)
                                  ..drawRect(x, currentY, width, segmentHeight)
                                  ..fillPath();
                                currentY += segmentHeight;
                              }
                            } else {
                              // Fallback: single color bar
                              final barHeight = (score.totalScore / maxScore) * chartHeight;
                              canvas
                                ..setFillColor(_primaryColor)
                                ..drawRect(x, 0, width, barHeight)
                                ..fillPath();
                            }
                          }
                        },
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    // Date labels
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                      children: scores.map((score) {
                        return pw.SizedBox(
                          width: pointWidth,
                          child: pw.Text(
                            DateFormat('E\nd').format(score.date),
                            style: const pw.TextStyle(fontSize: 7),
                            textAlign: pw.TextAlign.center,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Legend row
          if (categoryList.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: categoryList.map((cat) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(right: 12),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Container(
                        width: 8,
                        height: 8,
                        decoration: pw.BoxDecoration(
                          color: _getCategoryColor(cat),
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                      ),
                      pw.SizedBox(width: 3),
                      pw.Text(
                        _formatRatingName(cat),
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildDailyTable(List<DayScore> scores) {
    if (scores.isEmpty) {
      return pw.Text('No data available');
    }

    // Collect all category names from all scores for consistent columns
    final allCategories = <String>{};
    for (var score in scores) {
      allCategories.addAll(score.categoryScores.keys);
    }
    final categoryList = allCategories.toList()..sort();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5), // Date
        for (var i = 0; i < categoryList.length; i++)
          i + 1: const pw.FlexColumnWidth(1), // Category columns
        categoryList.length + 1: const pw.FlexColumnWidth(1), // Total
        categoryList.length + 2: const pw.FlexColumnWidth(1), // Notes
        categoryList.length + 3: const pw.FlexColumnWidth(1.2), // Status
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _primaryColor),
          children: [
            _tableCell('Date', isHeader: true, color: PdfColors.white),
            ...categoryList.map((cat) =>
              _tableCell(_formatRatingName(cat), isHeader: true, color: PdfColors.white, fontSize: 8)),
            _tableCell('Total', isHeader: true, color: PdfColors.white),
            _tableCell('Notes', isHeader: true, color: PdfColors.white),
            _tableCell('Status', isHeader: true, color: PdfColors.white),
          ],
        ),
        // Data rows
        ...scores.map((score) {
          final rowColor = _getRowColor(score);
          final hasNotes = score.noteCount > 0;
          final hasData = score.isComplete || hasNotes;

          return pw.TableRow(
            decoration: pw.BoxDecoration(color: rowColor),
            children: [
              _tableCell(
                DateFormat('EEE, MMM d').format(score.date),
                fontColor: hasData ? PdfColors.black : PdfColors.grey500,
              ),
              ...categoryList.map((cat) {
                final catScore = score.categoryScores[cat];
                if (catScore == null) {
                  return _tableCell('-',
                    textAlign: pw.TextAlign.center,
                    fontColor: PdfColors.grey400,
                  );
                }
                return _buildCategoryScoreCell(cat, catScore);
              }),
              // Total score
              _buildTotalScoreCell(score.totalScore, score.isComplete),
              // Note count
              _tableCell(
                score.noteCount > 0 ? '${score.noteCount}' : '-',
                textAlign: pw.TextAlign.center,
                fontColor: score.noteCount > 0 ? PdfColors.black : PdfColors.grey400,
              ),
              // Status indicator
              _buildStatusCell(score),
            ],
          );
        }),
      ],
    );
  }

  /// Get row background color based on day status
  PdfColor _getRowColor(DayScore score) {
    if (score.isComplete && score.noteCount > 0) {
      return const PdfColor(0.9, 0.97, 0.9); // Light green - fully complete
    } else if (score.isComplete) {
      return const PdfColor(0.92, 0.98, 0.92); // Lighter green - rated but no notes
    } else if (score.noteCount > 0) {
      return const PdfColor(1.0, 0.97, 0.88); // Light yellow - notes only
    } else {
      return const PdfColor(0.97, 0.97, 0.97); // Light gray - nothing logged
    }
  }

  /// Build a colored category score cell
  pw.Widget _buildCategoryScoreCell(String category, int score) {
    final color = _getCategoryColor(category);
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: pw.BoxDecoration(
          color: _lighten(color, 0.85),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          '$score',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  /// Build total score cell with color gradient
  pw.Widget _buildTotalScoreCell(int totalScore, bool isComplete) {
    if (!isComplete && totalScore == 0) {
      return _tableCell('-', textAlign: pw.TextAlign.center, fontColor: PdfColors.grey400);
    }
    final color = _getScoreColor(totalScore);
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          '$totalScore',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  /// Build status cell with visual indicator
  pw.Widget _buildStatusCell(DayScore score) {
    String label;
    PdfColor bgColor;
    PdfColor textColor;

    if (score.isComplete && score.noteCount > 0) {
      label = 'Full';
      bgColor = PdfColors.green;
      textColor = PdfColors.white;
    } else if (score.isComplete) {
      label = 'Rated';
      bgColor = PdfColors.lightGreen;
      textColor = PdfColors.white;
    } else if (score.noteCount > 0) {
      label = 'Notes';
      bgColor = PdfColors.amber;
      textColor = PdfColors.white;
    } else {
      label = 'Empty';
      bgColor = PdfColors.grey400;
      textColor = PdfColors.white;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: pw.Alignment.center,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: textColor,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  pw.Widget _tableCell(String text, {
    bool isHeader = false,
    PdfColor? color,
    PdfColor? fontColor,
    pw.TextAlign? textAlign,
    double fontSize = 10,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: textAlign == pw.TextAlign.center ? pw.Alignment.center : null,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? fontSize : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
          color: color ?? fontColor,
        ),
        textAlign: textAlign,
      ),
    );
  }

  String _getWeekKey(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    return 'Week of ${DateFormat('MMM d').format(weekStart)}';
  }

  String _formatRatingName(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Create a lighter tint of a color by mixing with white
  PdfColor _lighten(PdfColor color, double amount) {
    return PdfColor(
      color.red + (1.0 - color.red) * amount,
      color.green + (1.0 - color.green) * amount,
      color.blue + (1.0 - color.blue) * amount,
    );
  }

  PdfColor _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return PdfColors.blue;
      case 'productivity':
        return PdfColors.green;
      case 'sport':
        return PdfColors.orange;
      case 'food':
        return PdfColors.amber;
      default:
        return _primaryColor;
    }
  }

  PdfColor _getScoreColor(int score) {
    if (score < 6) return PdfColors.red;
    if (score < 10) return PdfColors.orange;
    if (score < 14) return PdfColors.amber;
    if (score < 18) return PdfColors.lightGreen;
    return PdfColors.green;
  }

  PdfColor _noteCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
      case 'arbeit':
        return PdfColors.purple;
      case 'leisure':
      case 'freizeit':
        return PdfColors.lightBlue;
      case 'food':
      case 'essen':
        return PdfColors.amber;
      case 'gym':
        return PdfColors.green;
      case 'sleep':
      case 'schlafen':
        return PdfColors.grey;
      default:
        return PdfColors.blueGrey;
    }
  }

  PdfColor _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.correlation:
        return _lighten(PdfColors.blue, 0.85);
      case InsightType.trend:
        return _lighten(PdfColors.green, 0.85);
      case InsightType.dayPattern:
        return _lighten(PdfColors.orange, 0.85);
      case InsightType.recommendation:
        return _lighten(PdfColors.purple, 0.85);
      case InsightType.achievement:
      case InsightType.improvement:
      case InsightType.milestone:
        return _lighten(_primaryColor, 0.85);
      case InsightType.warning:
        return _lighten(PdfColors.red, 0.85);
      case InsightType.suggestion:
        return _lighten(PdfColors.amber, 0.85);
    }
  }

  PdfColor _getInsightBorderColor(InsightType type) {
    switch (type) {
      case InsightType.correlation:
        return PdfColors.blue;
      case InsightType.trend:
        return PdfColors.green;
      case InsightType.dayPattern:
        return PdfColors.orange;
      case InsightType.recommendation:
        return PdfColors.purple;
      case InsightType.achievement:
      case InsightType.improvement:
      case InsightType.milestone:
        return _primaryColor;
      case InsightType.warning:
        return PdfColors.red;
      case InsightType.suggestion:
        return PdfColors.amber;
    }
  }
}
