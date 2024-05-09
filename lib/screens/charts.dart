import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:level/theme/app_color.dart'; // Ensure this is the correct path for your theme

class Charts extends StatefulWidget {
  const Charts({super.key});

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  final List<String> _cylindersList = [
    "XY00001",
    "XY00002",
    "XY00003",
    "XY00004",
    "XY00005"
  ];
  final List<String> _assetList = [
    "level",
    "batterylevel",
    "signal",
    "devicetemp",
    "humidity",
    "pressure",
    "altitude",
    "datafrequency"
  ];
  String _selectedCylinder = "XY00001";
  String _selectedAsset = "level";
  List<FlSpot> _chartData = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchData();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Adjust the interval as needed
      fetchData();
    });
  }

  Future<void> fetchData() async {
    String url =
        'http://43.204.133.45:4000/sensor/levelchartdata/$_selectedCylinder/$_selectedAsset';
    print('Fetching data from: $url');
    final response = await http.get(Uri.parse(url));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      List<FlSpot> loadedData = [];
      if (jsonData.isNotEmpty) {
        // Calculate the x interval if needed
        double firstTimestamp = DateTime.parse(jsonData.first['createdAt'])
            .millisecondsSinceEpoch
            .toDouble();
        double lastTimestamp = DateTime.parse(jsonData.last['createdAt'])
            .millisecondsSinceEpoch
            .toDouble();
        double xInterval = (lastTimestamp - firstTimestamp) / jsonData.length;

        loadedData = jsonData.map((dataPoint) {
          double y = double.parse(dataPoint[_selectedAsset].toString());
          DateTime createdAt = DateTime.parse(dataPoint['createdAt']);
          double x =
              (createdAt.millisecondsSinceEpoch.toDouble() - firstTimestamp) /
                  xInterval; // Normalizing x values
          return FlSpot(x, y);
        }).toList();
      }
      setState(() {
        _chartData = loadedData;
      });
    } else {
      print('Failed to fetch data');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text('Chart',
            style: TextStyle(
                fontFamily: 'Epilogue',
                fontWeight: FontWeight.w300,
                fontSize: 30)),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Select Cylinder No",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCylinder,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_circle,
                              color: Colors.deepPurple),
                          dropdownColor: Colors.deepPurple.shade50,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCylinder = newValue;
                                fetchData();
                              });
                            }
                          },
                          items: _cylindersList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[50],
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Select Asset",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAsset,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down_circle,
                              color: Colors.deepPurple),
                          dropdownColor: Colors.deepPurple.shade50,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedAsset = newValue;
                                fetchData();
                              });
                            }
                          },
                          items: _assetList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData mainData() {
    // Sorting the data by x (timestamp) to ensure correct plotting
    _chartData.sort((a, b) => a.x.compareTo(b.x));

    // Smooth the data using a moving average
    List<FlSpot> smoothedData = [];
    for (int i = 0; i < _chartData.length; i++) {
      double sum = _chartData[i].y;
      int count = 1;
      for (int j = 1; j <= 5; j++) {
        // Adjust the window size as needed
        if (i - j >= 0) {
          sum += _chartData[i - j].y;
          count++;
        }
        if (i + j < _chartData.length) {
          sum += _chartData[i + j].y;
          count++;
        }
      }
      double average = sum / count;
      smoothedData.add(FlSpot(_chartData[i].x, average));
    }

    // Dynamic range calculations with padding
    final double minX = smoothedData.isNotEmpty ? smoothedData.first.x : 0;
    final double maxX = smoothedData.isNotEmpty ? smoothedData.last.x : 0;
    final double rangePadding =
        (maxX - minX) * 0.05; // Adding 5% padding on both sides

    return LineChartData(
      minX: minX - rangePadding,
      maxX: maxX + rangePadding,
      minY: 0,
      maxY: smoothedData.isEmpty
          ? 30
          : smoothedData.map((spot) => spot.y).reduce(max) + 1,
      // Adding some padding to maxY
      lineBarsData: [
        LineChartBarData(
          spots: smoothedData,
          isCurved: false,
          gradient: const LinearGradient(
            colors: [AppColors.contentColorCyan, AppColors.contentColorBlue],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.contentColorCyan.withOpacity(0.3),
                AppColors.contentColorBlue.withOpacity(0.3)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              var date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              Widget dateText = Text(
                DateFormat('MM/dd').format(date),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              );

              // Rotate the text by 45 degrees
              return Transform.rotate(
                angle: 45 * pi / 140, // Converts degrees to radians
                child: dateText,
              );
            },
            reservedSize:
                60, // You might need to increase the reserved size for rotated labels
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.blue, // Customize your text color
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Customize your font size
                ),
              );
            },
            reservedSize: 40,
          ),
        ),

        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles:
                SideTitles(showTitles: false)), // Hide right titles if needed
      ),
    );
  }
}
