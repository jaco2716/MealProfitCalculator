import 'package:meal_profit_calculator/Model/Ingredient.dart';

class Meal {
  int id;
  String name;
  double salePrice;
  List<Ingredient> ingredients;

  //Constructor
  Meal(this.id, this.name, this.salePrice, this.ingredients);

  //Get the total cost of the meal, calculated from all ingredients
  double get totalCost {
    double totalPrice = 0;
    ingredients.forEach((e) {
      totalPrice += (e.amountInGrams / 1000) * e.kgPrice;
    });
    return totalPrice;
  }

  //Get the profit, calculated with salePrice and totalCost
  double get profit {
    return (salePrice - totalCost);
  }

  double get profitMargin {
    if(salePrice != 0){
      return (profit / salePrice * 100);
    }
    else return 0;
  }
  //Json convert function, fromJson and toJson
  Meal.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        salePrice = json['salePrice'],
        ingredients = (json['ingredients'] as List)
            ?.map((e) => Ingredient.fromJson(e))
            ?.toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'salePrice': salePrice,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
      };
}

