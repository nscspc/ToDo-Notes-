import 'package:flutter/material.dart';
import 'dart:async';
import '../database_helper.dart'; //here we go one directory back to import the database_helper.dart file.
import '../note.dart';
import 'notedetails.dart';
import 'package:sqflite/sqflite.dart';

class notelist extends StatefulWidget {
  @override
  State<notelist> createState() => _notelistState();
}

class _notelistState extends State<notelist> {
  DatabasesHelper databasesHelper = DatabasesHelper();
  List<note>? noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = <note>[];
      updateListView();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('todo'),
        backgroundColor: Colors.deepPurple,
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
        onPressed: () {
          navigateToDetail(note('', '', 2), 'Add Note');
        },
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
        itemCount: count,
        itemBuilder: (context, position) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            color: Colors.deepPurple,
            elevation: 4.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage("https://learncodeonline.in/mascot.png"),
              ),
              title: Text(
                this.noteList![position].title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              subtitle: Text(
                this.noteList![position].date,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              trailing: GestureDetector(
                child: Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                ),
                onTap: () {
                  navigateToDetail(this.noteList![position], 'Edit Todo');
                },
              ),
            ),
          );
        });
  }

  void navigateToDetail(note Note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (conntext) {
      return notedetails(Note, title);
    }));

    if (result == true) {
      //update the view :-
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databasesHelper.initializeDatabase();
    dbFuture.then(
      (database) {
        Future<List<note>> noteListFuture = databasesHelper.getNoteList();
        noteListFuture.then((noteList) {
          setState(() {
            this.noteList = noteList;
            this.count = noteList.length;
          });
        });
      },
    );
  }
}
