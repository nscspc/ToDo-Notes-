import 'package:flutter/material.dart';

class note {
  int _id =
      0; // _ => it ensures that the variable is private means accessible to class only.
  late String _title;
  late String _description;
  late String _date;
  late int _priority;

  note(this._title, this._date, this._priority, [this._description = ""]);
  note.withId(this._id, this._title, this._date, this._priority,
      [this._description =
          ""]); // we are calling this method with a named parameter that is id, because in the above case the database will generate the id but when we want to edit or update it then we will call the constructor with the id and also when we use ListView.builder().
  /*
  => Positional parameters
    -> Wrapping a set of function parameters in [] marks them
       as optional positional parameters.
    -> so that we can call this function by two way :- 

        - Without optional positional parameter
                  say('Bob', 'Howdy')
        - With optional positional parameter
                  say('Bob', 'Howdy', 'smoke signal')
  */

// All the getters :-
  int get id => _id;
  String get title => _title;
  String get description => _description;
  String get date => _date;
  int get priority => _priority;

// All the setters :-
  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  set description(String newDescription) {
    if (newDescription.length <= 255) {
      this._description = newDescription;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 2) {
      this._priority = newPriority;
    }
  }

  // We are going to map all the things so that we do not have to save or retrive the things separately , so that we can do it by one time only.
  // Used to save and retrieve from database .
  // convert note object to map object :-
  Map<String, dynamic> toMap() {
    //here dynamic means that it can hold value of any datatype.
    var map = Map<String, dynamic>();
    if (id != 0) {
      // here we have checked because we have to do 2 things , 1 is creating the note(at this time it will be 0 or null) and , 2nd is editting the note(at this time it will not be 0 or null).
      map['id'] = _id;
    }
    map['title'] = _title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['date'] = _date;

    return map;
  }

  // now we are converting the map object again to note object so that we can retrive them separately instead of a single map.
  note.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._title = map['title'];
    this._description = map['description'];
    this._priority = map['priority'];
    this._date = map['date'];
  }
}
