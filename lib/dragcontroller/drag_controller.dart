import 'package:flutter/material.dart';

class DragController extends ValueNotifier<Map<String, dynamic>> {
  DragController()
      : super(
          {
            'widgets': [
              {
                'id': 1,
                'positions': const Offset(0, 0),
                'size': const Size(115, 115),
                'colisionColor': Colors.transparent,
              },
              {
                'id': 2,
                'positions': const Offset(400, 0),
                'size': const Size(115, 115),
                'colisionColor': Colors.transparent,
                //sizeWidget :
              },
              {
                'id': 3,
                'positions': const Offset(700, 500),
                'size': const Size(115, 115),
                'colisionColor': Colors.transparent,
              }
            ]
          },
        );

  bool overlap = false;
  bool dragMode = false;
  bool colisionChecked = false;
  late dynamic widget;
  late dynamic widget2;
  late Widget widgetTarget;

  getWidgetTarget(Widget widget) {
    widgetTarget = widget;
  }

  changePositions(Offset positions, int index, int id) {
    dragMode = true;
    final widgets = value['widgets'];
    if (id == widgets[index]['id']) {
      widgets[index]['positions'] = positions;

      // Atualizando o mapa inteiro para garantir que o estado reflita a mudança
      value = {'widgets': widgets};
    }
  }

  checkColision(int id, Offset positions) {
    final widgets = value['widgets'];
    final atualWidget = widgets.firstWhere((widget) => widget['id'] == id);

    for (int i = 0; i < widgets.length; i++) {
      if (widgets[i]['id'] != id) {
        final otherWidget = widgets[i];

        // Coordenadas dos dois widgets
        final atualLeft = atualWidget['positions'].dx;
        final atualRight = atualLeft + atualWidget['size'].width;
        final atualTop = atualWidget['positions'].dy;
        final atualBottom = atualTop + atualWidget['size'].height;

        final otherLeft = otherWidget['positions'].dx;
        final otherRight = otherLeft + otherWidget['size'].width;
        final otherTop = otherWidget['positions'].dy;
        final otherBottom = otherTop + otherWidget['size'].height;

        // Verificar colisão
        final horizontalOverlap = atualRight > otherLeft && atualLeft < otherRight;
        final verticalOverlap = atualBottom > otherTop && atualTop < otherBottom;

        if (horizontalOverlap && verticalOverlap) {
          print('Houve uma colisão entre o widget $id e o widget ${otherWidget['id']}');
          overlap = true;
          colisionChecked = true;
          switchPositonWidgetsOnDragUpdate(atualWidget, otherWidget, positions);

          atualWidget['colisionColor'] = Colors.red.shade100;
          otherWidget['colisionColor'] = Colors.red.shade100;
        } else {
          overlap = false;
          atualWidget['colisionColor'] = Colors.transparent;
          otherWidget['colisionColor'] = Colors.transparent;
        }
      }
    }

    notifyListeners();
  }

  switchPositonWidgetsOnDragUpdate(dynamic atualWidget, dynamic otherWidgets, Offset globalPosition) {
    // Coordenadas do widget atual
    final atualLeft = atualWidget['positions'].dx;
    final atualRight = atualLeft + atualWidget['size'].width;
    final atualTop = atualWidget['positions'].dy;
    final atualBottom = atualTop + atualWidget['size'].height;

    Offset newOffset = atualWidget['positions'];
    bool canMove = true;

    // Coordenadas do outro widget
    final otherLeft = otherWidgets['positions'].dx;
    final otherRight = otherLeft + otherWidgets['size'].width;
    final otherTop = otherWidgets['positions'].dy;
    final otherBottom = otherTop + otherWidgets['size'].height;

    final double overlapLeft = atualRight - otherLeft;
    final double overlapRight = otherRight - atualLeft;
    final double overlapTop = atualBottom - otherTop;
    final double overlapBottom = otherBottom - atualTop;

    final double minOverlap = [
      overlapLeft.abs(),
      overlapRight.abs(),
      overlapTop.abs(),
      overlapBottom.abs(),
    ].reduce((a, b) => a < b ? a : b);

    // Verifica a direção da colisão e ajusta a posição
    if (minOverlap == overlapLeft.abs()) {
      // Colisão no lado esquerdo
      newOffset = Offset(otherLeft - atualWidget['size'].width, atualWidget['positions'].dy);
      print('object');
    } else if (minOverlap == overlapRight.abs()) {
      // Colisão no lado direito
      newOffset = Offset(otherRight, atualWidget['positions'].dy);
    } else if (minOverlap == overlapTop.abs()) {
      // Colisão no topo
      newOffset = Offset(atualWidget['positions'].dx, otherTop - atualWidget['size'].height);
    } else if (minOverlap == overlapBottom.abs()) {
      // Colisão na parte inferior
      newOffset = Offset(atualWidget['positions'].dx, otherBottom);
    }
    atualWidget['positions'] = newOffset;

    notifyListeners();
  }
}

/* 
    /colision logic
    // Distâncias de sobreposição (colisão)
    final double overlapLeft = atualRight - otherLeft;
    final double overlapRight = otherRight - atualLeft;
    final double overlapTop = atualBottom - otherTop;
    final double overlapBottom = otherBottom - atualTop;

    final double minOverlap = [
      overlapLeft.abs(),
      overlapRight.abs(),
      overlapTop.abs(),
      overlapBottom.abs(),
    ].reduce((a, b) => a < b ? a : b);

    // Verifica a direção da colisão e ajusta a posição
    if (minOverlap == overlapLeft.abs()) {
      // Colisão no lado esquerdo
      newOffset = Offset(otherLeft - atualWidget['size'].width, atualWidget['positions'].dy);
    } else if (minOverlap == overlapRight.abs()) {
      // Colisão no lado direito
      newOffset = Offset(otherRight, atualWidget['positions'].dy);
    } else if (minOverlap == overlapTop.abs()) {
      // Colisão no topo
      newOffset = Offset(atualWidget['positions'].dx, otherTop - atualWidget['size'].height);
    } else if (minOverlap == overlapBottom.abs()) {
      // Colisão na parte inferior
      newOffset = Offset(atualWidget['positions'].dx, otherBottom);
    }

    // Atualiza a posição do widget atual se for uma posição válida
    atualWidget['positions'] = newOffset;



 */
