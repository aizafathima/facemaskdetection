import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String buttonName;
  final IconData buttonIcon;
  final double paddingVertical;
  final Function onTap;
  RoundButton(
      {@required this.buttonIcon,
      @required this.buttonName,
      @required this.paddingVertical,
      @required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: paddingVertical),
      child: Material(
        elevation: 5.0,
        color: Color(0XFF8FDADD),
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onTap,
          minWidth: 200.0,
          height: 42.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                buttonIcon,
                color: Color(0XFF565B64),
              ),
              SizedBox(
                width: 5.0,
              ),
              Text(
                buttonName,
                style: TextStyle(color: Color(0XFF565B64)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
