import 'package:ccs_app/export.dart';
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
                  icon: const Icon(IconsaxPlusLinear.arrow_left_1, size: 20),
                  onPressed: () => setState(() => selectedYear--),
                ),
                CommonText.bold(selectedYear.toString(), size: 18, color: scheme.onSurface),
                IconButton(
                  icon: const Icon(IconsaxPlusLinear.arrow_right_3, size: 20),
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
                      child: CommonText.medium(
                        monthStr,
                        size: 14,
                        color: isSelected ? scheme.onPrimary : scheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
