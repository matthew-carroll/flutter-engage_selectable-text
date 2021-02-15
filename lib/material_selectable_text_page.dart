import 'package:flutter/material.dart';

import '_shared_text_widget.dart';

class MaterialSelectableTextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 800,
            child: SelectableText(
              sharedText,
              style: sharedTextStyle,
              showCursor: true,
            ),
          ),
        ],
      ),
    );
  }
}
