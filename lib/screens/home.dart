import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

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
  dynamic _currentLevel = 'Loading...'; // Initialized to 'Loading...'
  List<Map<String, dynamic>> _gridlist = [];
  Map<String, dynamic>? _lastData;

  @override
  void initState() {
    super.initState();
    _selectedVal = _cylindersList.first;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => fetchData());
  }

  Future<void> fetchData() async {
    if (_selectedVal == null) return;
    try {
      final response = await http.get(Uri.parse(
          'http://43.204.133.45:4000/sensor/leveldata/$_selectedVal'));
      if (response.statusCode == 200) {
        var newData = jsonDecode(response.body);
        print(newData);
        bool hasDataChanged(
            Map<String, dynamic>? oldData, Map<String, dynamic> newData) {
          if (oldData == null) return true;
          return oldData['level'] != newData['level'] ||
              oldData['batterylevel'] != newData['batterylevel'] ||
              oldData['signal'] != newData['signal'] ||
              oldData['devicetemp'] != newData['devicetemp'] ||
              oldData['humidity'] != newData['humidity'] ||
              oldData['pressure'] != newData['pressure'] ||
              oldData['altitude'] != newData['altitude'] ||
              oldData['datafrequency'] != newData['datafrequency'];
        }

        if (hasDataChanged(_lastData, newData)) {
          setState(() {
            _currentLevel = newData['level'];
            _gridlist = [
              {
                "title": "Battery",
                "value": newData['batterylevel'],
                "unit": "%"
              },
              {"title": "Signal", "value": newData['signal'], "unit": "%"},
              {"title": "Temp", "value": newData['devicetemp'], "unit": "°C"},
              {"title": "Humidity", "value": newData['humidity'], "unit": "%"},
              {
                "title": "Pressure",
                "value": newData['pressure'],
                "unit": "hPa"
              },
              {"title": "Altitude", "value": newData['altitude'], "unit": "m"},
              {
                "title": "Data Hz",
                "value": newData['datafrequency'],
                "unit": "Hz"
              },
            ];
            _lastData = newData;
          });
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Caught error: $e');
      setState(() {
        _gridlist = [];
      });
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
              height: 280,
              child: _head(context),
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
                          return GridItem(
                            title: gridItem['title'] as String,
                            value: int.parse(gridItem['value'].toString()),
                            unit: gridItem['unit'] as String,
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

  Widget _head(BuildContext context) {
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
                      const SizedBox(width: 10),
                      const Icon(Icons.sensors, color: Colors.white, size: 40),
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
  final String unit;

  const GridItem({
    required this.title,
    required this.value,
    required this.unit,
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
            RichText(
              text: TextSpan(
                text: "$title: $value", // Display the value next to the title
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: " $unit", // Append unit next to the value
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
          maximum: 300,
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
