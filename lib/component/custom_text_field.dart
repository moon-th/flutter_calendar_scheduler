import 'package:calendar_schduler/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String initialValue;
  // true 시간 false 내용
  final bool isTime;
  final FormFieldSetter<String> onSaved;

  const CustomTextField(
      {Key? key,
      required this.label,
      required this.isTime,
      required this.onSaved,
      required this.initialValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PRIMARY_COLOR,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isTime) renderTextField(),
        if (!isTime) Expanded(child: renderTextField())
      ],
    );
  }

  Widget renderTextField() {
    return TextFormField(
      onSaved: onSaved,
      // null 이 return 되면 에러가 없다.
      // 에러가 있으면 에럴를 string 값으로 리턴해준다.
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return '값을 입력해주세요';
        }

        if (isTime) {
          int time = int.parse(val);

          if (time < 0) {
            return '0 이상의 숫자를 입력해주세요';
          }

          if (time > 24) {
            return '24 이하의 숫자를 입력해주세요';
          }
        } else {
          if (val.length > 500) {
            return '500자 이하의 글자를 입력해주세요.';
          }
        }

        return null;
      },
      expands: !isTime, // 전체 부모의 높이만큼 넓히는 기능
      cursorColor: Colors.grey,
      initialValue: initialValue,
      maxLines: isTime ? 1 : null,
      maxLength: 500,
      keyboardType: isTime ? TextInputType.number : TextInputType.multiline,
      inputFormatters: isTime
          ? [
              FilteringTextInputFormatter.digitsOnly // 숫자만 적용가능
            ]
          : [],
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.grey[300],
        suffixText: isTime ? '시' : null,
      ),
    );
  }
}
