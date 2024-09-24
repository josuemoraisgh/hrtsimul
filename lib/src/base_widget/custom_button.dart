import 'dart:core';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final String? titleOff;
  final Color? colorOn;
  final Color? colorOff;
  final String initialValue;
  final ValueNotifier<String> groupValue;
  final Function(String?)? onChanged;

  const CustomButton({
    super.key,
    required this.title,
    this.titleOff,
    required this.initialValue,
    required this.groupValue,
    this.onChanged,
    this.colorOn,
    this.colorOff,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: groupValue,
        builder: (context, groupValueNotifier, _) => Padding(
          padding: const EdgeInsets.all(5),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: initialValue == groupValueNotifier ||
                      groupValueNotifier == ""
                  ? WidgetStateProperty.all<Color>(colorOn ?? Colors.black54)
                  : WidgetStateProperty.all<Color>(colorOff ?? Colors.white),
              elevation: WidgetStateProperty.all(8),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side:
                      BorderSide(width: 0.2, color: colorOn ?? Colors.black54),
                ),
              ),
            ),
            onPressed: (onChanged != null)
                ? () {
                    if (groupValue.value == (titleOff ?? "") ||
                        groupValue.value == "") {
                      groupValue.value = title;
                    } else {
                      groupValue.value = titleOff ?? "";
                    }
                    onChanged!(groupValue.value);
                  }
                : null,
            child: Text(
              titleOff != null
                  ? groupValueNotifier == ""
                      ? initialValue
                      : groupValueNotifier
                  : title,
              style: TextStyle(
                fontSize: 18,
                color: initialValue == groupValueNotifier ||
                        groupValueNotifier == ""
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
        ),
      );
}
