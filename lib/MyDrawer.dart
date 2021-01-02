import 'package:flutter/material.dart';
import 'package:meal_profit_calculator/ChartPage.dart';
import 'package:meal_profit_calculator/CreateIngredient.dart';
import 'package:meal_profit_calculator/CreateMeal.dart';
import 'package:meal_profit_calculator/IngredientList.dart';



class MyDrawer extends StatelessWidget {
  const MyDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      
      child: ListView(
        children: <Widget>[
          // UserAccountsDrawerHeader(
          //   currentAccountPicture: CircleAvatar(child: Icon(Icons.person),),
          //   accountEmail: Text('Guest e-mail'),
          //   accountName: Text('Guest'),
          // ),
          Container(
            padding: const EdgeInsets.only(top:60.0),
            child: Center(child: Icon(Icons.accessibility_new, size: 80, color: Colors.blue,),),
          ),
          Container(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('Welcome', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200,)))),
          drawerListTile(Icon(Icons.list), "All Ingredients", IngredientList(), context),
          // Divider(),
          drawerListTile(Icon(Icons.add), "Create Ingredient", CreateIngredient(), context),
          // Divider(),
          drawerListTile(Icon(Icons.add), "Create Meal", CreateMeal(), context),
          // Divider(),
          drawerListTile(Icon(Icons.show_chart), "Charts", ChartPage(), context),
          // Divider(),
        ],
      ),
    );
  }

  Widget drawerListTile(Icon _tileIcon, String _tileTitle, Widget _navigationPage, BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Theme(
        data: ThemeData.dark(),
              child: Card(
          color: Colors.blue,
                child: ListTile(
              leading: _tileIcon,
              title: Text(_tileTitle),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => _navigationPage));
              }),
        ),
      ),
    );
  }
}