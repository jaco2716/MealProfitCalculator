import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meal_profit_calculator/CreateIngredient.dart';
import 'package:meal_profit_calculator/Model/FirestoreRef.dart';

import 'Model/Ingredient.dart';

class IngredientList extends StatefulWidget {
  IngredientList({Key key}) : super(key: key);

  @override
  _IngredientListState createState() => _IngredientListState();
}

class _IngredientListState extends State<IngredientList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Ingredients')),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 700),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 45.0),
                child: ListTile(
                  visualDensity: VisualDensity.compact,
                  title: Text('Name'),
                  trailing: Text('Kg/Liter Cost'),
                  dense: true,
                ),
              ),
              // Divider(
              //   thickness: 2,
              // ),
              StreamBuilder<QuerySnapshot>(
                stream: FirestoreRef.ingredientRef.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

//Map data from firestore to objects in list.
                  List<Ingredient> ingredients = List<Ingredient>();
                  ingredients = snapshot.data.docs
                      ?.map((e) => Ingredient.fromJson(e.data()))
                      ?.toList();
                  return new ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ingredientListTile(ingredients[index]);
                    },
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                  );
                },
              ),
              SizedBox(
                height: 50,
              )
            ]),
          ),
        ),
      ),
    );
  }

//List tile widget of every ingredient
  Widget ingredientListTile(Ingredient ingredient) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        title: Row(children: [
          CircleAvatar(
            backgroundColor: Color(ingredient.color),
            radius: 10,
          ),
          Text('   ' + ingredient.name),
        ]),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                '${ingredient.kgPrice.toString()} Kr/${ingredient.measureUnit}'),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.edit,
                color: Colors.grey,
              ),
            )
          ],
        ),
        onTap: () {
//when tapped go to edit page.
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                CreateIngredient(editMode: true, editIngredient: ingredient),
          ));
        },
      ),
    );
  }
}
