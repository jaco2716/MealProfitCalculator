import 'dart:convert';

import 'MenuItem.dart';
import 'User.dart';

class Order {
  List<MenuItem> menuOrder;
  String orderDate;
  bool orderDone;
  bool orderAccepted;
  String acceptTime;
  User user;
  String restaurantMessage;
  String orderMessage;

  Order(
      {this.menuOrder,
      this.orderDate,
      this.orderDone,
      this.orderAccepted,
      this.user,
      this.restaurantMessage,
      this.acceptTime,
      this.orderMessage});

  String get dateString {
    List<String> dateTimeList =
        DateTime.fromMillisecondsSinceEpoch(int.parse(orderDate))
            .toString()
            .split(' ');
    List<String> dateList = dateTimeList[0].split('-');
    List<String> timeList = dateTimeList[1].split(':');
    String date = '${dateList[2]}/${dateList[1]}/${dateList[0]}';
    String time = '${timeList[0]}:${timeList[1]}';

    return '$time  $date';
  }

  int get totalPriceFromOrder {
    int total = 0;
    menuOrder.forEach((element) {
      int meatChoiceTotal = 0;
      if (element.meatChoice != null) {
        element.meatChoice.forEach((meat) {
          meatChoiceTotal += meat.price * meat.amount;
        });
      }
      total += element.price * element.amount + meatChoiceTotal;
    });
    return total;
  }

  Order.fromJson(Map<String, dynamic> json)
      : menuOrder = (json['menuOrder'] as List)
            ?.map((e) => MenuItem.fromJson(e))
            ?.toList(),
        orderDate = json['orderDate'],
        orderDone = json['orderDone'],
        orderAccepted = json['orderAccepted'],
        acceptTime = json['acceptTime'],
        restaurantMessage = json['restaurantMessage'],
        orderMessage = json['orderMessage'],
        user = User.fromJson(
          json['user'],
        );

  Map<String, dynamic> toJson() => {
        'menuOrder': jsonEncode(menuOrder),
        'orderDate': orderDate,
        'orderDone': orderDone,
        'orderAccepted': orderAccepted,
        'acceptTime': acceptTime,
        'restaurantMessage': restaurantMessage,
        'orderMessage': orderMessage,
        'user': user.toJson(),
      };
}
