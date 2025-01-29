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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: ValueListenableBuilder(
        valueListenable: dragController,
        builder: (context, value, child) {
          final positionsWidget = value['widgets'];
          return Stack(
            children: [ 
              for (int i = 0; i < positionsWidget.length; i++)
                Positioned(
                  top: positionsWidget[i]['position'].dy,
                  left: positionsWidget[i]['position'].dx,
                  child: _addingDraggable(
                    Container(
                      color: positionsWidget[i]['id'] == 1
                          ? Colors.red
                          : positionsWidget[i]['id'] == 2
                              ? Colors.blue
                              : Colors.green,
                      width: positionsWidget[i]['size'].width,
                      height: positionsWidget[i]['size'].height,
                    ),
                    i, 
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  _addingDraggable(Widget widget, int index) {
    
    return ValueListenableBuilder(
        valueListenable: dragController,
        builder: (context, value, child) {
          
          Offset positions = Offset(value['widgets'][index]['position'].dx, value['widgets'][index]['position'].dy);
          Size size = Size(value['widgets'][index]['size'].width, value['widgets'][index]['size'].height);
          int id = value['widgets'][index]['id'];

          return Positioned(
            top: positions.dy,
            left: positions.dx,
            child:  GestureDetector(
              onPanStart: (details) {
                dragController.getWidgetForTarget(widget);
                dragController.isDragging.value = true;

                // Ativa o estado de arrasto
                //overlay inicia-se na mesma posicao do widget

                dragController.widgetPosition = positions;
                dragController.positionOverlay = positions;
                dragController.indexForTarget = index;
                dragController.showOverlay(context, widget, positions);
                dragController.notifyListeners();
              },
              onPanUpdate: (details) {
                dragController.positionOverlay = Offset(
                  dragController.positionOverlay.dx + details.delta.dx,
                  dragController.positionOverlay.dy + details.delta.dy,
                );
                dragController.updateOverlayPosition(dragController.positionOverlay, context);

                dragController.widgetPosition = Offset(dragController.widgetPosition.dx + details.delta.dx, dragController.widgetPosition.dy + details.delta.dy);

                Future.delayed(Duration(milliseconds: 5), () {
                  dragController.changePositions(
                    dragController.widgetPosition,
                    value['widgets'][index]['id'],
                    index,
                  );
                });

                //REAJUSTANDO O WIDGET PARA QUE ELE NAO ULTRAPASSE OS LIMITES DA TELA
                if (dragController.widgetPosition.dx + value['widgets'][index]['size'].width >= MediaQuery.of(context).size.width || dragController.widgetPosition.dx < 0 || dragController.widgetPosition.dy + value['widgets'][index]['size'].height >= MediaQuery.of(context).size.height || dragController.widgetPosition.dy < 0) {
                  double maxX = MediaQuery.of(context).size.width - value['widgets'][index]['size'].width;
                  double maxY = MediaQuery.of(context).size.height - value['widgets'][index]['size'].height;

                  // 🔹 Garante que o widget não ultrapasse os limites da tela
                  dragController.widgetPosition = Offset(
                    dragController.widgetPosition.dx.clamp(0, maxX),
                    dragController.widgetPosition.dy.clamp(0, maxY),
                  );

                  // 🔹 Também ajusta a posição do `positionOverlay` para não sair da tela
                  if (dragController.positionOverlay.dx + value['widgets'][index]['size'].width >= MediaQuery.of(context).size.width || dragController.positionOverlay.dx < 0 || dragController.positionOverlay.dy + value['widgets'][index]['size'].height >= MediaQuery.of(context).size.height || dragController.positionOverlay.dy < 0) {
                    dragController.positionOverlay = Offset(
                      dragController.positionOverlay.dx.clamp(0, maxX),
                      dragController.positionOverlay.dy.clamp(0, maxY),
                    );
                  }
                }

                dragController.notifyListeners();
              },
              onPanEnd: (details) {
                dragController.isDragging.value = false;
                dragController.removeOverlay();
                dragController.notifyListeners();
              },
              child: dragController.isDragging.value && dragController.indexForTarget == index
                  //colocar o widget positioned aqui dentro para fazer o desability do draggable
                  ? TargetWidget(
                      id: id,
                      width: size.width,
                      height: size.height,
                    )
                  : HitBoxWidget(
                      idHitBox: id,
                      alertOverlaps: dragController.value['widgets'][index]['colisionColor'],
                      width: size.width,
                      height: size.height,
                      child: widget,
                    ),
            ),
          );
        });
  }
}
