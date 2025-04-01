import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MapPickerController {
  late Function mapMoving;
  late Function mapFinishedMoving;
  late Function hide, visible;
}

class MapPicker extends StatefulWidget {
  final Widget child;
  final Widget iconWidget;
  final Widget? topWidget;
  final bool showDot;
  final MapPickerController mapPickerController;

  MapPicker(
      {required this.mapPickerController,
      required this.iconWidget,
      this.showDot = true,
      required this.child, this.topWidget});

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  final visibleMapPicker = true.obs;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    widget.mapPickerController.mapMoving = mapMoving;
    widget.mapPickerController.mapFinishedMoving = mapFinishedMoving;
    widget.mapPickerController.hide = hide;
    widget.mapPickerController.visible = visible;
    super.initState();
  }

  void mapMoving() {
    if (!animationController.isCompleted || !animationController.isAnimating) {
      animationController.forward();
    }
  }

  void mapFinishedMoving() {
    animationController.reverse();
  }

  void hide() => visibleMapPicker.value = false;

  void visible() => visibleMapPicker.value = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Obx(() => Visibility(
              visible: visibleMapPicker.value,
              child: AnimatedBuilder(
                  animation: animationController,
                  builder: (context, snapshot) {
                    return Align(
                      alignment: Alignment.center,
                      child: NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (OverscrollIndicatorNotification overscroll) {
                          overscroll.disallowIndicator();
                          return false;
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.showDot)
                                Column(
                                  children: [
                                    Column(
                                      children: [
                                        Transform.translate(
                                          offset: Offset(0, -15 * animationController.value),
                                          child: Column(
                                            children: [
                                              if(widget.topWidget != null)
                                                Column(
                                                  children: [
                                                    widget.topWidget!,
                                                    SizedBox(height: 2 * animationController.value,)
                                                  ],
                                                ),

                                              Transform.scale(
                                                scale: 1 + 0.1 * animationController.value,
                                                child: Column(
                                                  children: [
                                                    widget.iconWidget,
                                                    if (animationController.value == 0)
                                                      Column(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(
                                                                horizontal: 1),
                                                            color:
                                                                const MaterialColor(
                                                              0xFF2196F3,
                                                              <int, Color>{
                                                                50: Color(
                                                                    0xFFD1D1D1),
                                                                100: Color(
                                                                    0xFFBFBFBF),
                                                                200: Color(
                                                                    0xFF808080),
                                                                250: Color(
                                                                    0xFFA6A6A6),
                                                                300: Color(
                                                                    0xFFDBEEF4),
                                                                400: Color(
                                                                    0xFFF1F1F1),
                                                                500: Color(
                                                                    0xFF2196F3),
                                                                600: Color(
                                                                    0xFFD7DAD6)
                                                              },
                                                            )[50],
                                                            child: Container(
                                                              height: 7,
                                                              width: 4,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    else
                                                      const SizedBox(
                                                        height: 7,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 20/(1+animationController.value),
                                          height: 10/(1+animationController.value),
                                          alignment: Alignment.topCenter,
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                            BorderRadius.all(Radius.elliptical(100, 50)),
                                          ),
                                          child: Visibility(
                                            visible: animationController.value == 0,
                                            child: Container(
                                              width: 6,
                                              height: 3,
                                              padding: const EdgeInsets.fromLTRB(1,0,1,1),
                                              decoration: BoxDecoration(
                                                color: const MaterialColor(
                                                  0xFF2196F3,
                                                  <int, Color>{
                                                    50: Color(0xFFD1D1D1),
                                                    100: Color(0xFFBFBFBF),
                                                    200: Color(0xFF808080),
                                                    250: Color(0xFFA6A6A6),
                                                    300: Color(0xFFDBEEF4),
                                                    400: Color(0xFFF1F1F1),
                                                    500: Color(0xFF2196F3),
                                                    600: Color(0xFFD7DAD6)
                                                  },
                                                )[50],
                                                borderRadius: const BorderRadius.only(
                                                  bottomLeft: Radius.circular(60),
                                                  bottomRight: Radius.circular(60),
                                                ),
                                              ),
                                              child: Container(
                                                width: 4,
                                                height: 2,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.only(
                                                    bottomLeft: Radius.circular(60),
                                                    bottomRight: Radius.circular(60),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: Platform.isAndroid ? 110 : 60,
                                    )
                                  ],
                                )
                              else
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    widget.iconWidget,
                                    const SizedBox(
                                      height: 110,
                                    )
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            )),
      ],
    );
  }
}
