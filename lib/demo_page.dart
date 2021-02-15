import 'package:flutter/material.dart';
import 'package:flutter_engage/_shared_text_widget.dart';

class DemoPage extends StatefulWidget {
  @override
  _DemoPageState createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  TextSelection _currentSelection = TextSelection.collapsed(offset: 0);

  void _onSelectionChange(TextSelection textSelection) {
    setState(() {
      _currentSelection = textSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedText = _currentSelection.textInside(sharedText);
    return Center(
      child: SizedBox(
        width: 800,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableTextDemo(
              text: sharedText,
              style: sharedTextStyle,
              onSelectionChange: _onSelectionChange,
            ),
            SizedBox(height: 48),
            Text(
              selectedText.isNotEmpty ? selectedText : 'No Text Selected',
              style: sharedTextStyle.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectableTextDemo extends StatefulWidget {
  const SelectableTextDemo({
    Key key,
    this.text,
    this.style,
    this.onSelectionChange,
  }) : super(key: key);

  final String text;
  final TextStyle style;
  final void Function(TextSelection) onSelectionChange;

  @override
  _SelectableTextDemoState createState() => _SelectableTextDemoState();
}

class _SelectableTextDemoState extends State<SelectableTextDemo> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: widget.style,
    );
  }
}

class _SelectionPainter extends CustomPainter {
  _SelectionPainter({
    @required Color color,
    @required List<Rect> rects,
    bool fill = true,
  })  : _color = color,
        _rects = rects,
        _fill = fill,
        _paint = Paint()..color = color;

  final Color _color;
  final bool _fill;
  final List<Rect> _rects;
  final Paint _paint;

  @override
  void paint(Canvas canvas, Size size) {
    _paint.style = _fill ? PaintingStyle.fill : PaintingStyle.stroke;
    for (final rect in _rects) {
      canvas.drawRect(rect, _paint);
    }
  }

  @override
  bool shouldRepaint(_SelectionPainter other) {
    return true;
  }
}
