import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../../../../features/pdf_reader/presentation/pages/pdf_reader_page.dart';
import '../bloc/annotation_bloc.dart';
import '../bloc/annotation_event.dart';
import '../bloc/annotation_state.dart';
import '../../domain/models/drawing_stroke.dart';
import '../../domain/models/pdf_stamp.dart';

class AnnotationPage extends StatelessWidget {
  const AnnotationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnnotationBloc(),
      child: const AnnotationView(),
    );
  }
}

class AnnotationView extends StatefulWidget {
  const AnnotationView({super.key});

  @override
  State<AnnotationView> createState() => _AnnotationViewState();
}

class _AnnotationViewState extends State<AnnotationView> {
  Uint8List? _pendingStampBytes;

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        context.read<AnnotationBloc>().add(LoadPdfForAnnotation(result.files.single.path!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pendingStampBytes != null ? 'Tap to Place' : 'Annotate PDF'),
        backgroundColor: _pendingStampBytes != null ? Colors.orange[100] : null,
        actions: [
          if (_pendingStampBytes != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _pendingStampBytes = null;
                });
              },
            ),
          BlocBuilder<AnnotationBloc, AnnotationState>(
            builder: (context, state) {
              if (state.pageImages != null && state.pageImages!.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    context.read<AnnotationBloc>().add(const SaveAnnotations());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<AnnotationBloc, AnnotationState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          } else if (state.successMessage != null) {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Success'),
                content: Text(state.successMessage!),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      if (state.pdfPath != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfReaderPage(initialPath: state.pdfPath!),
                          ),
                        );
                      }
                    },
                    child: const Text('Open PDF'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.pageImages != null && state.pageImages!.isNotEmpty) {
            return Column(
              children: [
                _buildToolbar(context, state),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.pageImages!.length,
                    itemBuilder: (context, index) {
                      return PageDrawingView(
                        pageIndex: index,
                        imageBytes: state.pageImages![index],
                        strokes: state.strokes[index] ?? [],
                        stamps: state.stamps[index] ?? [],
                        currentTool: state.currentTool,
                        currentColor: state.currentColor,
                        currentStrokeWidth: state.currentStrokeWidth,
                        isStampMode: _pendingStampBytes != null,
                        onStrokeAdded: (stroke) {
                          context.read<AnnotationBloc>().add(AddStroke(pageIndex: index, stroke: stroke));
                        },
                        onTap: (position) {
                          if (_pendingStampBytes != null) {
                            final stamp = PdfStamp(
                              imageBytes: _pendingStampBytes!,
                              position: position,
                              size: const Size(0.3, 0.1), // Default size, maybe make adjustable later
                            );
                            context.read<AnnotationBloc>().add(AddStamp(pageIndex: index, stamp: stamp));
                            setState(() {
                              _pendingStampBytes = null;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_document, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('Select a PDF to annotate'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _pickFile(context),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Select PDF'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, AnnotationState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[200],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // ... existing tools ...
            IconButton(
              icon: const Icon(Icons.edit),
              color: state.currentTool == AnnotationTool.pen ? Colors.blue : Colors.black,
              onPressed: () => context.read<AnnotationBloc>().add(const SelectTool(AnnotationTool.pen)),
            ),
            IconButton(
              icon: const Icon(Icons.brush),
              color: state.currentTool == AnnotationTool.highlighter ? Colors.blue : Colors.black,
              onPressed: () => context.read<AnnotationBloc>().add(const SelectTool(AnnotationTool.highlighter)),
            ),
            const VerticalDivider(width: 20),
            IconButton(
              icon: const Icon(Icons.draw), // Signature icon
              tooltip: 'Add Signature',
              onPressed: () => _showSignatureDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.approval), // Stamp icon
              tooltip: 'Add Stamp',
              onPressed: () => _showStampMenu(context),
            ),
            const VerticalDivider(width: 20),
            // ... colors ...
            IconButton(
              icon: const Icon(Icons.circle, color: Colors.red),
              onPressed: () => context.read<AnnotationBloc>().add(const UpdateColor(Colors.red)),
            ),
            IconButton(
              icon: const Icon(Icons.circle, color: Colors.blue),
              onPressed: () => context.read<AnnotationBloc>().add(const UpdateColor(Colors.blue)),
            ),
            IconButton(
              icon: const Icon(Icons.circle, color: Colors.black),
              onPressed: () => context.read<AnnotationBloc>().add(const UpdateColor(Colors.black)),
            ),
            const VerticalDivider(width: 20),
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () {
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStampMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Stamp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStampOption(context, 'APPROVED', Colors.green),
                  _buildStampOption(context, 'REJECTED', Colors.red),
                  _buildStampOption(context, 'CONFIDENTIAL', Colors.orange),
                  _buildStampOption(context, 'DRAFT', Colors.grey),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStampOption(BuildContext context, String text, Color color) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        final bytes = await _createStampImage(text, color);
        setState(() {
          _pendingStampBytes = bytes;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<Uint8List> _createStampImage(String text, Color color) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 40, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // Draw border
    final rect = Rect.fromLTWH(0, 0, textPainter.width + 20, textPainter.height + 10);
    canvas.drawRect(rect, paint);
    
    textPainter.paint(canvas, const Offset(10, 5));
    textPainter.dispose();
    
    final picture = recorder.endRecording();
    final img = await picture.toImage(rect.width.toInt(), rect.height.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);
    
    picture.dispose();
    img.dispose();
    
    return byteData!.buffer.asUint8List();
  }

  Future<void> _showSignatureDialog(BuildContext context) async {
    final GlobalKey<SfSignaturePadState> signaturePadKey = GlobalKey();
    
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Draw Signature'),
          content: Container(
            height: 200,
            width: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: SfSignaturePad(
              key: signaturePadKey,
              backgroundColor: Colors.white,
              strokeColor: Colors.black,
              minimumStrokeWidth: 2.0,
              maximumStrokeWidth: 4.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                signaturePadKey.currentState?.clear();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final image = await signaturePadKey.currentState?.toImage(pixelRatio: 3.0);
                if (image != null) {
                  final byteData = await image.toByteData(format: ImageByteFormat.png);
                  if (byteData != null) {
                    setState(() {
                      _pendingStampBytes = byteData.buffer.asUint8List();
                    });
                  }
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Use'),
            ),
          ],
        );
      },
    );
  }
}

class PageDrawingView extends StatefulWidget {
  final int pageIndex;
  final Uint8List imageBytes;
  final List<DrawingStroke> strokes;
  final List<PdfStamp> stamps;
  final AnnotationTool currentTool;
  final Color currentColor;
  final double currentStrokeWidth;
  final bool isStampMode;
  final Function(DrawingStroke) onStrokeAdded;
  final Function(Offset) onTap;

  const PageDrawingView({
    super.key,
    required this.pageIndex,
    required this.imageBytes,
    required this.strokes,
    required this.stamps,
    required this.currentTool,
    required this.currentColor,
    required this.currentStrokeWidth,
    required this.isStampMode,
    required this.onStrokeAdded,
    required this.onTap,
  });

  @override
  State<PageDrawingView> createState() => _PageDrawingViewState();
}

class _PageDrawingViewState extends State<PageDrawingView> {
  List<Offset> _currentPoints = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('Page ${widget.pageIndex + 1}'),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapUp: (details) {
                  if (widget.isStampMode) {
                    final size = context.size!;
                    final normalizedPoint = Offset(
                      details.localPosition.dx / size.width,
                      details.localPosition.dy / size.height,
                    );
                    widget.onTap(normalizedPoint);
                  }
                },
                onPanStart: widget.isStampMode ? null : (details) {
                  setState(() {
                    _currentPoints = [details.localPosition];
                  });
                },
                onPanUpdate: widget.isStampMode ? null : (details) {
                  setState(() {
                    _currentPoints.add(details.localPosition);
                  });
                },
                onPanEnd: widget.isStampMode ? null : (details) {
                  if (_currentPoints.isNotEmpty) {
                    final size = context.size!;
                    // Normalize points
                    final normalizedPoints = _currentPoints.map((p) {
                      return Offset(p.dx / size.width, p.dy / size.height);
                    }).toList();

                    final stroke = DrawingStroke(
                      points: normalizedPoints,
                      color: widget.currentTool == AnnotationTool.highlighter
                          ? widget.currentColor.withValues(alpha: 0.3)
                          : widget.currentColor,
                      width: widget.currentTool == AnnotationTool.highlighter ? 20.0 : widget.currentStrokeWidth,
                    );

                    widget.onStrokeAdded(stroke);
                    setState(() {
                      _currentPoints = [];
                    });
                  }
                },
                child: CustomPaint(
                  foregroundPainter: DrawingPainter(
                    strokes: widget.strokes,
                    currentPoints: _currentPoints,
                    currentColor: widget.currentTool == AnnotationTool.highlighter
                        ? widget.currentColor.withValues(alpha: 0.3)
                        : widget.currentColor,
                    currentWidth: widget.currentTool == AnnotationTool.highlighter ? 20.0 : widget.currentStrokeWidth,
                  ),
                  child: Stack(
                    children: [
                      Image.memory(
                        widget.imageBytes,
                        fit: BoxFit.contain,
                      ),
                      ...widget.stamps.map((stamp) {
                        // We need to know the size of the image to position stamps correctly
                        // But here we are inside a Stack that fits the image?
                        // Actually Image.memory might not fill the width if fit is contain.
                        // But CustomPaint child size is determined by the child.
                        // So the coordinate system is the image size.
                        return Positioned(
                          left: stamp.position.dx * constraints.maxWidth, // This might be wrong if image aspect ratio differs from constraints
                          top: stamp.position.dy * constraints.maxHeight, // We need actual rendered image size
                          width: stamp.size.width * constraints.maxWidth,
                          height: stamp.size.height * constraints.maxHeight,
                          child: Image.memory(stamp.imageBytes, fit: BoxFit.contain),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),
          // ...
        ],
      ),
    );
  }
}


class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final List<Offset> currentPoints;
  final Color currentColor;
  final double currentWidth;

  DrawingPainter({
    required this.strokes,
    required this.currentPoints,
    required this.currentColor,
    required this.currentWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw saved strokes
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length > 1) {
        final path = Path();
        final start = Offset(stroke.points[0].dx * size.width, stroke.points[0].dy * size.height);
        path.moveTo(start.dx, start.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          final p = Offset(stroke.points[i].dx * size.width, stroke.points[i].dy * size.height);
          path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, paint);
      } else if (stroke.points.length == 1) {
        final p = Offset(stroke.points[0].dx * size.width, stroke.points[0].dy * size.height);
        canvas.drawPoints(PointMode.points, [p], paint);
      }
    }

    // Draw current stroke
    if (currentPoints.isNotEmpty) {
      final paint = Paint()
        ..color = currentColor
        ..strokeWidth = currentWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (currentPoints.length > 1) {
        final path = Path();
        path.moveTo(currentPoints[0].dx, currentPoints[0].dy);
        for (int i = 1; i < currentPoints.length; i++) {
          path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
        }
        canvas.drawPath(path, paint);
      } else {
        canvas.drawPoints(PointMode.points, currentPoints, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
