import 'package:daily_tracker/shared/shared_styles.dart';
import 'package:flutter/material.dart';

class BusyCheckbox extends StatefulWidget {
  final bool busy;
  final Function onPressed;
  final bool checked;

  const BusyCheckbox(
      {this.busy = false, @required this.onPressed, @required this.checked});

  @override
  _BusyCheckbox createState() => _BusyCheckbox();
}

class _BusyCheckbox extends State<BusyCheckbox> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.busy ? () => {} : widget.onPressed,
      splashColor: NeonGreen,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 75, vertical: 75),
                  child: Transform.scale(
                    scale: 11.0,
                    child: AbsorbPointer(
                      absorbing: !widget.busy,
                      child: Checkbox(
                        fillColor: MaterialStateProperty.all<Color>(NeonGreen),
                        value: widget.checked,
                        onChanged: (bool value) => {},
                        splashRadius: 9,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.busy)
                Container(
                  alignment: Alignment.topRight,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: NeonGreen,
                  ),
                ),
            ],
          )),
    );
  }
}
