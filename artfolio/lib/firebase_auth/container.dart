import 'package:flutter/material.dart';

class FormContainerWidget extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final Key? fieldKey;
  final bool? isPassword;
  final TextEditingController? controller;
  final FormFieldSetter<String>? onSaved;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? inputType;

  const FormContainerWidget({
    this.hintText,
    this.labelText,
    this.helperText,
    this.fieldKey,
    this.isPassword,
    this.controller,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.inputType,
  });

  @override
  _FormContainerWidgetState createState() => _FormContainerWidgetState();
}

class _FormContainerWidgetState extends State<FormContainerWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: TextFormField(
        style: TextStyle(color: Color.fromARGB(255, 52, 7, 86)),
        controller: widget.controller,
        keyboardType: widget.inputType,
        key: widget.fieldKey,
        obscureText: widget.isPassword == true ? _obscureText : false,
        onSaved: widget.onSaved,
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromARGB(255, 209, 233, 243).withOpacity(.35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.black54),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
            child: widget.isPassword == true
                ? Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: _obscureText == false
                        ? Color.fromARGB(255, 129, 139, 247)
                        : Colors.grey,
                  )
                : Text(' '),
          ),
        ),
      ),
    );
  }
}