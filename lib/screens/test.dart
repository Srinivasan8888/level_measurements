import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Level Data App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StaticDataChart(),
    );
  }
}

class StaticDataChart extends StatefulWidget {
  @override
  _StaticDataChartState createState() => _StaticDataChartState();
}

class _StaticDataChartState extends State<StaticDataChart> {
  List<FlSpot> data = [];
  List<String> timestamps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final response = await http.get(
      Uri.parse(
          'http://43.204.133.45:4000/sensor/levelchartdata/XY00001/level'),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<FlSpot> tempData = [];
      List<String> tempTimestamps = [];
      for (int i = 0; i < jsonData.length; i++) {
        var item = jsonData[i];
        double level = double.parse(item['level']);
        DateTime createdAt = DateTime.parse(item['createdAt']);
        tempData.add(FlSpot(i.toDouble(), level));
        tempTimestamps.add(
            '${createdAt.month}/${createdAt.day}\n${createdAt.hour}:${createdAt.minute}');
      }
      setState(() {
        data = tempData;
        timestamps = tempTimestamps;
        isLoading = false;
      });
    } else {
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Data Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < timestamps.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                timestamps[index],
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.blue,
                      // Color set to blue
                      dotData: FlDotData(show: true),
                      // Show all the points
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          return LineTooltipItem(
                            '${touchedSpot.y}',
                            TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
//
// class Report extends StatefulWidget {
//   const Report({super.key});
//
//   @override
//   State<Report> createState() => ReportPage();
// }
//
// class ReportPage extends State<Report> {
//   DateTime? fromDate;
//   DateTime? toDate;
//   List<TemperatureData> reportData = [];
//
//   @override
//   void initState() {
//     super.initState();
//     initialize();
//     Timer.periodic(const Duration(seconds: 5), (timer) {
//       fetchReport();
//     });
//   }
//
//   Future<void> initialize() async {
//     await fetchReport();
//     setState(() {});
//   }
//
//   Future<void> fetchReport() async {
//     try {
//       final dio = Dio();
//       final response =
//           await dio.get('https://3lions.xyma.live/sensor/getallSensor');
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = response.data;
//         for (var item in jsonData) {
//           double temperature = double.parse(item['temperature']);
//           DateTime time = DateTime.parse(item['updatedAt']);
//           reportData.add(TemperatureData(time, temperature));
//         }
//         // Once data is fetched, trigger rebuild of the widget
//         setState(() {});
//       }
//     } catch (error) {
//       print('Error fetching graph: $error');
//     }
//
//     for (var data in reportData) {
//       print('Temperature ${data.value}, Time: ${data.dateTime}');
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context, bool isFromDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isFromDate
//           ? (fromDate ?? DateTime.now())
//           : (toDate ?? DateTime.now()),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != (isFromDate ? fromDate : toDate)) {
//       setState(() {
//         if (isFromDate) {
//           fromDate = picked;
//           print("Selected From Date: $fromDate");
//         } else {
//           toDate = picked;
//           print("Selected To Date: $toDate");
//         }
//       });
//     }
//   }
//
//   Future<void> _generateExcel() async {
//     print("button Clicked...");
//
//     final xlsio.Workbook workbook = xlsio.Workbook();
//     final xlsio.Worksheet sheet = workbook.worksheets[0];
//
//     // Adding headers
//     sheet.getRangeByName('A1').setText('DateTime');
//     sheet.getRangeByName('B1').setText('Value');
//
//     // Adding data
//     for (int i = 0; i < reportData.length; i++) {
//       sheet
//           .getRangeByName('A${i + 2}')
//           .setText(reportData[i].dateTime.toString());
//       sheet.getRangeByName('B${i + 2}').setNumber(reportData[i].value);
//     }
//
//     // Save file
//     final List<int> bytes = workbook.saveAsStream();
//     workbook.dispose();
//
//     final Uint8List fileBytes = Uint8List.fromList(bytes);
//     await _saveFile(fileBytes);
//   }
//
//   Future<void> _saveFile(Uint8List fileBytes) async {
//     // Request storage permissions
//     if (await Permission.storage.request().isGranted) {
//       Directory? directory;
//
//       if (Platform.isAndroid) {
//         directory = await getExternalStorageDirectory();
//         // Use directory.path for external storage
//         directory = Directory('/storage/emulated/0/Documents');
//       } else if (Platform.isIOS) {
//         directory = await getApplicationDocumentsDirectory();
//       } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
//         directory = await getApplicationSupportDirectory();
//       }
//
//       if (directory != null) {
//         final path = "${directory.path}/Report.xlsx";
//         final file = File(path);
//
//         // Save the file
//         await file.writeAsBytes(fileBytes, flush: true);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Report saved to $path')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to get the storage directory')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Storage permission denied')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('Report $reportData');
//
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: Row(
//           children: [
//             Text(
//               'Report',
//               style: TextStyle(
//                   fontWeight: FontWeight.w300,
//                   fontSize: 30,
//                   color: Theme.of(context).colorScheme.tertiary),
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Center(
//           child: Container(
//             width: MediaQuery.of(context).size.width,
//             height: MediaQuery.of(context).size.height,
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.primary,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Column(
//               children: <Widget>[
//                 AspectRatio(
//                   aspectRatio: 350 / 250,
//                   child: Image.asset(
//                     'lib/images/report.png',
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(top: 10.0),
//                   child: Text(
//                     'Categories',
//                     style: TextStyle(
//                       color: Theme.of(context).colorScheme.tertiary,
//                       fontSize: 20,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.only(right: 5.0, left: 5.0),
//                         child: ElevatedButton(
//                           onPressed: () => _selectDate(context, true),
//                           child: Text(fromDate == null
//                               ? 'Select From Date'
//                               : 'From: ${fromDate!.toLocal().toString().split(' ')[0]}'),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 5.0, right: 5.0),
//                         child: ElevatedButton(
//                           onPressed: () => _selectDate(context, false),
//                           child: Text(toDate == null
//                               ? 'Select To Date'
//                               : 'To: ${toDate!.toLocal().toString().split(' ')[0]}'),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Flexible(
//                   child: Padding(
//                     padding: const EdgeInsets.only(top: 40),
//                     child: ElevatedButton(
//                       onPressed: _generateExcel,
//                       style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green.shade300,
//                           foregroundColor: Colors.white),
//                       child: const Text(
//                         'Download Report',
//                         style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class TemperatureData {
//   final DateTime dateTime;
//   final double value;
//
//   TemperatureData(this.dateTime, this.value);
// }
