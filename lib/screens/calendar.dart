import 'package:akai/api/firebase_api.dart';
import 'package:akai/utils/constants/colors.dart';
import 'package:akai/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:akai/utils/theme/calendar_theme.dart';
import 'package:akai/utils/constants/sizes.dart';
import 'package:akai/utils/texts.dart';
import 'package:akai/utils/boxContainer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CustomCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final DateTime? rangeStartDay;
  final DateTime? rangeEndDay;
  final CalendarFormat calendarFormat;
  final void Function(DateTime, DateTime) onDaySelected;
  final List<MapEntry<DateTime, DateTime>> periodPredictions;
  final List<MapEntry<DateTime, DateTime>> fertilePredictions;
  final List<MapEntry<DateTime, DateTime>> pastPeriods;

  const CustomCalendar({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    this.rangeStartDay,
    this.rangeEndDay,
    required this.periodPredictions,
    required this.fertilePredictions,
    required this.pastPeriods,
  }) : super(key: key);

  bool _isDateInPeriodPredictions(DateTime date) {
    for (var range in periodPredictions) {
      if (date.isAfter(range.key.subtract(Duration(days: 1))) &&
          date.isBefore(range.value.add(Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }

  bool _isDateInFertilePredictions(DateTime date) {
    for (var range in fertilePredictions) {
      if (date.isAfter(range.key.subtract(Duration(days: 1))) &&
          date.isBefore(range.value.add(Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }

  bool _isDateInPastPeriods(DateTime date) {
    for (var range in pastPeriods) {
      if (date.isAfter(range.key.subtract(Duration(days: 1))) &&
          date.isBefore(range.value.add(Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      rangeSelectionMode: RangeSelectionMode.toggledOn,
      calendarStyle: TCalendarTheme.CalendarTheme,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          if (_isDateInPastPeriods(date)) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: TColors.bubblegumPink,
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text('${date.day}',
                      style: TextStyle(color: Colors.white))),
            );
          } else if (_isDateInPeriodPredictions(date)) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: TColors.bubblegumPink,
                  width: 2.0,
                ),
              ),
              child: Center(child: Text('${date.day}')),
            );
          } else if (_isDateInFertilePredictions(date)) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: TColors.lilac,
                  width: 2.0,
                ),
              ),
              child: Center(child: Text('${date.day}')),
            );
          }
          return null;
        },
      ),
      rowHeight: 40,
      focusedDay: focusedDay,
      firstDay: DateTime(2020),
      lastDay: DateTime(2027),
      selectedDayPredicate: (day) => isSameDay(day, selectedDay),
      rangeStartDay: rangeStartDay,
      rangeEndDay: rangeEndDay,
      availableGestures: AvailableGestures.all,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        onDaySelected(selectedDay, focusedDay);
      },
      calendarFormat: calendarFormat,
    );
  }
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late List<MapEntry<DateTime, DateTime>> _periodPredictions = [];
  late List<MapEntry<DateTime, DateTime>> _fertilePredictions = [];
  late List<MapEntry<DateTime, DateTime>> _pastPeriods = [];
  late DateTime currStart = DateTime.now();
  late DateTime currEnd = DateTime.now();

  int numMenses = 5;
  int cycleLength = 26;
  int daysTillPeriod = 12;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _rangeStartDay;
  DateTime? _rangeEndDay;
  bool _isPeriodBeingLogged = false; // New state variable

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDataFromServer();
  }

  Future<void> sendDataToServer() async {
    final String apiUrl =
        'https://akai-webapp-chfggua5dkb7g5bu.southafricanorth-01.azurewebsites.net/api/periods/saveperioddates';

    // Convert lists to JSON
    final periodPredictionsJson = _periodPredictions
        .map((e) => {
              'start': e.key.toIso8601String(),
              'end': e.value.toIso8601String()
            })
        .toList();

    final fertilePredictionsJson = _fertilePredictions
        .map((e) => {
              'start': e.key.toIso8601String(),
              'end': e.value.toIso8601String()
            })
        .toList();

    final pastPeriodsJson = _pastPeriods
        .map((e) => {
              'start': e.key.toIso8601String(),
              'end': e.value.toIso8601String()
            })
        .toList();

    final requestBody = jsonEncode({
      'periodPredictions': periodPredictionsJson,
      'fertilePredictions': fertilePredictionsJson,
      'pastPeriods': pastPeriodsJson,
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await secureStorage.read(key: 'token')}',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        // Successfully sent
        print('Data sent successfully');
      } else {
        // Handle errors here
        print('Failed to fetch data: ${response.statusCode}');
        try {
          final errorData = jsonDecode(response.body);
          print('Error response: ${errorData['error']}');
        } catch (e) {
          print('Error parsing error response: $e');
        }
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
    }
  }

  Future<void> fetchDataFromServer() async {
    final String apiUrl =
        'https://akai-webapp-chfggua5dkb7g5bu.southafricanorth-01.azurewebsites.net/api/periods/getperioddates'; // Replace with your URL

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await secureStorage.read(key: 'token')}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _periodPredictions = (data['periodPredictions'] as List)
              .map((e) => MapEntry(
                    DateTime.parse(e['start']),
                    DateTime.parse(e['end']),
                  ))
              .toList();
          _fertilePredictions = (data['fertilePredictions'] as List)
              .map((e) => MapEntry(
                    DateTime.parse(e['start']),
                    DateTime.parse(e['end']),
                  ))
              .toList();
          _pastPeriods = (data['pastPeriods'] as List)
              .map((e) => MapEntry(
                    DateTime.parse(e['start']),
                    DateTime.parse(e['end']),
                  ))
              .toList();
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  DateTime? findNextPredictedDate() {
    DateTime today = DateTime.now();
    DateTime? nextDate;

    for (var entry in _periodPredictions) {
      if (entry.key.isAfter(today)) {
        if (nextDate == null || entry.key.isBefore(nextDate)) {
          nextDate = entry.key;
        }
      }
    }

    return nextDate;
  }

  int get daysTillNextPeriod {
    DateTime? nextPredictedDate = findNextPredictedDate();
    if (nextPredictedDate != null) {
      return nextPredictedDate.difference(DateTime.now()).inDays;
    } else {
      return 0; // Or some default value if no future date is found
    }
  }

  DateTime? findEarliestDate(List<MapEntry<DateTime, DateTime>> entries) {
    if (entries.isEmpty) {
      return null;
    }

    DateTime earliestDate = entries.first.key;

    for (var entry in entries) {
      if (entry.key.isBefore(earliestDate)) {
        earliestDate = entry.key;
      }
    }

    return earliestDate;
  }

  DateTime? findLatestDate(List<MapEntry<DateTime, DateTime>> entries) {
    if (entries.isEmpty) {
      return null;
    }

    DateTime latestDate = entries.first.key;

    for (var entry in entries) {
      if (entry.key.isAfter(latestDate)) {
        latestDate = entry.key;
      }
    }

    return latestDate;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _rangeStartDay = null;
      _rangeEndDay = null;
    });
  }

  void _logPeriod() {
    setState(() {
      _rangeStartDay = currStart;
      _rangeEndDay = currEnd;
      _predictPeriod(_rangeStartDay!, _rangeEndDay!);
      numMenses =
          ((numMenses + (currEnd.difference(currStart).inDays)) / 2).ceil();
    });
  }

  void _logStartPeriod() {
    setState(() {
      currStart = _selectedDay;
      currEnd = _selectedDay.add(Duration(days: numMenses - 1));
      _logPeriod();
      _isPeriodBeingLogged = true; // period starting
    });
  }

  void _logEndPeriod() {
    setState(() {
      currEnd = _selectedDay;
      currEnd = currEnd.isAfter(currStart) ? _selectedDay : currStart;
      _logPeriod();
      _pastPeriods.add(MapEntry(currStart, currEnd));
      print("THIS IS DATE" + _pastPeriods.last.toString());
      _isPeriodBeingLogged = false; // period ending
    });
  }

  void _predictPeriod(DateTime _start, DateTime _end) {
    setState(() {
      _periodPredictions.clear();
      _fertilePredictions.clear();

      for (int i = 0; i < 12; i++) {
        _periodPredictions.add(MapEntry(_start, _end));
        DateTime fertileStart = _end.add(Duration(days: 2));
        DateTime fertileEnd = fertileStart.add(Duration(days: 5));
        _fertilePredictions.add(MapEntry(fertileStart, fertileEnd));
        _start = _end.add(Duration(days: cycleLength - numMenses));
        _end = _start.add(Duration(days: numMenses - 1));
      }

      sendDataToServer();
    });
  }

  void _showSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height: 1000,
              child: Column(
                children: [
                  const SizedBox(height: TSizes.defaultSpace),
                  BoxContainer(
                    height: 150,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomCalendar(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        calendarFormat: CalendarFormat.week,
                        rangeStartDay: _rangeStartDay,
                        rangeEndDay: _rangeEndDay,
                        periodPredictions: _periodPredictions,
                        fertilePredictions: _fertilePredictions,
                        pastPeriods: _pastPeriods,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _onDaySelected(selectedDay, focusedDay);
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: TSizes.defaultSpace),
                  Visibility(
                    visible: !_isPeriodBeingLogged &&
                        _selectedDay.isBefore(DateTime.now()),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: TSizes.defaultSpace,
                          left: TSizes.defaultSpace),
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _logStartPeriod();
                            Navigator.pop(context);
                          },
                          child: const Text(Texts.logPeriod),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: TSizes.defaultSpace,
                  ),
                  Visibility(
                    visible: _isPeriodBeingLogged,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: TSizes.defaultSpace,
                          left: TSizes.defaultSpace),
                      child: Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.lilac,
                            side: const BorderSide(color: Colors.white),
                          ),
                          onPressed: () {
                            _logEndPeriod();
                            Navigator.pop(context);
                          },
                          child: const Text(Texts.endPeriod),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Period Tracker',
              style: Theme.of(context).textTheme.headlineSmall),
          actions: [
            IconButton(
              onPressed: fetchDataFromServer,
              icon: Icon(Iconsax.refresh_left_square),
            )
          ]),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      Container(
                        height: 120,
                        child: Stack(
                          children: [
                            // Image widget
                            Positioned.fill(
                              child: Image.asset(
                                TImages.daysGraphic,
                                fit: BoxFit
                                    .contain, // Adjusts how the image fits within the container
                              ),
                            ),
                            // Text widget
                            Center(
                              child: Text(
                                '${daysTillNextPeriod}',
                                style: TextStyle(
                                  color: Colors.black, // Text color
                                  fontSize: 30, // Font size
                                  fontWeight: FontWeight.bold, // Font weight
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'days till next period',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(
                        height: TSizes.defaultSpace,
                      ),
                      BoxContainer(
                        height: constraints.maxWidth * 0.9,
                        width: constraints.maxWidth * 0.9,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomCalendar(
                            focusedDay: _focusedDay,
                            selectedDay: _selectedDay,
                            calendarFormat: _calendarFormat,
                            rangeStartDay: _rangeStartDay,
                            rangeEndDay: _rangeEndDay,
                            periodPredictions: _periodPredictions,
                            fertilePredictions: _fertilePredictions,
                            pastPeriods: _pastPeriods,
                            onDaySelected: (selectedDay, focusedDay) {
                              if (selectedDay.isBefore(DateTime.now())) {
                                _onDaySelected(selectedDay, focusedDay);
                                _showSheet();
                              }
                            },
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            color: TColors.rosePink,
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(1),
                                            border: Border.all(
                                              color: TColors.rosePink,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        Text(Texts.period),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            color: TColors.lilac,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Text(Texts.ovulationDay),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: TColors.bubblegumPink,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        Text(Texts.predictedPeriod),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            shape: BoxShape.rectangle,
                                            border: Border.all(
                                              color: TColors.lilac,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        Text(Texts.fertileWindow),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(TSizes.defaultSpace),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BoxContainer(
                              height: constraints.maxWidth * 0.25,
                              width: constraints.maxWidth * 0.25,
                              child: Image(
                                image: AssetImage(TImages.mensesPhase),
                              ),
                            ),
                            const SizedBox(width: TSizes.defaultSpace),
                            BoxContainer(
                              height: constraints.maxWidth * 0.25,
                              width: constraints.maxWidth * 0.25,
                              child: Image(
                                image: AssetImage(TImages.lutealPhase),
                              ),
                            ),
                            const SizedBox(width: TSizes.defaultSpace),
                            BoxContainer(
                              height: constraints.maxWidth * 0.25,
                              width: constraints.maxWidth * 0.25,
                              child: Image(
                                image: AssetImage(TImages.ovulationPhase),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Align(),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'chatpage');
                },
                child: Icon(Iconsax.message, color: Colors.white),
                backgroundColor: TColors.rosePink,
              ),
            ),
          ),
          const SizedBox(height: TSizes.defaultSpace),
        ],
      ),
    );
  }
}


//Latest code