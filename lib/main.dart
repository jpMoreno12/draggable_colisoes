import 'package:flutter/material.dart';
import 'package:teste_draggable/dragcontroller/drag_controller.dart';
import 'package:teste_draggable/widgets.dart/hit_box_widget.dart';

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
          for (int i = 0; i < dragController.value['widgets'].length; i++)

            //Nota: O widget target nao precisa passar por cima de outro widget pois o widget que vai passar por cima de outro
            // e o widget que esta debaixo do mouse
            if (isDragging)
              Positioned(
                top: temporaryWidgetOffset.dy,
                left: temporaryWidgetOffset.dx,
                child: Container(
                  width: dragController.value['widgets'][indexForTarget]['size'].width,
                  height: dragController.value['widgets'][indexForTarget]['size'].height,
                  color: Colors.red.withOpacity(0.5),
                ),
              ),
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
                          width: 100,
                          height: 100,
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
          isDragging = true;
          temporaryWidgetOffset = positions; // Inicia na posição do widget clicado
          initialDragOffset = positions;
          indexForTarget = index;
        });
      },
      onPanUpdate: (details) {
        final newOffset = Offset(
          positions.dx + details.delta.dx,
          positions.dy + details.delta.dy,
        );

        dragController.changePositions(newOffset, index, id);

        final distanceMoved = (newOffset - initialDragOffset).distance;

        if (distanceMoved > 50) {
          setState(() {
            temporaryWidgetOffset = newOffset;
            initialDragOffset = newOffset;
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
      },
      child: HitBoxWidget(
        idHitBox: dragController.value['widgets'][index]['id'],
        alertOverlaps: dragController.value['widgets'][index]['colisionColor'],
        width: dragController.value['widgets'][index]['size'].width,
        height: dragController.value['widgets'][index]['size'].height,
        child: widget,
      ),
    );
  }
}
