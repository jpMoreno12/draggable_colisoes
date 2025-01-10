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
          widget = atualWidget;
          widget2 = otherWidget;
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

switchPositonWidgetsOnDragUpdate(dynamic atualWidget, dynamic otherWidget, Offset globalPosition) {
  // Coordenadas do widget atual
  final atualLeft = atualWidget['positions'].dx;
  final atualRight = atualLeft + atualWidget['size'].width;
  final atualTop = atualWidget['positions'].dy;
  final atualBottom = atualTop + atualWidget['size'].height;

  // Coordenadas do outro widget
  final otherLeft = otherWidget['positions'].dx;
  final otherRight = otherLeft + otherWidget['size'].width;
  final otherTop = otherWidget['positions'].dy;
  final otherBottom = otherTop + otherWidget['size'].height;

  Offset newOffset = atualWidget['positions'];

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

  // Agora, precisamos garantir que o widget atual não se mova para um "buraco" entre dois widgets.
  bool isValidPosition = false;
  
  // Verificando se a nova posição não está colidindo com outros widgets
  while (!isValidPosition) {
    isValidPosition = true; // Assume que a posição é válida

    for (var widget in value['widgets']) {
      if (widget['id'] != atualWidget['id']) {
        final widgetLeft = widget['positions'].dx;
        final widgetRight = widgetLeft + widget['size'].width;
        final widgetTop = widget['positions'].dy;
        final widgetBottom = widgetTop + widget['size'].height;

        // Verifique a sobreposição horizontal e vertical
        final horizontalOverlap = newOffset.dx + atualWidget['size'].width > widgetLeft &&
                                  newOffset.dx < widgetRight;
        final verticalOverlap = newOffset.dy + atualWidget['size'].height > widgetTop &&
                                newOffset.dy < widgetBottom;

        // Se houver sobreposição, a posição não é válida
        if (horizontalOverlap && verticalOverlap) {
          isValidPosition = false;
          // Ajustar a posição para não sobrepor
          // Você pode tentar uma nova estratégia de ajuste, dependendo do tipo de movimento
          // Exemplo: mover o widget para a borda do outro widget
          if (newOffset.dx < widgetLeft) {
            newOffset = Offset(widgetLeft - atualWidget['size'].width, newOffset.dy);
          } else if (newOffset.dx + atualWidget['size'].width > widgetRight) {
            newOffset = Offset(widgetRight, newOffset.dy);
          } else if (newOffset.dy < widgetTop) {
            newOffset = Offset(newOffset.dx, widgetTop - atualWidget['size'].height);
          } else if (newOffset.dy + atualWidget['size'].height > widgetBottom) {
            newOffset = Offset(newOffset.dx, widgetBottom);
          }
          break;
        }
      }
    }
  }

  // Atualiza a posição do widget atual se for uma posição válida
  atualWidget['positions'] = newOffset;

  notifyListeners();
}



  Widget createFeedbackWidget(Widget widget) {
    return  widget;
  }
}
