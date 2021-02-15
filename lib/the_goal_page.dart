import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_engage/_shared_text_widget.dart';

class TheGoalPage extends StatefulWidget {
  @override
  _TheGoalPageState createState() => _TheGoalPageState();
}

class _TheGoalPageState extends State<TheGoalPage> {
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
            SelectableTextGoal(
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

class SelectableTextGoal extends StatefulWidget {
  const SelectableTextGoal({
    Key key,
    this.text = '',
    this.initialSelection,
    this.style,
    this.selectionColor = Colors.yellowAccent,
    this.caretColor = Colors.black,
    this.caretWidth = 1,
    this.changeCursor = true,
    this.allowSelection = true,
    this.paintTextBoxes = false,
    this.textBoxesColor = Colors.grey,
    this.onSelectionChange,
  }) : super(key: key);

  final String text;
  final TextSelection initialSelection;
  final TextStyle style;
  final Color selectionColor;
  final Color caretColor;
  final double caretWidth;
  final bool changeCursor;
  final bool allowSelection;
  final bool paintTextBoxes;
  final Color textBoxesColor;
  final void Function(TextSelection) onSelectionChange;

  @override
  _SelectableTextGoalState createState() => _SelectableTextGoalState();
}

class _SelectableTextGoalState extends State<SelectableTextGoal> {
  final _textKey = GlobalKey();

  final _textBoxRects = <Rect>[];

  final _selectionRects = <Rect>[];
  TextSelection _textSelection;
  int _selectionBaseOffset;

  Rect _caretRect;

  MouseCursor _cursor = SystemMouseCursors.basic;

  @override
  void initState() {
    super.initState();
    _textSelection = widget.initialSelection ?? TextSelection.collapsed(offset: -1);
    _scheduleTextLayoutUpdate();
  }

  @override
  void didUpdateWidget(SelectableTextGoal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _textBoxRects.clear();
      _selectionRects.clear();
      _textSelection = TextSelection.collapsed(offset: -1);
      _caretRect = null;

      _scheduleTextLayoutUpdate();
    }
  }

  RenderParagraph get _renderParagraph => _textKey.currentContext.findRenderObject();

  void _scheduleTextLayoutUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateVisibleTextBoxes();
      _updateSelectionDisplay();
    });
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _selectionBaseOffset = _getTextPositionAtOffset(details.localPosition).offset;
      _onUserSelectionChange(TextSelection.collapsed(offset: _selectionBaseOffset));
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      final selectionExtentOffset = _getTextPositionAtOffset(details.localPosition).offset;
      final textSelection = TextSelection(
        baseOffset: _selectionBaseOffset,
        extentOffset: selectionExtentOffset,
      );

      _onUserSelectionChange(textSelection);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _selectionBaseOffset = null;
    });
  }

  void _onDragCancel() {
    setState(() {
      _selectionBaseOffset = null;
      _onUserSelectionChange(TextSelection.collapsed(offset: 0));
    });
  }

  void _onMouseMove(PointerEvent event) {
    if (!widget.changeCursor) {
      return;
    }

    if (event is PointerHoverEvent) {
      setState(() {
        _cursor = _isOffsetOverText(event.localPosition) ? SystemMouseCursors.text : SystemMouseCursors.basic;
      });
    }
  }

  void _onUserSelectionChange(TextSelection textSelection) {
    _textSelection = textSelection;
    _updateSelectionDisplay();
    widget.onSelectionChange?.call(textSelection);
  }

  void _updateSelectionDisplay() {
    setState(() {
      final selectionRects = _computeSelectionRects(_textSelection);
      _selectionRects
        ..clear()
        ..addAll(selectionRects);
      _caretRect = _textSelection != null ? _computeCursorRectForTextOffset(_textSelection.extentOffset) : null;
    });
  }

  void _updateVisibleTextBoxes() {
    setState(() {
      _textBoxRects
        ..clear()
        ..addAll(_computeAllTextBoxRects());
    });
  }

  Rect _computeCursorRectForTextOffset(int offset) {
    if (offset < 0) {
      return Rect.zero;
    }
    if (_renderParagraph == null) {
      return Rect.zero;
    }

    final caretOffset = _renderParagraph.getOffsetForCaret(
      TextPosition(offset: offset),
      Rect.zero,
    );
    final caretHeight = _renderParagraph.getFullHeightForCaret(
      TextPosition(offset: offset),
    );
    return Rect.fromLTWH(
      caretOffset.dx - (widget.caretWidth / 2),
      caretOffset.dy,
      widget.caretWidth,
      caretHeight,
    );
  }

  TextPosition _getTextPositionAtOffset(Offset localOffset) {
    final myBox = context.findRenderObject();
    final textOffset = _renderParagraph.globalToLocal(localOffset, ancestor: myBox);
    return _renderParagraph.getPositionForOffset(textOffset);
  }

  bool _isOffsetOverText(Offset localOffset) {
    final rects = _computeAllTextBoxRects();
    for (final rect in rects) {
      if (rect.contains(localOffset)) {
        return true;
      }
    }
    return false;
  }

  List<Rect> _computeAllTextBoxRects() {
    if (_textKey.currentContext == null) {
      return const [];
    }

    if (_renderParagraph == null) {
      return const [];
    }

    return _computeSelectionRects(
      TextSelection(
        baseOffset: 0,
        extentOffset: widget.text.length,
      ),
    );
  }

  List<Rect> _computeSelectionRects(TextSelection selection) {
    if (selection == null) {
      return [];
    }
    if (_renderParagraph == null) {
      return [];
    }

    final textBoxes = _renderParagraph.getBoxesForSelection(selection);
    return textBoxes.map((box) => box.toRect()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: _onMouseMove,
      child: MouseRegion(
        cursor: _cursor,
        child: GestureDetector(
          onPanStart: widget.allowSelection ? _onDragStart : null,
          onPanUpdate: widget.allowSelection ? _onDragUpdate : null,
          onPanEnd: widget.allowSelection ? _onDragEnd : null,
          onPanCancel: widget.allowSelection ? _onDragCancel : null,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              CustomPaint(
                painter: _SelectionPainter(
                  color: widget.selectionColor,
                  rects: _selectionRects,
                ),
              ),
              if (widget.paintTextBoxes)
                CustomPaint(
                  painter: _SelectionPainter(
                    color: widget.textBoxesColor,
                    rects: _textBoxRects,
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
                  color: widget.caretColor,
                  rects: _caretRect != null ? [_caretRect] : const [],
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
