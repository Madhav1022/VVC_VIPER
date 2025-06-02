import 'package:path/path.dart' as P;
import 'package:sqflite/sqflite.dart';
import '../entities/contact_entity.dart';

class DbHelper {
  final String _createTableContact = '''
    CREATE TABLE $tableContact(
      $tblContactColId INTEGER PRIMARY KEY AUTOINCREMENT,
      $tblContactColName TEXT,
      $tblContactColMobile TEXT,
      $tblContactColEmail TEXT,
      $tblContactColAddress TEXT,
      $tblContactColCompany TEXT,
      $tblContactColDesignation TEXT,
      $tblContactColWebsite TEXT,
      $tblContactColImage TEXT,
      $tblContactColFavorite INTEGER
    )
  ''';

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    final dbPath = P.join(root, 'contact.db');
    return openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) {
        db.execute(_createTableContact);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 1) {
          await db.execute('ALTER TABLE $tableContact RENAME TO contact_old');
          await db.execute(_createTableContact);
          final rows = await db.query('contact_old');
          for (var row in rows) {
            await db.insert(tableContact, row);
          }
          await db.execute('DROP TABLE IF EXISTS contact_old');
        }
      },
    );
  }

  /// Inserts or replaces a contact in the local SQLite cache.
  Future<int> insertContact(ContactEntity contactEntity) async {
    final db = await _open();
    return db.insert(
      tableContact,
      contactEntity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ContactEntity>> getAllContacts() async {
    final db = await _open();
    final mapList = await db.query(tableContact);
    return List.generate(
      mapList.length,
          (i) => ContactEntity.fromMap(mapList[i]),
    );
  }

  Future<ContactEntity> getContactById(int id) async {
    final db = await _open();
    final mapList = await db.query(
      tableContact,
      where: '$tblContactColId = ?',
      whereArgs: [id],
    );
    return ContactEntity.fromMap(mapList.first);
  }

  Future<List<ContactEntity>> getAllFavoriteContacts() async {
    final db = await _open();
    final mapList = await db.query(
      tableContact,
      where: '$tblContactColFavorite = ?',
      whereArgs: [1],
    );
    return List.generate(
      mapList.length,
          (i) => ContactEntity.fromMap(mapList[i]),
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await _open();
    return db.delete(
      tableContact,
      where: '$tblContactColId = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateFavorite(int id, int value) async {
    final db = await _open();
    return db.update(
      tableContact,
      {tblContactColFavorite: value},
      where: '$tblContactColId = ?',
      whereArgs: [id],
    );
  }
}
