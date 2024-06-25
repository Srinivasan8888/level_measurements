import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

Future<bool> _request_per(Permission permission) async {
  AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
  if (build.version.sdkInt >= 30) {
    var re = await Permission.manageExternalStorage.request();
    if (re.isGranted) {
      return true;
    } else {
      return false;
    }
  } else {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }
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
        } else {
          toDate = picked;
        }
      });
    }
  }

  //
  // void fetchdatafromapipdf() {}
  //
  // Future<bool> requestPermissions() async {
  //   var status = await Permission.storage.status;
  //   print("Current permission status: $status");
  //
  //   if (!status.isGranted) {
  //     print("Requesting storage permission.");
  //     status = await Permission.storage.request();
  //     print("New permission status: $status");
  //   }
  //   return status.isGranted;
  // }

  void fetchDataFromApiExcel(BuildContext context, String? _selectedVal,
      DateTime? fromDate, DateTime? toDate) async {
    const String apiEndpoint =
        'http://43.204.133.45:4000/sensor/levelreportdata';
    if (_selectedVal == null || fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all filter options')),
      );
      return;
    }

    final Map<String, String> queryParams = {
      'id': _selectedVal,
      'date1': fromDate.toIso8601String(),
      'date2': toDate.toIso8601String(),
    };

    try {
      var uri = Uri.parse(apiEndpoint).replace(queryParameters: queryParams);
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        await exportToExcel(data, context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel file downloaded successfully!')),
        );
      } else {
        throw Exception(
            'Failed to load data with status code ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
      print(e);
    }
  }

  Future<bool> _checkStoragePermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;

      if ((info.version.sdkInt) >= 33) {
        status = await Permission.manageExternalStorage.request();
      } else {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.storage.request();
    }

    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return true;
      default:
        return false;
    }
  }

  void test() async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    final storageStatus = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (storageStatus == PermissionStatus.granted) {
      print("granted");
    }
    if (storageStatus == PermissionStatus.denied) {
      print("denied");
    }
    if (storageStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> exportToExcel(List<dynamic> data, BuildContext context) async {
    Directory? directory;

    // Determine directory based on platform
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      directory = Directory('${directory?.path}/Level_measurement_xyma');
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      directory = await getApplicationSupportDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    // Ensure storage permission is granted
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Create directory if it does not exist
      if (!await directory!.exists()) {
        await directory.create(recursive: true);
      }

      // Create Excel document using syncfusion_flutter_xlsio
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];

      // Define headers
      List<String> headers = [
        'ID',
        'Level',
        'Device Temp',
        'Signal',
        'Battery Level',
        'Humidity',
        'Pressure',
        'Altitude',
        'Data Frequency',
        'Created At'
      ];

      // Add headers to the first row of the Excel sheet
      for (int i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      }

      // Add data to the subsequent rows
      for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
        var datum = data[rowIndex];
        for (int columnIndex = 0; columnIndex < headers.length; columnIndex++) {
          var key = headers[columnIndex].toLowerCase().replaceAll(' ', '');
          var value = datum[key]?.toString() ?? '';
          sheet.getRangeByIndex(rowIndex + 2, columnIndex + 1).setText(value);
        }
      }

      // Save the Excel document
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      // Write bytes to file
      final String filePath = '${directory.path}/Output.xlsx';
      final File file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      print('Excel file saved to $filePath');
    } else {
      print('Storage permission not granted');
    }
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
                            // Expanded(
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(10),
                            //     child: ElevatedButton(
                            //       onPressed: () {
                            //         // fetchdatafromapipdf();
                            //       },
                            //       style: ElevatedButton.styleFrom(
                            //         foregroundColor: Colors.white,
                            //         backgroundColor: Colors.green.shade400,
                            //         // text color
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(
                            //               10), // rounded corners
                            //         ),
                            //         elevation: 5,
                            //         // shadow elevation
                            //         padding: const EdgeInsets.symmetric(
                            //             vertical: 15), // vertical padding
                            //       ),
                            //       child: const Text(
                            //         'Download PDF',
                            //         style: TextStyle(
                            //           fontSize: 16, // slightly smaller text
                            //           fontWeight: FontWeight.bold, // bold text
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ElevatedButton(
                                  onPressed: () {
                                    fetchDataFromApiExcel(context, _selectedVal,
                                        fromDate, toDate);
                                  },

                                  // onPressed: exportToExcel,

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
