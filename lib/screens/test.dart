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
