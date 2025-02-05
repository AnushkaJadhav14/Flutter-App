import 'package:flutter/material.dart';
// import '/Service/mongo_auth_service.dart';
// import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MongoDB connection
  // final db = mongo.Db('mongodb+srv://your_mongo_uri_here');
  // await db.open();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
