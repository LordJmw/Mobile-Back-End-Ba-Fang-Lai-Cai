import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaserService {
  String DB_NAME = "eventhub.db";
  Database? database;

  Future<Database> getDatabase() async {
    if (database != null) return database!;
    database = await initDataBase();
    return database!;
  }

  Future<Database> initDataBase() async {
    String DB_PATH = await getDatabasesPath();
    String path = join(DB_PATH, DB_NAME);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Vendor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        deskripsi TEXT,
        rating REAL,
        harga TEXT,
        testimoni TEXT,
        email TEXT,
        telepon TEXT,
        image TEXT,
        kategori TEXT,
        alamat TEXT,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Customer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        email TEXT,
        password TEXT,
        telepon TEXT,
        alamat TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE PurchaseHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        purchase_details TEXT,
        purchase_date TEXT,
        FOREIGN KEY (customer_id) REFERENCES Customer (id)
      )
    ''');
  }

  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Drop the old tables and recreate them to remove the isLoggedIn column
      await db.execute("DROP TABLE IF EXISTS PurchaseHistory");
      await db.execute("DROP TABLE IF EXISTS Vendor");
      await db.execute("DROP TABLE IF EXISTS Customer");
      _createDb(db, newVersion);
    }
  }
}
