// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
//
// // import 'package:facesdk_plugin/facesdk_plugin.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sqflite/sqflite.dart';
//
// import '../Api/Api.dart';
// import 'person.dart';
//
// List<Person> personList = <Person>[];
//
// class FaceDect {
//   final _facesdkPlugin = FacesdkPlugin();
//
//   void initFDF() async {
//     int facepluginState = -1;
//     try {
//       if (Platform.isAndroid) {
//         await _facesdkPlugin
//             .setActivation(
//                 "CFO+UUpNLaDMlmdjoDlhBMbgCwT27CzQJ4xHpqe9rDOErwoEUeCGPRTfQkZEAFAFdO0+rTNRIwnQwpqqGxBbfnLkfyFeViVS5bpWZFk15QXP3ZtTEuU1rK5zsFwcZrqRUxsG9dXImc+Vw5Ddc9zBp9GEUuDycHLqC9KgQGVb0TS2u9Kz67HQOSDw9hskjBpjRbqiG+F/h5DBLPzjgFh1Y6vzgg6I59FzTOcdrdEbX7kI15Nwgf1hvHGtSgON/a0Fmw+XNdnxH2pVY96mcTemHYZAtxh8lA/t1DtTyZXpHjW8N6nq4UN2YDlKLXSrDzLpLHJmBsdpH71AXb7dfAq94Q==")
//             .then((value) => facepluginState = value ?? -1);
//       } else {
//         await _facesdkPlugin
//             .setActivation(
//                 "nWsdDhTp12Ay5yAm4cHGqx2rfEv0U+Wyq/tDPopH2yz6RqyKmRU+eovPeDcAp3T3IJJYm2LbPSEz"
//                 "+e+YlQ4hz+1n8BNlh2gHo+UTVll40OEWkZ0VyxkhszsKN+3UIdNXGaQ6QL0lQunTwfamWuDNx7Ss"
//                 "efK/3IojqJAF0Bv7spdll3sfhE1IO/m7OyDcrbl5hkT9pFhFA/iCGARcCuCLk4A6r3mLkK57be4r"
//                 "T52DKtyutnu0PDTzPeaOVZRJdF0eifYXNvhE41CLGiAWwfjqOQOHfKdunXMDqF17s+LFLWwkeNAD"
//                 "PKMT+F/kRCjnTcC8WPX3bgNzyUBGsFw9fcneKA==")
//             .then((value) => facepluginState = value ?? -1);
//       }
//
//       if (facepluginState == 0) {
//         await _facesdkPlugin
//             .init()
//             .then((value) => facepluginState = value ?? -1);
//       }
//     } catch (e) {}
//
//     // await SettingsPageState.initSettings();
//
//     final prefs = await SharedPreferences.getInstance();
//     int? livenessLevel = prefs.getInt("liveness_level");
//
//     try {
//       await _facesdkPlugin
//           .setParam({'check_liveness_level': livenessLevel ?? 0});
//     } catch (e) {}
//
//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//
//     if (facepluginState == -1) {
//     } else if (facepluginState == -2) {
//     } else if (facepluginState == -3) {
//     } else if (facepluginState == -4) {
//     } else if (facepluginState == -5) {}
//   }
//
//   Future<Database> createDB() async {
//     final database = openDatabase(
//       // Set the path to the database. Note: Using the `join` function from the
//       // `path` package is best practice to ensure the path is correctly
//       // constructed for each platform.
//       join(await getDatabasesPath(), 'person.db'),
//       // When the database is first created, create a table to store dogs.
//       onCreate: (db, version) {
//         // Run the CREATE TABLE statement on the database.
//         return db.execute(
//           'CREATE TABLE person(name text, faceJpg blob, templates blob)',
//         );
//       },
//       // Set the version. This executes the onCreate function and provides a
//       // path to perform database upgrades and downgrades.
//       version: 1,
//     );
//     return database;
//   }
//
// // A method that retrieves all the dogs from the dogs table.
//   Future<List<Person>> loadAllPersons() async {
//     // Get a reference to the database.
//     final db = await createDB();
//     //await Api().fetchData(usrid.text);
//     // Query the table for all persons.
//     final List<Map<String, dynamic>> maps = await db.query('person');
//
//     // Convert the List<Map<String, dynamic>> into a List<Person> with null checks.
//     final List<Person> personList = [];
//     for (final map in maps) {
//       if (map['name'] != null &&
//           map['faceJpg'] != null &&
//           map['templates'] != null) {
//         personList.add(Person.fromMap(map));
//       } else {
//         // Handle the case where some data is missing
//         print("Error: Person data incomplete at index ${maps.indexOf(map)}");
//       }
//     }
//     return personList;
//   }
//
//   Future<List<Person>> insertPerson(Person person) async {
//     // Get a reference to the database.
//     final db = await createDB();
//
//     // Insert the Dog into the correct table. You might also specify the
//     // `conflictAlgorithm` to use in case the same dog is inserted twice.
//     //
//     // In this case, replace any previous data.
//     await db.insert(
//       'person',
//       person.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//
//     personList.add(person);
//     return personList;
//   }
//
//   Future<void> deleteAllPerson() async {
//     final db = await createDB();
//     await db.delete('person');
//
//     personList.clear();
//
//     Fluttertoast.showToast(
//         msg: "All person deleted!",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0);
//   }
//
//   Future<void> deletePerson(index) async {
//     // ignore: invalid_use_of_protected_member
//
//     final db = await createDB();
//     await db
//         .delete('person', where: 'name=?', whereArgs: [personList[index].name]);
//
//     personList.removeAt(index);
//
//     Fluttertoast.showToast(
//         msg: "Person removed!",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//         fontSize: 16.0);
//   }
//
//   Future<List<Person>> enrollPerson() async {
//     try {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? base64Profile = prefs.getString('profile');
//       List<int> profileBytes = base64Decode(base64Profile!);
//       final Uint8List inputImage = Uint8List.fromList(profileBytes);
//       Directory tempDir = await getTemporaryDirectory();
//       String tempPath = '${tempDir.path}/temp_image.jpg';
//       File tempFile = File(tempPath);
//       await tempFile.writeAsBytes(inputImage);
//
//       var rotatedImage = await FlutterExifRotation.rotateImage(path: tempPath);
//
//       final faces = await _facesdkPlugin.extractFaces(rotatedImage.path);
//       for (var face in faces) {
//         num randomNumber =
//             10000 + Random().nextInt(10000); // from 0 upto 99 included
//         Person person = Person(
//             name: 'Person$randomNumber',
//             faceJpg: face['faceJpg'],
//             templates: face['templates']);
//         return insertPerson(person);
//       }
//
//       if (faces.length == 0) {
//         await enrollPerson();
//         Fluttertoast.showToast(
//             msg: "No face detected!",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.red,
//             textColor: Colors.white,
//             fontSize: 16.0);
//         return personList;
//       } else {
//         Fluttertoast.showToast(
//             msg: "Person enrolled!",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 1,
//             backgroundColor: Colors.red,
//             textColor: Colors.white,
//             fontSize: 16.0);
//         return personList;
//       }
//     } catch (e) {
//       return personList;
//     }
//   }
// }
