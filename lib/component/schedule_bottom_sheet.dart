import 'package:calendar_schduler/const/colors.dart';
import 'package:calendar_schduler/database/drift_database.dart';
import 'package:calendar_schduler/model/category_color.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:calendar_schduler/database/drift_database.dart';

import 'custom_text_field.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;

  const ScheduleBottomSheet({
    Key? key,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime;
  int? endTime;
  String? content;
  int? selectedColorId;

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context).viewInsets.bottom; // 스크린 부분에서 시스템적인 ui 의  크기

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height / 2 + bottomInset,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 16),
              child: Form(
                key: formKey,
                autovalidateMode:
                    AutovalidateMode.always, // 실시간으로 벨리데이션을 체크하여 준다.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TIme(
                      onStartSaved: (String? val) {
                        startTime = int.parse(val!);
                      },
                      onEndSaved: (String? val) {
                        endTime = int.parse(val!);
                      },
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    _Content(
                      onSaved: (String? val) {
                        content = val;
                      },
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    FutureBuilder<List<CategoryColor>>(
                        future: GetIt.I<LocalDatabase>().getCategoryColors(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData &&
                              selectedColorId == null &&
                              snapshot.data!.isNotEmpty) {
                            selectedColorId = snapshot.data![0].id;
                          }

                          return _ColorPicker(
                            colors: snapshot.hasData ? snapshot.data! : [],
                            selectedColorId: selectedColorId,
                            colorIdSetter: (int id) {
                              setState(() {
                                selectedColorId = id;
                              });
                            },
                          );
                        }),
                    SizedBox(
                      height: 16,
                    ),
                    _SaveButton(
                      onPressed: onSavePressed,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onSavePressed() async{
    // formKey 는 생성을 했는데
    // Form 위젯과 결압을 안했을떄
    if (formKey.currentContext == null) {
      // 현재상태

      return;
    }
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save(); // onSaved 가 전부 실행이 된다.

     final key = await GetIt.I<LocalDatabase>().createSchedule(
        SchedulesCompanion(
          date: Value(widget.selectedDate),
          startTime: Value(startTime!),
          endTime: Value(endTime!),
          content: Value(content!),
          colorId: Value(selectedColorId!),
        ),
      );

     Navigator.of(context).pop();
    } else {

    }
  }
}

class _TIme extends StatelessWidget {
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;

  const _TIme({Key? key, required this.onStartSaved, required this.onEndSaved})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: CustomTextField(
          label: '시작시간',
          isTime: true,
          onSaved: onStartSaved,
        )),
        SizedBox(
          width: 16.0,
        ),
        Expanded(
            child: CustomTextField(
          label: '마감시간',
          isTime: true,
          onSaved: onEndSaved,
        )),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final FormFieldSetter<String> onSaved;

  const _Content({Key? key, required this.onSaved}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: '내용',
        isTime: false,
        onSaved: onSaved,
      ),
    );
  }
}

typedef ColorIdSetter = void Function(int id);

class _ColorPicker extends StatelessWidget {
  final List<CategoryColor> colors;
  final int? selectedColorId;
  final ColorIdSetter colorIdSetter;

  const _ColorPicker({
    Key? key,
    required this.colors,
    required this.selectedColorId,
    required this.colorIdSetter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // 양옆
      runSpacing: 10.0, // 위아래
      children: colors
          .map((e) => GestureDetector(
                onTap: () {
                  colorIdSetter(e.id);
                },
                child: renderColor(
                  e,
                  selectedColorId == e.id,
                ),
              ))
          .toList(),
    );
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(
            int.parse(
              'FF${color.hexCode}',
              radix: 16,
            ),
          ),
          border: isSelected
              ? Border.all(
                  color: Colors.black,
                  width: 4.0,
                )
              : null),
      width: 32.0,
      height: 32.0,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            child: Text('저장'),
            style: ElevatedButton.styleFrom(
              primary: PRIMARY_COLOR,
            ),
          ),
        ),
      ],
    );
  }
}
