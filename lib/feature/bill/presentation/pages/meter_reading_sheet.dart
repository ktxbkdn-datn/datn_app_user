import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeterReadingSheet extends StatefulWidget {
  final String serviceTitle;
  final int serviceId;
  final Function(double, int, String) onSubmit; // callback for (reading, year, month)

  const MeterReadingSheet({
    required this.serviceTitle,
    required this.serviceId,
    required this.onSubmit,
    super.key,
  });

  @override
  State<MeterReadingSheet> createState() => _MeterReadingSheetState();
}

class _MeterReadingSheetState extends State<MeterReadingSheet> {
  late TextEditingController _controller;
  late int selectedYear;
  late String selectedMonth;
  List<Map<String, dynamic>> availableYearMonths = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    
    // Get current date
    DateTime now = DateTime.now();
    int currentYear = now.year;
    int currentMonth = now.month;
    
    // Calculate valid years and months (current month and previous month only)
    DateTime earliestDate = DateTime(currentYear, currentMonth - 1, 1);
    DateTime latestDate = now;
    
    // Set defaults
    selectedYear = currentYear;
    selectedMonth = DateFormat('MM').format(now);
    
    // Create list of valid year-months
    for (int year = earliestDate.year; year <= latestDate.year; year++) {
      int startMonth = (year == earliestDate.year) ? earliestDate.month : 1;
      int endMonth = (year == latestDate.year) ? latestDate.month : 12;

      for (int month = startMonth; month <= endMonth; month++) {
        availableYearMonths.add({
          'year': year,
          'month': month < 10 ? '0$month' : '$month',
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // If text field has content, ask for confirmation before exiting
        if (_controller.text.isNotEmpty) {
          bool shouldPop = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Xác nhận'),
              content: const Text('Bạn có chắc muốn hủy nhập chỉ số? Dữ liệu đã nhập sẽ bị mất.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), // Don't pop, continue entering
                  child: const Text('Tiếp tục nhập'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true), // Allow pop, exit screen
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Hủy nhập'),
                ),
              ],
            ),
          ) ?? false; // Default to false if dialog is dismissed
          
          return shouldPop;
        }
        
        // If no text entered, just go back
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Nhập chỉ số ${widget.serviceTitle}"),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Year selection
                    const Text(
                      "Chọn năm",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: selectedYear,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                        ),
                        items: availableYearMonths
                            .map((ym) => ym['year'])
                            .toSet() // Get unique years
                            .map((year) => DropdownMenuItem<int>(
                                  value: year,
                                  child: Text(year.toString()),
                                ))
                            .toList(),
                        onChanged: (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedYear = newValue;
                              
                              // Check if current month is valid for selected year
                              bool isMonthValid = availableYearMonths
                                  .any((ym) => ym['year'] == selectedYear && ym['month'] == selectedMonth);
                              
                              if (!isMonthValid) {
                                // Set to first available month for this year
                                final firstMonth = availableYearMonths
                                    .firstWhere((ym) => ym['year'] == selectedYear)['month'];
                                selectedMonth = firstMonth;
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Month selection
                    const Text(
                      "Chọn tháng",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedMonth,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                        ),
                        items: availableYearMonths
                            .where((ym) => ym['year'] == selectedYear)
                            .map((ym) => DropdownMenuItem<String>(
                                  value: ym['month'],
                                  child: Text('Tháng ${ym['month']}'),
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedMonth = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Current reading input
                    const Text(
                      "Chỉ số tháng này",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextFormField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1F2937),
                        ),
                        decoration: const InputDecoration(
                          hintText: "Nhập chỉ số hiện tại",
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [                        // Cancel button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // If text field has content, ask for confirmation before exiting
                              if (_controller.text.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xác nhận'),
                                    content: const Text('Bạn có chắc muốn hủy nhập chỉ số? Dữ liệu đã nhập sẽ bị mất.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => mounted ? Navigator.pop(context) : null, // Close dialog
                                        child: const Text('Tiếp tục nhập'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (mounted) Navigator.pop(context); // Close dialog
                                          if (mounted) Navigator.pop(context); // Go back to previous screen
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                        ),
                                        child: const Text('Hủy nhập'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                if (mounted) Navigator.pop(context);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.indigo,
                              side: const BorderSide(color: Colors.indigo),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Hủy",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Submit button with gradient
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_controller.text.isEmpty) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Vui lòng nhập chỉ số tháng này")),
                                    );
                                  }
                                  return;
                                }
                                double current;
                                try {
                                  current = double.parse(_controller.text);
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Chỉ số phải là một số hợp lệ")),
                                    );
                                  }
                                  return;
                                }
                                if (current < 0) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Chỉ số không được âm")),
                                    );
                                  }
                                  return;
                                }
                                _controller.clear();
                                widget.onSubmit(current, selectedYear, selectedMonth);
                                if (mounted) Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Gửi chỉ số",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}