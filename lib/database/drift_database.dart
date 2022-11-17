// private 값들은 불러올 수 없다.
import 'dart:io';

import 'package:calendar_schduler/model/schedule_with_color.dart';
import 'package:flutter/material.dart';
import 'package:calendar_schduler/model/category_color.dart';
import 'package:calendar_schduler/model/schedule.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as P;
import 'package:path_provider/path_provider.dart';

// private 값들까지 불러올 수 있다. .g 파일이 자동으로 생성
part 'drift_database.g.dart';

@DriftDatabase(
  tables: [
    Schedules,
    CategoryColors,
  ],
)

// _$LocalDatabase .g 파일에 생성된다
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  Future<int> createSchedule(SchedulesCompanion data) => //inset 구문
      into(schedules).insert(data); // insert 한 primary key 를 돌려준다

  Future<int> createCategoryColor(CategoryColorsCompanion data) =>
      into(categoryColors).insert(data);

  Future<Schedule> getScheduleById(int id) =>
      (select(schedules)..where((tbl) => tbl.id.equals(id))).getSingle();

  // 단발적인 것
  Future<List<CategoryColor>> getCategoryColors() =>
      select(categoryColors).get();

  Future<int> updateScheduleById(int id, SchedulesCompanion data) =>
      (update(schedules)..where((tbl) => tbl.id.equals(id))).write(data);

  //삭제
   Future<int> removeSchedule(int id) =>
      (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();

  // 업데이터 될 때마다 받을 수 있다.
  Stream<List<ScheduleWithColor>> watchSchedules(DateTime date) {
    final query = select(schedules).join([
      innerJoin(categoryColors, categoryColors.id.equalsExp(schedules.colorId))
    ]);
    query.where(schedules.date.equals(date));
    query.orderBy([OrderingTerm.asc(schedules.startTime)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => ScheduleWithColor(
                  schedule: row.readTable(schedules),
                  categoryColor: row.readTable(categoryColors),
                ),
              )
              .toList(),
        );
    //  return (select(schedules)..where((tbl) => tbl.date.equals(date))).watch();
  }

  // final query = select(schedules);
  // query.where((tbl) => tbl.date.equals(date));
  // return query.watch();

  // num1 = number.toString() -> String 형태가 반환
  // num2 = number..toString() -> int 반환
  // ..은 함수는 실행이 되나 함수가 실행한 주체를 번환해 준다.

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder =
        await getApplicationDocumentsDirectory(); // 앱 전용으로 사용할 수 있는 폴더
    final file = File(P.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
