import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _cylindersList = [
    "XY00001",
    "XY00002",
    "XY00003",
    "XY00004",
    "XY00005"
  ];
  Timer? _timer;
  String? _selectedVal;
  dynamic
      _currentLevel; // Corrected: Removed duplicate and kept only one declaration
  List<Map<String, dynamic>> _gridlist = [];

  @override
  void initState() {
    super.initState();
    _selectedVal = _cylindersList.first; // Set default value
    // Fetch data for the default cylinder
    // _timer = Timer.periodic(Duration(seconds: 1), (timer) => fetchData());

    fetchData();
  }

  Future<void> fetchData() async {
    if (_selectedVal == null) return;

    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      try {
        final response = await http
            .get(Uri.parse('http://192.168.1.13:8000/asset/$_selectedVal'));
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          // Check if data has changed before updating the state
          if (_currentLevel != data['Level'] ||
              _gridlist[0]['value'] != data['Battery']) {
            setState(() {
              _currentLevel = data['Level'];
              _gridlist = [
                {"title": "Battery", "value": data['Battery']},
                {"title": "Signal", "value": data['Signal']},
                {"title": "Temp", "value": data['Temp']},
                {"title": "Humidity", "value": data['Humidity']},
                {"title": "Pressure", "value": data['Pressure']},
                {"title": "Altitude", "value": data['Altitude']},
                {"title": "Data frequency", "value": data['Data frequency']},
              ];
            });
          }
        } else {
          throw Exception('Failed to load data');
        }
      } catch (e) {
        print('Caught error: $e');
        setState(() {
          _gridlist = []; // Clear data or handle error appropriately
        });
      }
    });
  }

  @override
  void dispose() {
    _timer
        ?.cancel(); // Make sure to cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Home',
            style: TextStyle(
                fontFamily: 'Epilogue',
                fontWeight: FontWeight.w300,
                fontSize: 30)),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 280, // Explicit height for the header
              child: _head(), // This is the fixed header part
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text("Data",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(8.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final gridItem = _gridlist[index];
                          String parseValue(String value) {
                            // Remove non-numeric characters and trim any whitespace
                            String numericValue =
                                value.replaceAll(RegExp(r'[^0-9]'), '').trim();
                            return numericValue;
                          }

                          return GridItem(
                            title: gridItem['title'] as String,
                            value: int.parse(
                                parseValue(gridItem['value'].toString())),
                          );
                        },
                        childCount: _gridlist.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _head() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.teal.shade400,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.50),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            width: 300,
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
                    fetchData();
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
        Positioned(
          top: 110,
          left: MediaQuery.of(context).size.width * 0.5 - 160,
          child: Container(
            height: 140,
            width: 320,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 8),
                  child: Text('Level',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white)),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${_currentLevel ?? 'Loading...'} ML",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white)),
                      SizedBox(width: 10),
                      Icon(Icons.sensors, color: Colors.white, size: 40),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 20, right: 20, bottom: 8, top: 15),
                  child: Text("Last Updated: 4/18/2024 1:12 PM",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class GridItem extends StatelessWidget {
  final String title;
  final int value;

  const GridItem({
    required this.title,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final cellWidth = constraints.maxWidth;
                  final cellHeight = constraints.maxHeight;
                  final gaugeSize = math.min(cellWidth, cellHeight) *
                      0.8; // Adjust the scaling factor as needed
                  return SizedBox(
                    width: gaugeSize,
                    height: gaugeSize,
                    child: _buildRadialGauge(value),
                  );
                },
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadialGauge(int value) {
    return RadialNonLinearLabel(value);
  }
}

class RadialNonLinearLabel extends StatelessWidget {
  final int value;

  const RadialNonLinearLabel(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      enableLoadingAnimation: true,
      key: UniqueKey(),
      animationDuration: 2500,
      axes: <RadialAxis>[
        RadialAxis(
          axisLineStyle: const AxisLineStyle(
            thicknessUnit: GaugeSizeUnit.factor,
            thickness: 0.15,
          ),
          radiusFactor: 0.9,
          showTicks: true,
          showLastLabel: true,
          maximum: 150,
          axisLabelStyle: const GaugeTextStyle(),
          pointers: <GaugePointer>[
            NeedlePointer(
              enableAnimation: true,
              gradient: const LinearGradient(
                colors: <Color>[
                  Color.fromRGBO(203, 126, 223, 0),
                  Color(0xFFCB7EDF)
                ],
                stops: <double>[0.25, 0.75],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              animationType: AnimationType.easeOutBack,
              value: value.toDouble(),
              animationDuration: 1300,
              needleStartWidth: 4,
              needleEndWidth: 8,
              needleLength: 0.8,
              knobStyle: const KnobStyle(
                knobRadius: 0,
              ),
            ),
            RangePointer(
              value: value.toDouble(),
              width: 0.15,
              sizeUnit: GaugeSizeUnit.factor,
              color: const Color(0xFF494CA2),
              animationDuration: 1300,
              animationType: AnimationType.easeOutBack,
              gradient: const SweepGradient(
                colors: <Color>[Color(0xFF9E40DC), Color(0xFFE63B86)],
                stops: <double>[0.25, 0.75],
              ),
              enableAnimation: true,
            )
          ],
        )
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}
