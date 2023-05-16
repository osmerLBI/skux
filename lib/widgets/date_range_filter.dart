import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:span_mobile/common/style.dart';
import 'package:span_mobile/common/util.dart';
import 'package:span_mobile/widgets/line_separator.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateRangeFilter extends StatefulWidget {
  final PickerDateRange initialDateRange;
  final Function(PickerDateRange dateRange) onChanged;

  const DateRangeFilter({
    Key key,
    this.initialDateRange,
    @required this.onChanged,
  }) : super(key: key);

  @override
  _DateRangeFilterState createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  PickerDateRange _dateRange;

  @override
  void initState() {
    super.initState();

    _dateRange = PickerDateRange(
      widget.initialDateRange?.startDate,
      widget.initialDateRange?.endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: _dateRange.startDate == null
                    ? Text(
                        tr('Unlimited'),
                        style: const TextStyle(
                          color: Colors.black45,
                        ),
                      )
                    : Text(
                        Jiffy(_dateRange.startDate).yMd,
                        style: TextStyle(
                          color: style.primaryColor,
                          fontFamily: style.fontFamily5,
                        ),
                      ),
              ),
              const Text('~'),
              Expanded(
                child: _dateRange.endDate == null
                    ? Text(
                        tr('Unlimited'),
                        style: const TextStyle(
                          color: Colors.black45,
                        ),
                        textAlign: TextAlign.right,
                      )
                    : Text(
                        Jiffy(_dateRange.endDate).yMd,
                        style: TextStyle(
                          color: style.primaryColor,
                          fontFamily: style.fontFamily5,
                        ),
                        textAlign: TextAlign.right,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const LineSeparator(),
          const SizedBox(height: 8),
          SizedBox(
            width: 300,
            height: 300,
            child: SfDateRangePicker(
              monthViewSettings: DateRangePickerMonthViewSettings(
                firstDayOfWeek:
                    MaterialLocalizations.of(context).firstDayOfWeekIndex,
              ),
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: _dateRange,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                _dateRange = args.value as PickerDateRange;
                setState(() {});
                widget.onChanged(_dateRange);
              },
            ),
          ),
        ],
      ),
    );
  }
}

void showDateRangeFilterDialog({
  BuildContext context,
  PickerDateRange initialDateRange,
  @required void Function(PickerDateRange) onChanged,
}) {
  PickerDateRange dateRange = PickerDateRange(
    initialDateRange?.startDate,
    initialDateRange?.endDate,
  );
  showDialog<void>(
    context: context ?? Util.context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(tr('Select Date Range')),
        content: DateRangeFilter(
          initialDateRange: dateRange,
          onChanged: (PickerDateRange _) {
            dateRange = _;
          },
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: style.errorColor,
            ),
            child: Text(
              tr('Clear'),
              style: TextStyle(
                color: style.errorColor,
              ),
            ),
            onPressed: () {
              onChanged(null);
              Navigator.of(dialogContext).pop();
            },
          ),
          const SizedBox(width: 5),
          ElevatedButton(
            child: Text(tr('Search')),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            ),
            onPressed: () {
              onChanged(dateRange);
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}
