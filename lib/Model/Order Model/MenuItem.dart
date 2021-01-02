
import 'MeatChoice.dart';

class MenuItem {
  int id;
  String title;
  String description;
  int price;
  String image;
  int amount;
  List<MeatChoice> meatChoice;

  MenuItem(this.id, this.title, this.description, this.price, this.image,
      this.amount,
      {this.meatChoice});

  MenuItem.clone(MenuItem menuItemCopy)
      : this(menuItemCopy.id, menuItemCopy.title, menuItemCopy.description,
            menuItemCopy.price, menuItemCopy.image, menuItemCopy.amount,
            meatChoice: menuItemCopy.meatChoice
                ?.map((e) => MeatChoice.clone(e))
                ?.toList());

  MenuItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        description = json['description'],
        price = json['price'],
        image = json['image'],
        amount = json['amount'],
        meatChoice = (json['meatChoice'] as List)
            ?.map((e) => MeatChoice.fromJson(e))
            ?.toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'image': image,
        'amount': amount,
        'meatChoice': meatChoice != null
            ? meatChoice.map((e) => e.toJson()).toList()
            : null,
        //'meatChoice': jsonEncode(meatChoice),
      };

  @override
  String toString() {
    return "$id, $title, $price dk,- Antal: $amount. extra";
  }
}
