import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_profit_calculator/CreateMeal.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'Model/FirestoreRef.dart';
import 'Model/Meal.dart';
import 'main.dart';

class SingleMeal extends StatelessWidget {
  String title;
  Meal meal;
  SingleMeal(this.title, this.meal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                title = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        CreateMeal(editMode: true, editMeal: meal)));
              })
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Card(
            color: Colors.red[50],
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
            child: Container(
                width: double.infinity,
                child: ListTile(
                  title: Text(
                    'Total Cost:',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  trailing: Text(
                    '${meal.totalCost.toStringAsFixed(2)},- kr',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                )),
          ),
          Card(
            color: Colors.blue[50],
            elevation: 5,
            margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
            child: Container(
                width: double.infinity,
                child: ListTile(
                  title: Text(
                    'Sale Price:',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                  trailing: Text(
                    '${meal.salePrice.toStringAsFixed(2)},- kr',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                )),
          ),
          Card(
            elevation: 5,
            color: meal.profitMargin > 0 ? Colors.green[50] : Colors.orange[50],
            margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
            child: Container(
                width: double.infinity,
                child: ListTile(
                  title: Text(
                    'Profit:',
                    style: TextStyle(
                        color: meal.profitMargin > 0
                            ? Colors.green[700]
                            : Colors.orange[700]),
                  ),
                  trailing: Text(
                    '${meal.profit.toStringAsFixed(2)},- kr',
                    style: TextStyle(
                        color: meal.profitMargin > 0
                            ? Colors.green[700]
                            : Colors.orange[700]),
                  ),
                )),
          ),
          meal.profitMargin < 0
              ? _profitMarginWidget(-meal.profitMargin, Colors.orange[700], '-')
              : _profitMarginWidget(meal.profitMargin, Colors.green[700], ''),
          // RaisedButton(
          //     child: Text('Choose Profit Margin'),
          //     onPressed: () {
          //       _showChangeProfitMargin(context);
          //     }),
          Card(
            margin: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Ingredients',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 30,
                        color: Colors.pink[100],
                      )),
                ),
                Divider(
                  thickness: 1,
                ),
                ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      thickness: 2,
                    );
                  },
                  itemCount: meal.ingredients.length,
                  itemBuilder: (BuildContext context, int index) {
                    String _lowMeasureUnit =
                        meal.ingredients[index].measureUnit == 'Kg'
                            ? 'g'
                            : 'ml';
                    // print(Color(meal.ingredients[index].color));
                    return ListTile(
                      title: Row(children: [
                        CircleAvatar(
                          backgroundColor: Color(meal.ingredients[index].color),
                          radius: 10,
                        ),
                        Text('   ' + meal.ingredients[index].name),
                      ]),
                      subtitle: Text(
                          '         ${meal.ingredients[index].amountInGrams.round()} ' +
                              _lowMeasureUnit),
                      trailing: Text(
                          '${(meal.ingredients[index].kgPrice * meal.ingredients[index].amountInGrams / 1000).toStringAsFixed(2)} kr,-'),
                    );
                  },
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            width: 200,
            child: IconButton(
                iconSize: 40,
                color: Colors.red,
                icon: Icon(Icons.delete),
                padding: EdgeInsets.all(15),
                onPressed: () => _deleteMealDialog(context)),
          ),
        ],
      )),
    );
  }

//Show menu to calculate price from profit margin
//   _showChangeProfitMargin(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         TextEditingController tec = TextEditingController();
//         return AlertDialog(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Calculate the Sale Price from a Profit Margin'),
//               Container(
//                   padding: EdgeInsets.all(5),
//                   width: 100,
//                   child: TextField(
//                     inputFormatters: <TextInputFormatter>[
//                       FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
//                     ],
//                     keyboardType: TextInputType.phone,
//                     maxLength: 2,
//                     maxLengthEnforced: true,
//                     controller: tec,
//                     decoration: InputDecoration(
//                         hintText: '%',
//                         border: OutlineInputBorder(),
//                         counterText: ''),
//                   )),
//             ],
//           ),
//           actions: [
//             FlatButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('Cancel')),
//             RaisedButton(
//               onPressed: () async {
// //Calculate price from profit margin and save it to firestore.
//                 String textfield = tec.text;
//                 double profitMargin;
//                 if (textfield != null)
//                   profitMargin = double.tryParse(textfield);
//                 if (profitMargin != null) {
//                   double newSalePrice =
//                       ((meal.totalCost / (1 - profitMargin / 100)) * 100)
//                               .roundToDouble() /
//                           100;
//                   print(newSalePrice);
//                   bool dbSucess = false;
//                   dbSucess = await _saveProfitMarginToDB(
//                       meal.id.toString(), newSalePrice);

//                   if (dbSucess) {
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       content: Text('Profit Margin has been saved.'),
//                     ));
//                     meal.salePrice = newSalePrice;
//                     Navigator.pop(context);
//                     Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SingleMeal(meal.name, meal),
//                         ));
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                       content: Text('Something went wrong, please try again.'),
//                     ));
//                   }
//                 }
//               },
//               child: Text('Accept'),
//             )
//           ],
//         );
//       },
//     );
//   }

//Show menu to delete meal.
  _deleteMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete'),
          content: Text('Are you sure you want to delete ${meal.name}?'),
          actions: [
            FlatButton(
              child: Text('cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            RaisedButton(
              child: Text('Delete'),
              color: Colors.red,
              onPressed: () => _deleteMeal(context),
            )
          ],
        );
      },
    );
  }

//delete meal and show error/ succes message
  _deleteMeal(BuildContext context) async {
    bool deleteSuccess = false;

    deleteSuccess = await _deleteMealFromDB(meal);

    if (deleteSuccess) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ),
          (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${meal.name} was deleted.'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong, please try again.'),
      ));
    }
  }

//delete meal from firestore database
  Future<bool> _deleteMealFromDB(Meal newMeal) {
    return FirestoreRef.mealRef
        .doc(newMeal.id.toString())
        .delete()
        .then((value) {
      print("${meal.name} deleted from DB");
      return true;
    }).catchError((error) {
      print("Failed to delete ${meal.name} from DB: $error");
      return false;
    });
  }

//save new price from profit margin to database
  // Future<bool> _saveProfitMarginToDB(String id, double salePrice) {
  //   return FirestoreRef.mealRef
  //       .doc(id)
  //       .update({"salePrice": salePrice}).then((value) {
  //     print("DB updated");
  //     return true;
  //   }).catchError((error) {
  //     print("Failed to update salePrice in DB: $error");
  //     return false;
  //   });
  // }

//Round widget to show profit margin in percent.
  Widget _profitMarginWidget(
      double localProfitMargin, Color indicatorColor, String negative) {
    localProfitMargin /= 100;
    return CircularPercentIndicator(
      radius: 170.0,
      lineWidth: 20.0,
      animation: true,
      percent: localProfitMargin < 1 ? localProfitMargin : 1,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new Text(
            "$negative${(localProfitMargin * 100).round()}%",
            textAlign: TextAlign.center,
            style: new TextStyle(fontWeight: FontWeight.w300, fontSize: 30.0),
          ),
          Text('Profit Margin'),
        ],
      ),
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Colors.blue[100],
      progressColor: indicatorColor,
    );
  }
}
