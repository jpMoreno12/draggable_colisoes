import 'package:flutter/material.dart';
import 'package:teste_draggable/dragcontroller/drag_controller.dart';
import 'package:teste_draggable/widgets.dart/hit_box_widget.dart';
import 'package:teste_draggable/widgets.dart/target_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GridTeste(),
    );
  }
}

class GridTeste extends StatefulWidget {
  const GridTeste({super.key});

  @override
  State<GridTeste> createState() => _GridTesteState();
}

class _GridTesteState extends State<GridTeste> {
  DragController dragController = DragController();
  bool isDragging = false;
  Offset temporaryWidgetOffset = Offset.zero;
  Offset initialDragOffset = Offset.zero; // Posição inicial do arrasto
  late int indexForTarget;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: dragController,
            builder: (context, value, child) {
              final positionsWidget = value['widgets'];
              return Stack(
                children: [
                  for (int i = 0; i < positionsWidget.length; i++)
                    Positioned(
                      top: positionsWidget[i]['positions'].dy,
                      left: positionsWidget[i]['positions'].dx,
                      child: addingDraggable(
                        Container(
                          color: positionsWidget[i]['id'] == 1
                              ? Colors.red
                              : positionsWidget[i]['id'] == 2
                                  ? Colors.blue
                                  : Colors.green,
                          width: positionsWidget[i]['size'].width,
                          height: positionsWidget[i]['size'].height,
                        ),
                        Offset(
                          positionsWidget[i]['positions'].dx,
                          positionsWidget[i]['positions'].dy,
                        ),
                        Size(
                          positionsWidget[i]['size'].width,
                          positionsWidget[i]['size'].height,
                        ),
                        positionsWidget[i]['id'],
                        i,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  addingDraggable(Widget widget, Offset positions, Size sizes, int id, int index) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          dragController.getWidgetForTarget(widget);
          isDragging = true;
          temporaryWidgetOffset = positions; // Inicia na posição do widget clicado
          initialDragOffset = positions;
          indexForTarget = index;
        });
        _showOverlay(context, widget, temporaryWidgetOffset);
      },
      onPanUpdate: (details) {
        final newOffset = Offset(
          positions.dx + details.delta.dx,
          positions.dy + details.delta.dy,
        );

        dragController.changePositions(newOffset, index, id);
        dragController.mousePointer = temporaryWidgetOffset;

        final distanceMoved = (newOffset - initialDragOffset).distance;

        if (distanceMoved > 0.1) {
          // Ajuste para mover o target mais suavemente
          setState(() {
            temporaryWidgetOffset = Offset(
              temporaryWidgetOffset.dx + details.delta.dx,
              temporaryWidgetOffset.dy + details.delta.dy ,
            );
            _updateOverlayPosition(temporaryWidgetOffset);
          });
        }

        if (dragController.dragMode == true) {
          dragController.checkColision(id, newOffset);
        }
      },
      onPanEnd: (details) {
        setState(() {
          isDragging = false;
        });
        _removeOverlay();
      },
      child: isDragging && indexForTarget == index
          ? Positioned(
            
            child: TargetWidget(
                id: id,
                width: sizes.width,
                height: sizes.height,
              ),
          )
          : HitBoxWidget(
              idHitBox: dragController.value['widgets'][index]['id'],
              alertOverlaps: dragController.value['widgets'][index]['colisionColor'],
              width: sizes.width,
              height: sizes.height,
              child: widget,
            ),
    );
  }

  void _showOverlay(BuildContext context, Widget widget, Offset startPosition) {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: startPosition.dx,
        top: startPosition.dy,
        child: Material(
          color: Colors.red,
          child: widget,
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _updateOverlayPosition(Offset newPosition) {
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: newPosition.dx,
        top: newPosition.dy,
        child: Material(
          color: Colors.transparent,
          child: dragController.widgetForTarget,
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
