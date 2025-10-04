import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaserService {
  String DB_NAME = "eventhub.db";
  int VERSION = 1;
  Database? database;

  Future<Database> getDatabase() async {
    if (database != null) {
      return database!;
    }
    database = await initDataBase();
    return database!;
  }

  Future<Database> initDataBase() async {
    String DB_PATH = await getDatabasesPath();
    String path = join(DB_PATH, DB_NAME);

    return await openDatabase(
      path,
      version: VERSION,
      onCreate: (db, version) {
        //Harga ada 3 tipe dan isinya  string dan int, jadi buat TEXT aja dulu
        db.execute(
          'CREATE TABLE Vendor (id INTEGER PRIMARY KEY AUTOINCREMENT, nama TEXT, deskripsi TEXT, rating REAL,harga TEXT,testimoni TEXT, email TEXT,telepon TEXT,image TEXT,kategori TEXT)',
        );
      },
    );
  }
}
