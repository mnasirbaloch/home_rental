import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CountDownTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback callback;
  final double? height;
  const CountDownTimer(
      {Key? key,
      required this.seconds,
      required this.height,
      required this.callback})
      : super(key: key);

  @override
  CountDownTimerState createState() => CountDownTimerState();
}

class CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  AnimationController? controller;
  bool isFirst = true;

  String get timerString {
    Duration duration = controller!.duration! * controller!.value;
    if (duration.inMilliseconds <= 0 && !isFirst) {
      Future.microtask(() {
        if (controller!.isAnimating) controller!.stop();

        widget.callback();
      });

      return '';
    }

    isFirst = false;

    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    );

    Future.microtask(() {
      if (controller!.isAnimating) {
        controller!.stop();
      } else {
        controller!
            .reverse(from: controller!.value == 0.0 ? 1.0 : controller!.value);
      }
    });
  }

  @override
  void dispose() {
    if (controller!.isAnimating) controller!.stop();
    controller!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    double fontSize2 = 25.0;
    if (widget.height != null) {
      fontSize2 = widget.height! / 4.5;
    }
    return Container(
      alignment: Alignment.center,
      width: Get.width,
      margin: const EdgeInsets.only(left: 0),
      child: Center(
        child: AnimatedBuilder(
            animation: controller!,
            builder: (context, child) {
              return Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Align(
                            alignment: FractionalOffset.center,
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: CustomTimerPainter(
                                        animation: controller!,
                                        backgroundColor: Get
                                            .theme.colorScheme.secondary
                                            .withOpacity(.2),
                                        color: themeData.indicatorColor,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: FractionalOffset.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        /*Text(
                                          "Remaining",
                                          style: TextStyle(fontSize: fontSize1),
                                        ),*/
                                        Text(
                                          timerString,
                                          style: TextStyle(fontSize: fontSize2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double>? animation;
  final Color? backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor!
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color!;
    double progress = (1.0 - animation!.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  // ignore: avoid_renaming_method_parameters
  bool shouldRepaint(CustomTimerPainter old) {
    return animation!.value != old.animation!.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
