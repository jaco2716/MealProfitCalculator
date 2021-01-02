import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:meal_profit_calculator/Model/FirestoreRef.dart';

import 'Model/Ingredient.dart';
import 'main.dart';

class CreateIngredient extends StatefulWidget {
  bool editMode;
  Ingredient editIngredient;

  CreateIngredient({this.editMode, this.editIngredient});

  @override
  _CreateIngredientState createState() => _CreateIngredientState();
}

class _CreateIngredientState extends State<CreateIngredient> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _kgPrice = '';
  String _measureUnit = 'Kg';
  Color currentColor = Colors.red;

  List<Ingredient> ingredientsList = List<Ingredient>();

  @override
  void initState() {
    super.initState();

    initEditMode();
  }

  initEditMode() {
    if (widget.editMode ?? false) {
      currentColor = Color(widget.editIngredient.color);
      _name = widget.editIngredient.name;
      _kgPrice = widget.editIngredient.kgPrice.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Ingredient'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                  initialValue: _name,
                  keyboardType: TextInputType.name,
                  validator: (value) => validateString(value),
                  onSaved: (value) => _name = value,
                  onFieldSubmitted: (value) => changeFocus(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 180,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Price per Kg/Liter',
                        ),
                        initialValue: _kgPrice,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                        ],
                        keyboardType: TextInputType.phone,
                        validator: (value) => validateDouble(value),
                        onSaved: (value) => _kgPrice = value,
                        onFieldSubmitted: (value) => changeFocus(),
                      ),
                    ),
                    Container(
                        width: 70,
                        // height: 70,
                        padding: EdgeInsets.only(top: 20),
                        child: DropdownButton(
                            value: _measureUnit,
                            // style: TextStyle(color: Colors.white),
                            // iconEnabledColor: Colors.white,
                            // dropdownColor: Colors.blue,
                            items: <String>[
                              "Kg",
                              "Liter",
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _measureUnit = newValue;
                              });
                            }))
                  ],
                ),
                Text(
                  '\nPick a color identifier',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic),
                ),
                Container(
                  padding: EdgeInsets.only(top: 0, right: 50, left: 50),
                  height: 290,
                  child: BlockPicker(
                    pickerColor: currentColor,
                    onColorChanged: changeColor,
                  ),
                ),
                Container(
                    width: 200,
                    child: RaisedButton.icon(
                        icon: Icon(Icons.save),
                        padding: EdgeInsets.all(15),
                        label: Text('Save Ingredient'),
                        onPressed: () => _saveIngredient())),
                SizedBox(
                  height: 20,
                ),
                widget.editMode ?? false
                    ? IconButton(
                        padding: EdgeInsets.all(20),
                        iconSize: 40,
                        color: Colors.red,
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteIngredientDialog(context),
                      )
                    : Center(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _saveIngredient() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      double finalKgPrice = double.parse(_kgPrice);
      int newID;
      if (widget.editMode ?? false)
        newID = widget.editIngredient.id;
      else
        newID = DateTime.now().millisecondsSinceEpoch;

      Ingredient newIngredient = Ingredient(
          newID, _name, finalKgPrice, currentColor.value, _measureUnit);

      bool dbSucess = false;

      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('connected');
          dbSucess = await _saveIngredientToDB(newIngredient);
        }
      } on SocketException catch (_) {
        print('not connected');
        dbSucess = false;
      }

      if (dbSucess) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_name + ' has been saved.'),
        ));
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Something went wrong, try again.'),
        ));
      }
    }
  }

  Future<bool> _saveIngredientToDB(Ingredient newIngredient) async {
    return FirestoreRef.ingredientRef
        .doc(newIngredient.id.toString())
        .set(newIngredient.toJson())
        .then((value) {
      print("newIngredient Added");
      return true;
    }).catchError((error) {
      print("Failed to add newIngredient: $error");
      return false;
    });
  }

  _deleteIngredientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete'),
          content: Text(
              'Are you sure you want to delete ${widget.editIngredient.name}?'),
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
              onPressed: () => _deleteIngredient(context),
            )
          ],
        );
      },
    );
  }

  _deleteIngredient(BuildContext context) async {
    bool deleteSuccess = false;

    deleteSuccess = await _deleteIngredientFromDB(widget.editIngredient);

    if (deleteSuccess) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => MyHomePage(),
          ),
          (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.editIngredient.name} was deleted.'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Something went wrong, please try again.'),
      ));
    }
  }

  Future<bool> _deleteIngredientFromDB(Ingredient editIngredient) {
    return FirestoreRef.ingredientRef
        .doc(editIngredient.id.toString())
        .delete()
        .then((value) {
      print("${editIngredient.name} deleted from DB");
      return true;
    }).catchError((error) {
      print("Failed to delete ${editIngredient.name} from DB: $error");
      return false;
    });
  }

  void changeFocus() {
    FocusScope.of(context).nextFocus();
  }

  String validateString(String value) {
    return value.isEmpty ? 'Required' : null;
  }

  String validateDouble(String value) {
    try {
      double.parse(value);
      return null;
    } catch (error) {
      return "Invalid number. Use '.' as komma.";
    }
  }

  void changeColor(Color color) => setState(() => currentColor = color);
}
