import 'package:flutter/material.dart';

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  DateTime? fromDate;
  DateTime? toDate;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Text('Report',
                style: TextStyle(
                    fontFamily: 'Epilogue',
                    fontWeight: FontWeight.w300,
                    fontSize: 30 * MediaQuery.of(context).size.width / 800)),
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
                        aspectRatio: isDesktop ? 4 / 3 : 350 / 250,
                        child: Image.asset(
                          'lib/images/report.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: isDesktop ? 20.0 : 10.0),
                        child: Text(
                          'Categories',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 5.0, left: 5.0),
                              child: ElevatedButton(
                                onPressed: () => _selectDate(context, true),
                                child: Text(fromDate == null
                                    ? 'Select From Date'
                                    : 'From: ${fromDate!.toLocal().toString().split(' ')[0]}'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: ElevatedButton(
                                onPressed: () => _selectDate(context, false),
                                child: Text(toDate == null
                                    ? 'Select To Date'
                                    : 'To: ${toDate!.toLocal().toString().split(' ')[0]}'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: isDesktop ? 20.0 : 10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Implement your download logic here
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade300,
                                foregroundColor: Colors.white),
                            child: const Text(
                              'Download Report',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
