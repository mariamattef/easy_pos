import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SqlHelper {
  Database? db;
  Future<void> init() async {
    try {
      if (kIsWeb) {
        var factory = databaseFactoryFfiWeb;
        db = await factory.openDatabase('my_db.db');
        // var sqliteVersion =
        //     (await db!.rawQuery('select sqlite_version()')).first.values.first;
        // print('>>>>>$sqliteVersion');
      } else {
        var db = await openDatabase(
          'pos.db',
          version: 1,
          onCreate: (db, version) {
            print('>>>>>>>>>> :  DataBase Created Successfully');
          },
        );
      }
    } catch (ex) {
      print('>>> Error in creating database $ex');
    }
  }

  Future<bool> createTables() async {
    try {
      var batch = db!.batch();
      batch.execute('''
        create table if not exists 'categories' (
        id integer primary key autoincrement,
        name text not null,
        description text not null,
       
        )
         ''');

      batch.execute('''
        create table if not exists 'products' (
        id integer primary key autoincrement,
        name text not null,
        description text not null,
       price double not null,
       stock integer not null,
       isAvailable boolean not null,
       image blob,
       categoryId integer not null,

        )
         ''');
      batch.execute('''
        create table if not exists 'clients' (
        id integer primary key autoincrement,
        name text not null,
        phone text ,
        email text ,
        address text 
       
        )
         ''');
      var result = await batch.commit();
      print('Result $result');
      print('Table Created Successfully');
      return true;
    } catch (ex) {
      print('Error in creating Table : $ex');
      return false;
    }
  }
}






























// class SqlHelper {
//   static SqlHelper? _instance;
//   Database? db;
//   SqlHelper._();

//   factory SqlHelper() {
//     _instance ??= SqlHelper._();
//     return _instance!;
//   }

//   Future<void> createTables() async {
//     try {
//       await db!.execute('''
//         create table if not exists 'employee' (
//         id integer primary key autoincrement,
//         name String,
//         email String,
//         password String,
//         phone String
//         )
//          ''');
//     } catch (e) {
//       print('Error $e');
//     }
//   }

//   Future<void> init() async {
//     try {
//       if (kIsWeb) {
//         var factory = databaseFactoryFfiWeb;
//         db = await factory.openDatabase('emp.db');
//       } else {
//         db = await openDatabase(
//           'emp.db',
//           version: 1,
//           onCreate: (Database db, int version) {
//             print('>>>>>>>>>> database created sucssefully');
//           },
//         );
//       }
//       createTables();
//     } catch (e) {
//       print('Errror in created database :$e');
//     }
//   }

//   Future<int> insertData(String sql) async {
//     int response = await db!.rawInsert(sql);
//     return response;
//   }

//   Future<List<Map<String, dynamic>>> getData(String sql) async {
//     List<Map<String, dynamic>> response = await db!.rawQuery(sql);
//     return response;
//   }

//   Future<int> deleteData(String sql) async {
//     int response = await db!.rawDelete(sql);
//     return response;
//   }
// }




// import 'package:flutter/foundation.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// class SqlHelper {
//   Database? db;
//   SqlHelper() {
//     _init();
//   }
//   void createTables() async {
//     try {
//       await db!.execute('''
//         create teble if not exists customer(
//         id intger primary key autoincrement,
//         name text,
//         phone text,
//         email text,
//         )
// ''');
//     } catch (e) {
//       print('Error $e');
//     }
//   }

//   void _init() async {
//     try {
//       if (kIsWeb) {
//         var factory = databaseFactoryFfiWeb;
//         db = await factory.openDatabase('pos.db');
//       } else {
//         db = await openDatabase(
//           'pos.db',
//           version: 1,
//           onCreate: (db, version) {
//             print('>>>>>>>>>> database created sucssefully');
//           },
//         );
//       }
//     } catch (e) {
//       print('Errror in created database :$e');
//     }
//   }
// }
