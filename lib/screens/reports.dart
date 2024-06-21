import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  DateTime? fromDate;
  DateTime? toDate;

  final _cylindersList = [
    "XY00001",
    "XY00002",
    "XY00003",
    "XY00004",
    "XY00005"
  ];
  String? _selectedVal;

  @override
  void initState() {
    super.initState();
    _selectedVal = _cylindersList.first;
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (fromDate ?? DateTime.now())
          : (toDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != (isFromDate ? fromDate : toDate)) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
          print("Selected From Date: $fromDate");
        } else {
          toDate = picked;
          print("Selected To Date: $toDate");
        }
      });
    }
  }

  void fetchdatafromapipdf() {}

  void fetchdatafromapiexcel() async {
    var url = Uri.parse(
        'http://43.204.133.45:4000/sensor/levelreportdata?id=$_selectedVal&date1=${fromDate?.toIso8601String()}&date2=${toDate?.toIso8601String()}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body) as List;
      print(url);
      generateExcel(jsondata);
    } else {
      throw Exception('Failed to load data');
    }
  }

  void generateExcel(List<dynamic> jsonData) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    List<String> columnHeaders = [
      "ID",
      "Level",
      "Device Temp",
      "Signal",
      "Battery Level",
      "Humidity",
      "Pressure",
      "Altitude",
      "Data Frequency",
      "Created At",
      "Updated At"
    ];

    // Append column headers directly without casting
    sheetObject.appendRow(columnHeaders.cast<CellValue?>());

    DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss'); // Date format

    for (var data in jsonData) {
      var formattedCreatedAt = data['createdAt'] != null
          ? format.format(DateTime.parse(data['createdAt']))
          : '';
      var formattedUpdatedAt = data['updatedAt'] != null
          ? format.format(DateTime.parse(data['updatedAt']))
          : '';

      List<dynamic> row = [
        data['id'] ?? '',
        data['level'] ?? '',
        data['devicetemp'] ?? '',
        data['signal'] ?? '',
        data['batterylevel'] ?? '',
        data['humidity'] ?? '',
        data['pressure'] ?? '',
        data['altitude'] ?? '',
        data['datafrequency'] ?? '',
        formattedCreatedAt,
        formattedUpdatedAt
      ];

      // Ensure each item is correctly handled as a CellValue
      var excelRow =
          row.map((item) => item is! CellValue ? "$item" : item).toList();
      sheetObject.appendRow(excelRow.cast<CellValue?>());
    }

    var fileBytes = excel.save();
    var directory = await getApplicationDocumentsDirectory();
    File file = File("${directory.path}/SensorData.xlsx");
    await file.writeAsBytes(fileBytes!, flush: true);
    print("Excel file is saved at ${file.path}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: const Row(
            children: [
              Text(
                'Report',
                style: TextStyle(
                  fontFamily: 'Epilogue',
                  fontWeight: FontWeight.w300,
                  fontSize: 30,
                ),
              ),
            ],
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth > 600;
            final double paddingValue = isDesktop ? 40.0 : 20.0;

            return Padding(
              padding: EdgeInsets.all(paddingValue),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: isDesktop
                        ? constraints.maxWidth * 0.5
                        : constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: isDesktop ? 4 / 3 : 370 / 250,
                          child: Image.asset(
                            'lib/images/report.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: isDesktop ? 20.0 : 10.0),
                          child: Text(
                            'Select the date',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        // Dropdown menu example
                        InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Select Cylinder No",
                            // Replace with your desired label
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            filled: true,
                            fillColor: Colors
                                .lightBlue[50], // Your desired background color
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedVal ?? _cylindersList.first,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down_circle,
                                  color: Colors.deepPurple),
                              dropdownColor: Colors.deepPurple.shade50,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedVal = newValue;
                                });
                              },
                              items: _cylindersList
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: ElevatedButton(
                                  onPressed: () => _selectDate(context, true),
                                  child: Text(
                                    fromDate == null
                                        ? 'Select From Date'
                                        : 'From: ${fromDate!.toLocal().toString().split(' ')[0]}',
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: ElevatedButton(
                                  onPressed: () => _selectDate(context, false),
                                  child: Text(
                                    toDate == null
                                        ? 'Select To Date'
                                        : 'To: ${toDate!.toLocal().toString().split(' ')[0]}',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    fetchdatafromapipdf();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.green.shade400,
                                    // text color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // rounded corners
                                    ),
                                    elevation: 5,
                                    // shadow elevation
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15), // vertical padding
                                  ),
                                  child: const Text(
                                    'Download PDF',
                                    style: TextStyle(
                                      fontSize: 16, // slightly smaller text
                                      fontWeight: FontWeight.bold, // bold text
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    fetchdatafromapiexcel();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.green.shade400,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                  ),
                                  child: const Text(
                                    'Download Excel',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
