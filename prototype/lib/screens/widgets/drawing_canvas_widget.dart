import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Represents a single stroke.
class DrawingPoint {
  final Offset offset;
  final Paint paint;
  final String toolType;

  DrawingPoint({
    required this.offset,
    required this.paint,
    required this.toolType,
  });
}

/// Represents a complete stroke with multiple points.
class DrawingStroke {
  final List<DrawingPoint> points;
  final String toolType;

  DrawingStroke({required this.points, required this.toolType});
}

/// Represents a line segment (for line tool).
class LineSegment {
  final Offset start;
  final Offset end;
  final Paint paint;

  LineSegment({required this.start, required this.end, required this.paint});
}

/// Represents a rectangle (for rectangle tool).
class RectangleShape {
  final Rect rect;
  final Paint paint;

  RectangleShape({required this.rect, required this.paint});
}

/// Represents a circle (for circle tool).
class CircleShape {
  final Offset center;
  final double radius;
  final Paint paint;

  CircleShape({
    required this.center,
    required this.radius,
    required this.paint,
  });
}

/// Canvas painter for drawing.
class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final List<LineSegment> lines;
  final List<RectangleShape> rectangles;
  final List<CircleShape> circles;
  final Offset? currentPoint;
  final String currentTool;
  final Offset? lineStart;
  final Offset? rectStart;
  final Paint? previewPaint;
  final List<DrawingPoint>? currentStrokePoints;

  DrawingPainter({
    required this.strokes,
    required this.lines,
    required this.rectangles,
    required this.circles,
    this.currentPoint,
    required this.currentTool,
    this.lineStart,
    this.rectStart,
    this.previewPaint,
    this.currentStrokePoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Draw all completed strokes
    for (var stroke in strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(
          stroke.points[i].offset,
          stroke.points[i + 1].offset,
          stroke.points[i].paint,
        );
      }
    }

    // Draw all lines
    for (var line in lines) {
      canvas.drawLine(line.start, line.end, line.paint);
    }

    // Draw all rectangles
    for (var rect in rectangles) {
      canvas.drawRect(rect.rect, rect.paint);
    }

    // Draw all circles
    for (var circle in circles) {
      canvas.drawCircle(circle.center, circle.radius, circle.paint);
    }

    // Draw current stroke being drawn
    if (currentTool == 'pen' &&
        currentStrokePoints != null &&
        currentStrokePoints!.isNotEmpty) {
      for (int i = 0; i < currentStrokePoints!.length - 1; i++) {
        canvas.drawLine(
          currentStrokePoints![i].offset,
          currentStrokePoints![i + 1].offset,
          currentStrokePoints![i].paint,
        );
      }
    }

    // Draw preview for current tool
    if (previewPaint != null) {
      if (currentTool == 'line' && lineStart != null && currentPoint != null) {
        canvas.drawLine(lineStart!, currentPoint!, previewPaint!);
      } else if (currentTool == 'rectangle' &&
          rectStart != null &&
          currentPoint != null) {
        final rect = Rect.fromPoints(rectStart!, currentPoint!);
        canvas.drawRect(rect, previewPaint!);
      } else if (currentTool == 'circle' &&
          rectStart != null &&
          currentPoint != null) {
        final radius = (currentPoint! - rectStart!).distance;
        canvas.drawCircle(rectStart!, radius, previewPaint!);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return true;
  }
}

/// Drawing canvas widget.
class DrawingCanvas extends StatefulWidget {
  final Function(Uint8List) onImageGenerated;

  const DrawingCanvas({Key? key, required this.onImageGenerated})
    : super(key: key);

  @override
  State<DrawingCanvas> createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  final List<DrawingStroke> strokes = [];
  final List<LineSegment> lines = [];
  final List<RectangleShape> rectangles = [];
  final List<CircleShape> circles = [];
  Size canvasSize = const Size(800, 1000);

  String currentTool = 'pen';
  double strokeWidth = 3.0;
  Offset? currentPoint;
  Offset? lineStart;
  Offset? rectStart;
  List<DrawingPoint>? currentStrokePoints;

  Paint _getPaint() {
    return Paint()
      ..color = Colors.black
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
  }

  void clearCanvas() {
    setState(() {
      strokes.clear();
      lines.clear();
      rectangles.clear();
      circles.clear();
      currentPoint = null;
      lineStart = null;
      rectStart = null;
      currentStrokePoints = null;
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      currentPoint = details.localPosition;
      if (currentTool == 'pen') {
        currentStrokePoints = [
          DrawingPoint(
            offset: details.localPosition,
            paint: _getPaint(),
            toolType: currentTool,
          ),
        ];
      } else if (currentTool == 'line' ||
          currentTool == 'rectangle' ||
          currentTool == 'circle') {
        lineStart = details.localPosition;
        rectStart = details.localPosition;
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      currentPoint = details.localPosition;
      if (currentTool == 'pen') {
        currentStrokePoints?.add(
          DrawingPoint(
            offset: details.localPosition,
            paint: _getPaint(),
            toolType: currentTool,
          ),
        );
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (currentTool == 'pen') {
      if (currentStrokePoints != null && currentStrokePoints!.isNotEmpty) {
        setState(() {
          strokes.add(
            DrawingStroke(points: currentStrokePoints!, toolType: currentTool),
          );
          currentStrokePoints = null;
        });
      }
    } else if (currentTool == 'line' &&
        lineStart != null &&
        currentPoint != null) {
      setState(() {
        lines.add(
          LineSegment(
            start: lineStart!,
            end: currentPoint!,
            paint: _getPaint(),
          ),
        );
        lineStart = null;
      });
    } else if (currentTool == 'rectangle' &&
        rectStart != null &&
        currentPoint != null) {
      setState(() {
        rectangles.add(
          RectangleShape(
            rect: Rect.fromPoints(rectStart!, currentPoint!),
            paint: _getPaint()..style = PaintingStyle.stroke,
          ),
        );
        rectStart = null;
      });
    } else if (currentTool == 'circle' &&
        rectStart != null &&
        currentPoint != null) {
      final radius = (currentPoint! - rectStart!).distance;
      setState(() {
        circles.add(
          CircleShape(
            center: rectStart!,
            radius: radius,
            paint: _getPaint()..style = PaintingStyle.stroke,
          ),
        );
        rectStart = null;
      });
    }
    setState(() {
      currentPoint = null;
    });
  }

  Future<void> _generateImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = canvasSize;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    for (var stroke in strokes) {
      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(
          stroke.points[i].offset,
          stroke.points[i + 1].offset,
          stroke.points[i].paint,
        );
      }
    }

    for (var line in lines) {
      canvas.drawLine(line.start, line.end, line.paint);
    }

    for (var rect in rectangles) {
      canvas.drawRect(rect.rect, rect.paint);
    }

    for (var circle in circles) {
      canvas.drawCircle(circle.center, circle.radius, circle.paint);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    widget.onImageGenerated(pngBytes!.buffer.asUint8List());
  }

  void _undoLastAction() {
    setState(() {
      if (strokes.isNotEmpty) {
        strokes.removeLast();
      } else if (lines.isNotEmpty) {
        lines.removeLast();
      } else if (rectangles.isNotEmpty) {
        rectangles.removeLast();
      } else if (circles.isNotEmpty) {
        circles.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Tool buttons
                ...[
                  ('pen', Icons.edit, 'Pen'),
                  ('line', Icons.show_chart, 'Line'),
                  ('rectangle', Icons.square, 'Rectangle'),
                  ('circle', Icons.circle_outlined, 'Circle'),
                ].map((tool) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton.icon(
                      onPressed: () => setState(() => currentTool = tool.$1),
                      icon: Icon(tool.$2),
                      label: Text(tool.$3),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentTool == tool.$1
                            ? Colors.blue
                            : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 16),
                // Stroke width slider
                Tooltip(
                  message: 'Stroke Width: ${strokeWidth.toStringAsFixed(1)}',
                  child: SizedBox(
                    width: 120,
                    child: Slider(
                      value: strokeWidth,
                      min: 1,
                      max: 10,
                      onChanged: (val) => setState(() => strokeWidth = val),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Undo button
                ElevatedButton.icon(
                  onPressed: _undoLastAction,
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                // Clear button
                ElevatedButton.icon(
                  onPressed: clearCanvas,
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Canvas
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              canvasSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  color: Colors.grey[100],
                  child: CustomPaint(
                    painter: DrawingPainter(
                      strokes: strokes,
                      lines: lines,
                      rectangles: rectangles,
                      circles: circles,
                      currentPoint: currentPoint,
                      currentTool: currentTool,
                      lineStart: lineStart,
                      rectStart: rectStart,
                      currentStrokePoints: currentStrokePoints,
                      previewPaint: currentTool != 'pen' && currentPoint != null
                          ? (_getPaint()..style = PaintingStyle.stroke)
                          : null,
                    ),
                    size: canvasSize,
                  ),
                ),
              );
            },
          ),
        ),
        // Generate image button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _generateImage,
            icon: const Icon(Icons.save),
            label: const Text('Submit Drawing'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
