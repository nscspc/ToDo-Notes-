import 'package:flutter/material.dart';
import '../note.dart';
import '../database_helper.dart';
import 'package:intl/intl.dart';

class notedetails extends StatefulWidget {
  final String appBarTitle;
  final note Note;

  notedetails(this.Note, this.appBarTitle);

  @override
  State<notedetails> createState() =>
      _notedetailsState(this.Note, this.appBarTitle);
}

class _notedetailsState extends State<notedetails> {
  static var _priorities = ['High', 'Low'];
  DatabasesHelper helper = DatabasesHelper();
  String appBarTitle;
  note Note;
  _notedetailsState(this.Note, this.appBarTitle);

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // TextEditingController :-
  /*
  => A controller for an editable text field.
  => Whenever the user modifies a text field with an
     associated [TextEditingController], the text field
     updates [value] and the controller notifies its 
     listeners. Listeners can then read the [text] and 
     [selection] properties to learn what the user has 
     typed or how the selection has been updated.
  => Similarly, if you modify the [text] or [selection] 
     properties, the text field will be notified and 
     will update itself appropriately.
  => A [TextEditingController] can also be used to provide
     an initial value for a text field. If you build a text
     field with a controller that already has [text], the 
     text field will use that text as its initial value.
  */

  @override
  Widget build(BuildContext context) {
    TextStyle? textStyle = Theme.of(context).textTheme.headline1;
    titleController.text = Note.title;
    descriptionController.text = Note.description;

    return WillPopScope(
      onWillPop: () => moveToLastScreen(),
      child: Scaffold(
        backgroundColor: Colors.cyanAccent,
        appBar: AppBar(
          title: Text(appBarTitle),
          backgroundColor: Colors.pink,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(10.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 5.0),
                  //dropdown menu
                  // ignore: unnecessary_new
                  child: new ListTile(
                    leading: const Icon(Icons.low_priority),
                    title: DropdownButton(
                        items: _priorities.map((String dropDownStringItem) {
                          return DropdownMenuItem<String>(
                            value: dropDownStringItem,
                            child: Text(dropDownStringItem,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          );
                        }).toList(),
                        value: getPriorityAsString(Note.priority),
                        onChanged: (valueSelectedByUser) {
                          setState(() {
                            updatePriorityAsInt(valueSelectedByUser.toString());
                          });
                        }),
                  ),
                ),
                // Second Element
                Padding(
                  padding: EdgeInsets.only(
                      top: 15.0, bottom: 15.0, left: 15.0, right: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: TextStyle(fontSize: 20.0),
                    onChanged: (value) {
                      updateTitle();
                    },
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(fontSize: 20.0),
                      icon: Icon(Icons.title),
                    ),
                  ),
                ),

                // Third Element
                Padding(
                  padding: EdgeInsets.only(
                      top: 15.0, bottom: 15.0, left: 15.0, right: 15.0),
                  child: TextField(
                    controller: descriptionController,
                    style: TextStyle(fontSize: 20.0),
                    onChanged: (value) {
                      updateDescription();
                    },
                    decoration: InputDecoration(
                      labelText: 'Details',
                      labelStyle: TextStyle(fontSize: 20.0),
                      icon: Icon(Icons.details),
                    ),
                  ),
                ),

                // Fourth Element
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.green,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Save',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Save button clicked");
                              _save();
                            });
                          },
                        ),
                      ),
                      Container(
                        width: 5.0,
                      ),
                      Expanded(
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: Colors.red,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              _delete();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateTitle() {
    Note.title = titleController.text;
  }

  void updateDescription() {
    Note.description = descriptionController.text;
  }

  void _save() async {
    moveToLastScreen();
    Note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (Note.id != 0) {
      result = await helper.updateNote(Note);
    } else {
      result = await helper.insertNote(Note);
    }

    if (result != 0) {
      _showAlertDialog("Status", "Note Saved Successfully");
    } else {
      _showAlertDialog("Status", "Problem in Saving the Note");
    }
  }

  void _delete() async {
    moveToLastScreen();
    if (Note.id == 0) {
      _showAlertDialog('Status', 'First add a note');
      return;
    }

    int result = await helper.deleteNote(Note.id);

    if (result != 0) {
      _showAlertDialog("Status", "Note Deleted Successfully");
    } else {
      _showAlertDialog("Status", "Error");
    }
  }

  // when user sets the priority then it is shown as high and low but saved as 1 and 0.
  //convert to int to save into database :-
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        Note.priority = 1;
        break;
      case 'Low':
        Note.priority = 2;
        break;
    }
  }

  // when user comes to edit the note then from database the priority value 0 and 1 is converted to low and high and then showed to the user.
  //convert int to String to show user :-
  String getPriorityAsString(int value) {
    String priority = "";
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  Future<bool> moveToLastScreen() async {
    Navigator.pop(context, true);
    return false; //
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) =>
            alertDialog); // in this we have passed '_' in builder because it is private one , so whichever is going to call it then it will build the alertdialog based on that context.
  }
}

//255