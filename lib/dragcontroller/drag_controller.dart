import 'package:flutter/material.dart';

class DragController extends ValueNotifier<Map<String, dynamic>> {
  DragController()
      : super(
          {
            'widgets': [
              {
                'id': 1,
                'position': const Offset(0, 0),
                'size': const Size(115, 115),
                'colisionColor': Colors.transparent,
              },
              {
                'id': 2,
                'position': const Offset(400, 0),
                'size': const Size(115, 115),
                'colisionColor': Colors.transparent,
              },
              {
                'id': 3,
                'position': const Offset(700, 500),
                'size': const Size(115, 115),
                'colisionColor': Colors.transparent,
              }
            ]
          },
        );

  ValueNotifier<bool> isDragging = ValueNotifier<bool>(false);
  OverlayEntry? _overlayEntry;

  

  bool dragMode = false;
  bool overlap = false;
  bool colision = false;

  late Widget widgetForTarget;
  late int indexForTarget;

  Offset widgetPosition = Offset.zero;

  int counterWidgetsInOverlay = 0;
  Offset positionOverlay = Offset.zero;

  getPositionOverlay(Offset position) {
    positionOverlay = position;
  }

  getWidgetForTarget(Widget widget) {
    widgetForTarget = widget;
  }

  addingWidgetsOnMap(int id, Offset position, Size size) {
    value['widgets'].add({
      'id': id,
      'position': position,
      'size': size,
      'colisionColor': Colors.transparent,
    });
  }

  changePositions(Offset newOffset, int id, int index) {
    dragMode = true;
    final widgets = value['widgets'];

    final atualWidget = widgets[index];

    oldPositions[id] = atualWidget['position'];

    atualWidget['position'] = newOffset;

    if (dragMode == true) {
      checkColision(id, newOffset, index);
    }

    notifyListeners();
  }

  //Widgets em colisao
  Set<int> collidingWidgets = {};
  Map<int, Offset> oldPositions = {}; // Última posição válida dos widgets

  checkColisionOverlay(
    dynamic atualWidget,
  ) {
    int widgetId = atualWidget['id'];

    // Se o widget ainda não tem uma posição antiga armazenada, define a atual como inicial
    oldPositions.putIfAbsent(widgetId, () => atualWidget['position']);

    Map<String, dynamic> overlay = {
      'id': widgetId,
      'position': positionOverlay,
      'size': atualWidget['size'],
    };

    Set<int> newCollidingWidgets = {};
    bool thereWasCollision = false;

    for (var otherWidget in value['widgets']) {
      if (otherWidget['id'] != overlay['id']) {
        final atualLeft = overlay['position'].dx;
        final atualRight = atualLeft + overlay['size'].width;
        final atualTop = overlay['position'].dy;
        final atualBottom = atualTop + overlay['size'].height;

        final otherLeft = otherWidget['position'].dx;
        final otherRight = otherLeft + otherWidget['size'].width;
        final otherTop = otherWidget['position'].dy;
        final otherBottom = otherTop + otherWidget['size'].height;

        final horizontalOverlap = atualRight > otherLeft && atualLeft < otherRight;
        final verticalOverlap = atualBottom > otherTop && atualTop < otherBottom;

        if (horizontalOverlap && verticalOverlap) {
          newCollidingWidgets.add(otherWidget['id']);
          //houve colisao
          thereWasCollision = true;
        }
      }
    }

    collidingWidgets = newCollidingWidgets;
    counterWidgetsInOverlay = collidingWidgets.length;

    print('Número de widgets colidindo: $counterWidgetsInOverlay');

    if (thereWasCollision) {
      // Se houve colisão, volta para a última posição válida
      atualWidget['position'] = oldPositions[widgetId]!;
    } else {
      // Se não houve colisão, atualiza a posição antiga para a posição atual
      oldPositions[widgetId] = positionOverlay;
      atualWidget['position'] = positionOverlay;
    }

    notifyListeners();
  }

  checkColision(int id, Offset positions, int index) {
    final widgets = value['widgets'];
    final atualWidget = widgets[index];

    for (int i = 0; i < widgets.length; i++) {
      if (widgets[i]['id'] != id) {
        final otherWidget = widgets[i];

        // Coordenadas dos dois widgets
        final atualLeft = atualWidget['position'].dx;
        final atualRight = atualLeft + atualWidget['size'].width;
        final atualTop = atualWidget['position'].dy;
        final atualBottom = atualTop + atualWidget['size'].height;

        final otherLeft = otherWidget['position'].dx;
        final otherRight = otherLeft + otherWidget['size'].width;
        final otherTop = otherWidget['position'].dy;
        final otherBottom = otherTop + otherWidget['size'].height;

        // Verificar colisão
        final horizontalOverlap = atualRight > otherLeft && atualLeft < otherRight;
        final verticalOverlap = atualBottom > otherTop && atualTop < otherBottom;

        if (horizontalOverlap && verticalOverlap) {
          overlap = true;
          colision = true;
          // Atualizar posições ou outros estados dos widgets

          checkColisionOverlay(atualWidget);
          dontOverlapsOtherWidgets(atualWidget, otherWidget, positions);
          atualWidget['colisionColor'] = Colors.purple.shade100;
          /* otherWidget['colisionColor'] = Colors.purple.shade100; */
        } else {
          atualWidget['colisionColor'] = Colors.transparent;
          otherWidget['colisionColor'] = Colors.transparent;
        }
        notifyListeners();
      }
    }

    notifyListeners();
  }

  dontOverlapsOtherWidgets(dynamic atualWidget, dynamic otherWidget, Offset globalPosition) {
    // Coordenadas do widget atual
    final atualLeft = atualWidget['position'].dx;
    final atualRight = atualLeft + atualWidget['size'].width;
    final atualTop = atualWidget['position'].dy;
    final atualBottom = atualTop + atualWidget['size'].height;

    Offset newOffset = atualWidget['position'];

    // Coordenadas do outro widget
    final otherLeft = otherWidget['position'].dx;
    final otherRight = otherLeft + otherWidget['size'].width;
    final otherTop = otherWidget['position'].dy;
    final otherBottom = otherTop + otherWidget['size'].height;

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
      newOffset = Offset(otherLeft - atualWidget['size'].width, atualWidget['position'].dy);
      colision = true;
    } else if (minOverlap == overlapRight.abs()) {
      // Colisão no lado direito
      newOffset = Offset(otherRight, atualWidget['position'].dy);
      colision = true;
    } else if (minOverlap == overlapTop.abs()) {
      // Colisão no topo
      newOffset = Offset(atualWidget['position'].dx, otherTop - atualWidget['size'].height);
      colision = true;
    } else if (minOverlap == overlapBottom.abs()) {
      // Colisão na parte inferior
      newOffset = Offset(atualWidget['position'].dx, otherBottom);
      colision = true;
    }

    if (counterWidgetsInOverlay == 0) {
      atualWidget['position'] = newOffset; // Travando a posição no novo valor
    }

    notifyListeners();
  }


 

  void showOverlay(BuildContext context, Widget widget, Offset startPosition) {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: startPosition.dx,
        top: startPosition.dy,
        child: Material(
          color: Colors.transparent,
          child: widgetForTarget,
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void updateOverlayPosition(Offset newPosition, BuildContext context) {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
    }
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: newPosition.dx,
        top: newPosition.dy,
        child: Material(
          color: Colors.transparent,
          child: widgetForTarget,
        ),
      ),
    );

    if (Overlay.of(context).mounted) {
      Overlay.of(context).insert(_overlayEntry!);
      getPositionOverlay(newPosition);
    }
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
