import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:meal_profit_calculator/Model/FirestoreRef.dart';

import 'Model/Ingredient.dart';
import 'Model/Meal.dart';
import 'Model/Order Model/Order.dart';

class ChartPage extends StatefulWidget {
  ChartPage({Key key}) : super(key: key);

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  // List<Meal> mealList = List<Meal>();
  double maxy = 10;
  double miny = 50;
  List<FlSpot> chartList;
  List<FlSpot> secoundaryChartList = List<FlSpot>();
  List<String> chartListTitles = List<String>();
  List<Meal> mealList;
  List<Order> orderList;
  String dropDownValue = "Profit Margin";
  String chartTitle = 'Profit Margin';
  String chartSubtitle;
  Stream<QuerySnapshot> firestoreData;

  @override
  void initState() {
    super.initState();
    _getInitialData();
  }

  _getInitialData() async {
    firestoreData = FirestoreRef.mealRef.get().asStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Charts')),
      backgroundColor: Colors.blueGrey[900],
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: firestoreData,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return Text('Something went wrong');
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            if (dropDownValue == "Leo's Wok Orders")
              orderList = snapshot.data.docs
                  ?.map((e) => Order.fromJson(e.data()))
                  ?.toList();
            else
              mealList = snapshot.data.docs
                  ?.map((e) => Meal.fromJson(e.data()))
                  ?.toList();

            return StreamBuilder<QuerySnapshot>(
                stream: FirestoreRef.ingredientRef.snapshots(),
                builder: (context, ingredientSnapshot) {
                  if (ingredientSnapshot.hasError)
                    return Center(child: Text('Something went wrong'));
                  if (ingredientSnapshot.connectionState ==
                      ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());

                  List<Ingredient> mealIngredients = ingredientSnapshot
                      .data.docs
                      ?.map((e) => Ingredient.fromJson(e.data()))
                      ?.toList();

                  mealList.forEach((m) {
                    m.ingredients.forEach((i) {
                      mealIngredients.forEach((mi) {
                        if (i.id == mi.id) {
                          i.kgPrice = mi.kgPrice;
                          // print("Name: ${i.name}, Price: ${i.kgPrice}");
                        }
                      });
                    });
                  });

                  // print('lengthththt: ' + orderList.length.toString());
                  if (dropDownValue == "Profit Margin")
                    _changeToProfitMargin();
                  else if (dropDownValue == "Total Cost / Sale Price")
                    _changeToSaleCost();
                  else if (dropDownValue == "Profit")
                    _changeToProfit();
                  else if (dropDownValue == "Leo's Wok Orders")
                    _changeToOrders();

                  return _chartWidget(
                      chartList, chartListTitles, maxy, miny, chartTitle,
                      secoundChartList: secoundaryChartList,
                      subtitle: chartSubtitle);
                });
          },
        ),
      ),
    );
  }

  Widget _chartWidget(List<FlSpot> _chartList, List<String> _chartListTitles,
      double _maxy, double _miny, String _title,
      {List<FlSpot> secoundChartList, String subtitle}) {
    _chartList.forEach((e) {
      if (_maxy < e.y + 1) _maxy = e.y.roundToDouble();
      if (_miny > e.y - 1) _miny = e.y.roundToDouble();
    });

    secoundChartList?.forEach((e) {
      if (_maxy < e.y + 1) _maxy = e.y.roundToDouble();
      if (_miny > e.y - 1) _miny = e.y.roundToDouble();
    });

    double _chartHeight = _maxy - _miny;
    if (_chartHeight > 100) {
      _miny -= 20;
      _maxy += 20;
    } else {
      _miny -= 2;
      _maxy += 2;
    }

    double _nrInterval = 0;

    if (_chartHeight > 1000)
      _nrInterval = 200;
    else if (_chartHeight > 250)
      _nrInterval = 50;
    else if (_chartHeight > 100)
      _nrInterval = 10;
    else if (_chartHeight > 50)
      _nrInterval = 5;
    else if (_chartHeight > 20)
      _nrInterval = 2;
    else if (_chartHeight <= 20) _nrInterval = 1;

    return Center(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.all(10)),
          Text(
            _title,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.cyan[400], fontWeight: FontWeight.w900),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.deepOrange[400], fontWeight: FontWeight.w900),
            ),
          Container(
            height: 520,
            width: double.infinity,
            padding: EdgeInsets.only(top: 10, bottom: 70, right: 30, left: 15),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: _chartList.length.toDouble() - 1,
                minY: _miny,
                maxY: _maxy,
                titlesData: FlTitlesData(
                    show: true,
                    leftTitles: SideTitles(
                      interval: 1,
                      getTextStyles: (_) =>
                          TextStyle(color: Colors.white, fontSize: 12),
                      showTitles: true,
                      getTitles: (value) {
                        if (value % _nrInterval == 0)
                          return value.round().toString();
                        else
                          return '';
                      },
                    ),
                    bottomTitles: SideTitles(
                        margin: 25,
                        rotateAngle: 80,
                        getTextStyles: (_) =>
                            TextStyle(color: Colors.white, fontSize: 12),
                        showTitles: true,
                        getTitles: (value) {
                          String itemName = _chartListTitles[value.toInt()];

                          if (itemName.length > 17) {
                            itemName = itemName.replaceRange(
                                15, itemName.length, "...");
                          }
                          return '$itemName';
                        })),
                gridData: FlGridData(
                  horizontalInterval: 1,
                  show: true,
                  getDrawingHorizontalLine: (value) {
                    FlLine thickLine = FlLine(
                      color: Colors.white38,
                      strokeWidth: 1,
                    );
                    if (value % _nrInterval == 0) {
                      return thickLine;
                    } else {
                      return FlLine(
                        color: Colors.white12,
                        strokeWidth: 0.001,
                      );
                    }
                  },
                  drawVerticalLine: true,
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.white54,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black, width: 1)),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    barWidth: 6,
                    colors: [
                      Colors.cyan[400],
                    ],
                    belowBarData: BarAreaData(show: true, colors: [
                      Colors.cyan[600].withOpacity(0.2),
                      Colors.cyan[200].withOpacity(0.2),
                    ]),
                    spots: _chartList,
                  ),
                  if (secoundChartList != null)
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 6,
                      colors: [
                        Colors.deepOrange[400],
                      ],
                      belowBarData: BarAreaData(show: true, colors: [
                        Colors.red[600].withOpacity(0.2),
                        Colors.red[200].withOpacity(0.2),
                      ]),
                      spots: secoundChartList,
                    ),
                ],
              ),
            ),
          ),
          _customDropDownButton(),
        ],
      ),
    );
  }

  Widget _customDropDownButton() {
    return Card(
      color: Colors.blue,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          width: 200,
          child: DropdownButton(
            value: dropDownValue,
            style: TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
            dropdownColor: Colors.blue,
            items: <String>[
              "Profit Margin",
              "Total Cost / Sale Price",
              "Profit",
              "Leo's Wok Orders"
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String newValue) {
              switch (newValue) {
                case "Profit Margin":
                  firestoreData = FirestoreRef.mealRef.get().asStream();
                  break;
                case "Total Cost / Sale Price":
                  firestoreData = FirestoreRef.mealRef.get().asStream();
                  break;
                case "Profit":
                  firestoreData = FirestoreRef.mealRef.get().asStream();
                  break;
                case "Leo's Wok Orders":
                  firestoreData =
                      FirestoreRef.leosWokOrdersRef.get().asStream();
                  break;

                default:
                  firestoreData = FirestoreRef.mealRef.get().asStream();
              }

              setState(() {
                dropDownValue = newValue;
              });
            },
          )),
    );
  }

  double _roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  _changeToProfitMargin() {
    chartTitle = 'Profit Margin';
    chartSubtitle = null;

    chartList = mealList
        .asMap()
        .entries
        ?.map<FlSpot>((v) =>
            FlSpot(v.key.toDouble(), _roundDouble(v.value.profitMargin, 2)))
        ?.toList();

    secoundaryChartList = null;

    chartListTitles = mealList?.map<String>((v) => v.name)?.toList();
  }

  _changeToSaleCost() {
    chartTitle = 'Sale Price';
    chartSubtitle = 'Total Cost';

    chartList = mealList
        .asMap()
        .entries
        ?.map<FlSpot>(
            (v) => FlSpot(v.key.toDouble(), _roundDouble(v.value.salePrice, 2)))
        ?.toList();
    secoundaryChartList = mealList
        .asMap()
        .entries
        ?.map<FlSpot>(
            (v) => FlSpot(v.key.toDouble(), _roundDouble(v.value.totalCost, 2)))
        ?.toList();

    chartListTitles = mealList?.map<String>((v) => v.name)?.toList();
  }

  _changeToProfit() {
    chartTitle = 'Profit';
    chartSubtitle = null;

    chartList = mealList
        .asMap()
        .entries
        ?.map<FlSpot>(
            (v) => FlSpot(v.key.toDouble(), _roundDouble(v.value.profit, 2)))
        ?.toList();

    secoundaryChartList = null;

    chartListTitles = mealList?.map<String>((v) => v.name)?.toList();
  }

  _changeToOrders() {
    chartTitle = 'Orders';
    chartSubtitle = null;

    chartList = orderList
        .asMap()
        .entries
        ?.map<FlSpot>((v) => FlSpot(v.key.toDouble(),
            _roundDouble(v.value.totalPriceFromOrder.toDouble(), 2)))
        ?.toList();
    secoundaryChartList = null;

    chartListTitles = orderList?.map<String>((v) => v.dateString)?.toList();
  }
}
