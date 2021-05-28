import 'package:flutter/material.dart';

class TextBox extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool password;

  TextBox(
      {@required this.controller,
      @required this.placeholder,
      this.password = false});

  @override
  _TextBoxState createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  bool isPassword;
  double fieldHeight = 55;

  @override
  void initState() {
    super.initState();
    isPassword = widget.password;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Colors.grey[200]),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              obscureText: isPassword,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration.collapsed(
                hintText: widget.placeholder,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              isPassword = !isPassword;
            }),
            child: widget.password
                ? Container(
                    height: fieldHeight,
                    width: fieldHeight,
                    alignment: Alignment.center,
                    child: Icon(
                        isPassword ? Icons.visibility : Icons.visibility_off),
                  )
                : Container(),
          )
        ],
      ),
    );
  }
}
