import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRef {

  static final CollectionReference ingredientRef = FirebaseFirestore.instance
        .collection('applications')
        .doc('MealProfitCalculator')
        .collection('ingredients');

  static final CollectionReference mealRef = FirebaseFirestore.instance
        .collection('applications')
        .doc('MealProfitCalculator')
        .collection('meals');
        
  static final CollectionReference leosWokOrdersRef = FirebaseFirestore.instance
        .collection('orders');
}