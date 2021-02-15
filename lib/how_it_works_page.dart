import 'package:flutter/material.dart';
import 'package:flutter_engage/the_goal_page.dart';

import '_shared_text_widget.dart';

class HowItWorksPage extends StatefulWidget {
  @override
  _HowItWorksPageState createState() => _HowItWorksPageState();
}

class _HowItWorksPageState extends State<HowItWorksPage> {
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        _buildTextPositionExample(),
        _buildTextSelectionExample(),
        _buildTextBoxesExample(),
      ],
    );
  }

  Widget _buildTextPositionExample() {
    return _buildPageLayout(
      title: 'Text Position',
      content: SelectableTextGoal(
        text: sharedText,
        initialSelection: TextSelection.collapsed(offset: 11),
        caretColor: Colors.red,
        caretWidth: 3,
        allowSelection: false,
        changeCursor: false,
        style: sharedTextStyle,
      ),
      data: '${TextPosition(offset: 11)}',
    );
  }

  Widget _buildTextSelectionExample() {
    return _buildPageLayout(
      title: 'Text Selection',
      content: SelectableTextGoal(
        text: sharedText,
        initialSelection: TextSelection(
          baseOffset: 11,
          extentOffset: 19,
        ),
        caretColor: Colors.red,
        caretWidth: 3,
        allowSelection: false,
        changeCursor: false,
        style: sharedTextStyle,
      ),
      data: '${TextSelection(baseOffset: 11, extentOffset: 19)}',
    );
  }

  Widget _buildTextBoxesExample() {
    return _buildPageLayout(
      title: 'Text Boxes',
      content: SelectableTextGoal(
        text: sharedText,
        allowSelection: false,
        changeCursor: false,
        paintTextBoxes: true,
        style: sharedTextStyle,
      ),
      data: '',
    );
  }

  Widget _buildPageLayout({
    @required String title,
    @required Widget content,
    @required String data,
  }) {
    return Center(
      child: SizedBox(
        width: 800,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 48),
            content,
            SizedBox(height: 48),
            Text(
              data,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
