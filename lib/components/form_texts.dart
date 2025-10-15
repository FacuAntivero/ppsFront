import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/constants/size_config.dart';

TextFormField customTextForm(
  TextEditingController controller, {
  required String labelText,
  required String hintText,
  required TextInputType inputType,
  required IconData icon,
  required BuildContext context,
  FocusNode? focusNode,
}) {
  return TextFormField(
    textAlignVertical: TextAlignVertical.center,
    controller: controller,
    autocorrect: false,
    focusNode: focusNode,
    keyboardType: inputType,
    cursorColor: Theme.of(context).colorScheme.primary,
    style: TextStyle(color: Theme.of(context).colorScheme.surface),
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      labelText: labelText,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: xxxs(),
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: xxs(),
        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        fontWeight: FontWeight.normal,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      prefixIcon: Icon(
        icon,
      ),
    ),
  );
}

class PasswordFormText extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;

  const PasswordFormText({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
  });

  @override
  PasswordFormTextState createState() => PasswordFormTextState();
}

class PasswordFormTextState extends State<PasswordFormText> {
  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: obscure,
      cursorColor: Theme.of(context).colorScheme.primary,
      style: TextStyle(color: Theme.of(context).colorScheme.surface),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: xxxs(),
        ),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: xxs(),
          color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
          fontWeight: FontWeight.normal,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: const Icon(
          Icons.lock,
        ),
      ),
    );
  }
}

class MessageTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;

  const MessageTextField({
    super.key,
    required this.hintText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      minLines: 1,
      autocorrect: true,
      cursorColor: Theme.of(context).colorScheme.primary,
      cursorHeight: sm(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.surface,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondary,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
          fontSize: xxs(),
          fontWeight: FontWeight.normal,
        ),
        counterText: '',
        contentPadding: EdgeInsets.symmetric(
          vertical: SizeConfig.screenHeight * 0.0025,
          horizontal: SizeConfig.screenWidth * 0.05,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}

Widget minimalistEditableInfo({
  required TextEditingController? controller,
  required BuildContext context,
  required String hintText,
  required bool enabled,
  TextInputType? keyboardType,
}) {
  return TextFormField(
    keyboardType: keyboardType,
    controller: controller,
    readOnly: !enabled,
    cursorColor: Theme.of(context).colorScheme.primary,
    style: TextStyle(
      color: Theme.of(context).colorScheme.surface,
      fontSize: xs(),
      fontWeight: FontWeight.normal,
    ),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: xs(),
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(
          strokeAlign: BorderSide.strokeAlignOutside,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          strokeAlign: BorderSide.strokeAlignOutside,
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      isDense: true,
    ),
  );
}

Widget minimalistEditableBio({
  required TextEditingController? controller,
  required BuildContext context,
  required String hintText,
  required bool enabled,
}) {
  return TextFormField(
    controller: controller,
    readOnly: !enabled,
    cursorColor: Theme.of(context).colorScheme.primary,
    style: TextStyle(
      color: Theme.of(context).colorScheme.surface,
      fontSize: xs(),
    ),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: xs(),
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(
          strokeAlign: BorderSide.strokeAlignOutside,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          strokeAlign: BorderSide.strokeAlignOutside,
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      isDense: true,
      counterText: '',
    ),
    minLines: 1,
    maxLines: 4,
    maxLength: 200,
  );
}

class SupportFormField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType textInputType;
  final String labelText;
  final String validatorText;
  final bool enabled;
  final int? maxLines;
  final int? maxLenght;

  const SupportFormField({
    super.key,
    required this.controller,
    required this.textInputType,
    required this.labelText,
    required this.validatorText,
    required this.enabled,
    this.maxLines,
    this.maxLenght,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: !enabled,
      enabled: enabled,
      controller: controller,
      keyboardType: textInputType,
      style: TextStyle(
        fontSize: xs(),
        fontWeight: FontWeight.normal,
        color: Theme.of(context).colorScheme.surface,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: xs(),
          fontWeight: FontWeight.normal,
          color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
        ),
        floatingLabelStyle: TextStyle(
          fontSize: xs(),
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.surface,
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surface,
            width: 2,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: CupertinoColors.destructiveRed,
          ),
        ),
        suffixIcon: enabled
            ? null
            : Icon(
                CupertinoIcons.lock,
                color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
              ),
      ),
      maxLines: maxLines,
      maxLength: maxLenght,
      validator: (value) => value!.isEmpty ? validatorText : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
