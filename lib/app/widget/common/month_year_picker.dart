import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Future<DateTime?> showMonthYearPicker(BuildContext context, DateTime initialDate) async {
  DateTime selectedDate = initialDate;
  int selectedYear = initialDate.year;

  return await showDialog<DateTime>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final scheme = Theme.of(context).colorScheme;
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                  onPressed: () => setState(() => selectedYear--),
                ),
                Text(selectedYear.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                  onPressed: () => setState(() => selectedYear++),
                ),
              ],
            ),
            content: SizedBox(
              width: 300,
              height: 300,
              child: GridView.builder(
                itemCount: 12,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  final monthStr = DateFormat('MMM').format(DateTime(selectedYear, index + 1));
                  final isSelected = selectedDate.month == index + 1 && selectedDate.year == selectedYear;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context, DateTime(selectedYear, index + 1, 1));
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected ? scheme.primary : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        monthStr,
                        style: TextStyle(
                          color: isSelected ? scheme.onPrimary : scheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );
}
