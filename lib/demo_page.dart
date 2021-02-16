import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final _textKey = GlobalKey();

  final List<Rect> _textRects = [];
  final List<Rect> _selectionRects = [];
  Rect _caretRect = Rect.zero;

  int _selectionBaseOffset;
  TextSelection _textSelection = TextSelection.collapsed(offset: -1);

  MouseCursor _cursor = SystemMouseCursors.basic;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateAllTextRects();
    });
  }

  RenderParagraph get _renderParagraph => _textKey.currentContext.findRenderObject() as RenderParagraph;

  void _onPanStart(DragStartDetails details) {
    if (_renderParagraph == null) {
      return;
    }

    _selectionBaseOffset = _renderParagraph.getPositionForOffset(details.localPosition).offset;
    _textSelection = TextSelection.collapsed(offset: _selectionBaseOffset);
    _updateSelectionDisplay();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final selectionExtentOffset = _renderParagraph.getPositionForOffset(details.localPosition).offset;
    _textSelection = TextSelection(
      baseOffset: _selectionBaseOffset,
      extentOffset: selectionExtentOffset,
    );
    _updateSelectionDisplay();
  }

  void _onPanEnd(DragEndDetails details) {
    // TODO:
  }

  void _onPanCancel() {
    // TODO:
  }

  void _updateSelectionDisplay() {
    // Compute selection rectangles.
    final selectionRects = _computeRectsForSelection(_textSelection);

    // Update caret display
    final caretOffset = _renderParagraph.getOffsetForCaret(_textSelection.extent, Rect.zero);
    final caretHeight = _renderParagraph.getFullHeightForCaret(_textSelection.extent);

    setState(() {
      _selectionRects
        ..clear()
        ..addAll(selectionRects);
      _caretRect = Rect.fromLTWH(caretOffset.dx - 1, caretOffset.dy, 2, caretHeight);

      widget.onSelectionChange?.call(_textSelection);
    });
  }

  void _onMouseMove(event) {
    if (event is PointerHoverEvent) {
      if (_renderParagraph == null) {
        return;
      }

      final allTextRects = _computeRectsForSelection(
        TextSelection(
          baseOffset: 0,
          extentOffset: widget.text.length,
        ),
      );
      bool isOverText = false;
      for (final rect in allTextRects) {
        if (rect.contains(event.localPosition)) {
          isOverText = true;
        }
      }

      final newCursor = isOverText ? SystemMouseCursors.text : SystemMouseCursors.basic;
      if (newCursor != _cursor) {
        setState(() {
          _cursor = newCursor;
        });
      }
    }
  }

  void _updateAllTextRects() {
    setState(() {
      _textRects
        ..clear()
        ..addAll(
          _computeRectsForSelection(
            TextSelection(
              baseOffset: 0,
              extentOffset: widget.text.length,
            ),
          ),
        );
    });
  }

  List<Rect> _computeRectsForSelection(TextSelection textSelection) {
    if (_renderParagraph == null) {
      return [];
    }

    final textBoxes = _renderParagraph.getBoxesForSelection(textSelection);
    return textBoxes.map((box) => box.toRect()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: _onMouseMove,
      child: MouseRegion(
        cursor: _cursor,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          onPanCancel: _onPanCancel,
          child: Stack(
            children: [
              CustomPaint(
                painter: _SelectionPainter(
                  color: Colors.yellow,
                  rects: _selectionRects,
                  fill: true,
                ),
              ),
              CustomPaint(
                painter: _SelectionPainter(
                  color: Colors.grey,
                  rects: _textRects,
                  fill: false,
                ),
              ),
              Text(
                widget.text,
                key: _textKey,
                style: widget.style,
              ),
              CustomPaint(
                painter: _SelectionPainter(
                  color: Colors.blue,
                  rects: [_caretRect],
                  fill: true,
                ),
              ),
            ],
          ),
        ),
      ),
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
