import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal_profit_calculator/Model/FirestoreRef.dart';
import 'package:meal_profit_calculator/SingleMeal.dart';

import 'Model/Ingredient.dart';
import 'Model/Meal.dart';

class MealList extends StatefulWidget {
  MealList({Key key}) : super(key: key);

  @override
  _MealListState createState() => _MealListState();
}

class _MealListState extends State<MealList> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Column(children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirestoreRef.mealRef.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> mealSnapshot) {
                  if (mealSnapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (mealSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: Text("Loading"));
                  }
                  if (mealSnapshot.data.docs.length == 0) {
                    return Center(
                        child: Text(
                      "You have no meals.\nCreate some in the menu.",
                      textAlign: TextAlign.center,
                    ));
                  }

                  List<Meal> meals = List<Meal>();
                  meals = mealSnapshot.data.docs
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

                        List<Ingredient> allIngredients = ingredientSnapshot
                            .data.docs
                            ?.map((e) => Ingredient.fromJson(e.data()))
                            ?.toList();

                        meals.forEach((meal) {
                          meal.ingredients.forEach((ingredient) {
                            allIngredients.forEach((aIngredient) {
                              if (ingredient.id == aIngredient.id) {
                                ingredient.name = aIngredient.name;
                                ingredient.color = aIngredient.color;
                                ingredient.kgPrice = aIngredient.kgPrice;
                                ingredient.measureUnit = aIngredient.measureUnit;
                              }
                            });
                          });
                        });

                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              child: ListTile(
                                visualDensity: VisualDensity.compact,
                                title: Text('Name'),
                                trailing: Text('Cost/Profit'),
                                dense: true,
                              ),
                            ),
                            // Divider(
                            //   thickness: 2,
                            // ),
                            ListView.builder(
                              itemCount: meals.length,
                              itemBuilder: (BuildContext context, int index) {
                                return mealListTile(meals[index]);
                              },
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                            ),
                            // SizedBox(height: 20,),
                            SizedBox(
                              height: 90,
                              width: double.infinity,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: FlatButton(
                                    shape: ContinuousRectangleBorder(),
                                    color: Colors.blue,
                                    child: Text('Set All Profit Margins'),
                                    onPressed: () {
                                      _showChangeProfitMargin(context, meals);
                                    }),
                              ),
                            ),
                          ],
                        );
                      });
                },
              ),
            ]),
          );
  }

  Widget mealListTile(Meal meal) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      // color: Colors.red[100],
      child: ListTile(
        // leading: CircleAvatar(
        //   child: Text(meal.id.toString(), style: TextStyle(color: Colors.white),),
        //   radius: 15,
        //   backgroundColor: Colors.blue[200],
        // ),
        title: Text(meal.name),
        subtitle: Text('${meal.ingredients.length} Ingredients'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${meal.salePrice.toStringAsFixed(2)},-',
              style: TextStyle(color: Colors.blue),
            ),
            Text(' / '),
            Text(
              '${meal.profit.toStringAsFixed(2)},-',
              style: TextStyle(
                  color: meal.profit > 0 ? Colors.green : Colors.orange[700]),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SingleMeal(meal.name, meal),
          ));
          print(meal.name + ' Tapped!');
        },
      ),
    );
  }

  _showChangeProfitMargin(BuildContext context, List<Meal> meals) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController tec = TextEditingController();
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Calculate the Sale Price from a Profit Margin'),
              Container(
                  padding: EdgeInsets.all(5),
                  width: 100,
                  child: TextField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    keyboardType: TextInputType.phone,
                    maxLength: 2,
                    maxLengthEnforced: true,
                    controller: tec,
                    decoration: InputDecoration(
                        hintText: '%',
                        border: OutlineInputBorder(),
                        counterText: ''),
                  )),
            ],
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel')),
            RaisedButton(
              onPressed: () async {
                Navigator.pop(context);

                setState(() {
                  isLoading = true;
                });
                await _changeAllProfitMargin(tec.text, meals);
                setState(() {
                  isLoading = false;
                });
              },
              child: Text('Accept'),
            )
          ],
        );
      },
    );
  }

  Future<bool> _changeAllProfitMargin(
      String textFieldText, List<Meal> meals) async {
    String textfield = textFieldText;
    double profitMargin;
    bool dbSucess = false;
    if (textfield != null) profitMargin = double.tryParse(textfield);
    if (profitMargin != null) {
      for (var meal in meals) {
        double newSalePrice =
            ((meal.totalCost / (1 - profitMargin / 100)) * 100)
                    .roundToDouble() /
                100;
        print(newSalePrice);
        dbSucess =
            await _saveProfitMarginToDB(meal.id.toString(), newSalePrice);
        meal.salePrice = newSalePrice;
        print(dbSucess);
      }

      if (dbSucess) {
        // setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profit Margin has been saved.'),
        ));
        print('success: ' + dbSucess.toString());
        return true;
      } else {
        print('error: ' + dbSucess.toString());
        // setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Something went wrong, please try again.'),
        ));
      }
    }
    return false;
  }

  Future<bool> _saveProfitMarginToDB(String id, double salePrice) {
    return FirestoreRef.mealRef
        .doc(id)
        .update({"salePrice": salePrice}).then((value) {
      print("DB updated");
      return true;
    }).catchError((error) {
      print("Failed to update salePrice in DB: $error");
      return false;
    });
  }
}
