import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/app_module.dart';
import 'src/app_widget.dart';

Box<dynamic>? boxHrtStorage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  boxHrtStorage ??= await Hive.openBox<dynamic>('HRTSTORAGE');  
  runApp(ModularApp(module: AppModule(), child: const AppWidget()));
}