import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class BottomButton extends StatelessWidget {
  BottomButton({this.onTap, @required this.buttonTitle});

  final Function onTap;
  final String buttonTitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Center(
          child: Text(
            buttonTitle,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w600,
              color: Color(0XFF565B64),
            ),
          ),
        ),
        color: Color(0XFF8FDADD),
        margin: EdgeInsets.only(top: 15.0),
        padding: EdgeInsets.only(bottom: 10.0),
        width: double.infinity,
        height: 40.0,
      ),
    );
  }
}
