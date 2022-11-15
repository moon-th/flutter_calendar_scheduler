import 'package:calendar_schduler/database/drift_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'screen/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

const DEFAULT_COLORS = [
  // 빨강
  'F44336',
  // 주황
  'FF9800',
  // 노랑
  'FFEB3B',
  // 초록
  'FCAF50',
  // 파랑
  '2196F3',
  // 남색
  '3F51B5',
  // 보라색
  '9C27B0'
];

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // flutter 가 준비가 될 떄 까지 기다린다. runApp 을 실행하면 자동으로 실행되나 runApp 전에 실행하는 코드가 있으면 이미 실행시켜 준다.

  await initializeDateFormatting(); // intl 패키지 안에 있는 모든 언어들을 다 사용할 수 있다.

  final database = LocalDatabase();

  GetIt.I.registerSingleton<LocalDatabase>(database); // 어디에서든 해당 데이터베이스를 사용할 수 있다.

  final colors = await database.getCategoryColors();
  int i =0;

  if (colors.isEmpty) {
    for (String hexCode in DEFAULT_COLORS) {
      await database.createCategoryColor(
        CategoryColorsCompanion(
          id: Value(i=i+1),
          hexCode: Value(hexCode)
        ),
      );
    }
  }

  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'NotoSans',
    ),
    home: HomeScreen(),
  ));
}
