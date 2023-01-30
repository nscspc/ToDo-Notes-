import 'note.dart'; // as we are going to perform database operations on the note.
import 'package:sqflite/sqflite.dart';
import 'dart:async'; // as we are going to do the things in Future means asynchronously.
import 'dart:io'; // as we are writing things into the file.
import 'package:path_provider/path_provider.dart'; // to get the actual path.

class DatabasesHelper {
  // ignore: unused_field
  static DatabasesHelper? _databasesHelper; //Singleton.
  static Database? _database; //Singleton.

  /*
  Singleton is a design pattern used so that we initialize(database
  object in this case ) only once . Even if we request for a databasse reference again
  in runtime for operati tons of crud we return the same object without
  creating a new one.
  */

  /*
  databaseHelper is a more handy to use and comes with
  synchronized methods databaseHelper helps us to manage
  database creation and version management in an easy way.
  On the other hand, the database is used for CRUD operations.
  */

  String noteTable = 'note_table';
  String colID = 'id';
  String coltitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabasesHelper._createInstance(); // named constructor which is going to be used to create the database.
  /*
  We are following a singleton design pattern here , any
  no of times we call the _createInstance() method it will 
  return the same object . If we are calling it for the
  first time , as it is not available in memory a new one 
  is created. Further , if we again call it , now that it
  is available in memory , it will not create a new
  instance again.
  */

  factory DatabasesHelper() {
    /*
    factory methods are singleton(as we do not want to run
    the database again and again while we perform 
    operations(like accessing , creating note , editting ,
    etc) multiple times , instead of this we want to run
    the database only once and put in or access the 
    information again and again ) methods that runs 
    once at a time.
    */
    if (_databasesHelper == null) {
      _databasesHelper = DatabasesHelper._createInstance();
    }
    return _databasesHelper!;
  }

// custom getter :-
  Future<Database> get database async {
    // we are using Future because these operations take a while and provide the result after a while , but these operations look instant becuase we have fast computers but actually it takes a while.
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    Directory directory =
        await getApplicationDocumentsDirectory(); // it provides the directory of the application in the device.
    String path = directory.path + 'notes.db';

    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);

    return notesDatabase;
  }

  // openDatabase() :-
  /*
  => Open the database at a given path
  => [version] (optional) specifies the schema version of 
     the database being opened. This is used to decide 
     whether to call [onCreate], [onUpgrade], and 
     [onDowngrade].
  => The optional callbacks are called in the following 
     order:
    -> [onConfigure]
    -> [onCreate] or [onUpgrade] or [onDowngrade]
    -> [onOpen]
  => If [version] is specified, [onCreate], [onUpgrade], 
     and [onDowngrade] can be called. These functions are
     mutually exclusive — only one of them can be called 
     depending on the context, although they can all be 
     specified to cover multiple scenarios
  => [onCreate] is called if the database did not exist 
     prior to calling [openDatabase]. You can use the 
     opportunity to create the required tables in the 
     database according to your schema
  */

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($colID INTEGER PRIMARY KEY AUTOINCREMENT,$coltitle TEXT,$colDescription TEXT,$colPriority INTEGER, $colDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database; // to get the reference to the database.
    // var result = await db.rawQuery('SELECT * from $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insertNote(note Note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, Note.toMap());
    return result; // to ensure that the operation is successful or not.
  }

  Future<int> updateNote(note Note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, Note.toMap(),
        where: '$colID = ?', whereArgs: [Note.id]);
    return result;
  }

  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    var result =
        await db.rawDelete('DELETE FROM $noteTable where $colID = $id');
    return result;
  }

  Future<int?> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int? result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;
    List<note> noteList = <note>[];
    for (var i = 0; i < count; i++) {
      noteList.add(note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }
}
