import 'package:flutter/material.dart';
import 'package:flutter_engage/_shared_text_widget.dart';

class TextWidgetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 800,
            child: Text(
              sharedText,
              style: sharedTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
