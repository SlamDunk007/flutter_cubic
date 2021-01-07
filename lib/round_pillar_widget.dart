import 'package:flutter/material.dart';

/// @date:2021/1/7
/// @author:guannan
/// @des:带动画圆角状图图
///

class RoundPillarWidget extends StatefulWidget {
  ///
  /// 绘制区域大小
  ///
  Size size;

  ///
  /// 默认边距
  ///
  double defaultPadding;

  ///
  /// 数据集
  ///
  List<PillarBean> pillarBeans;

  ///
  /// 是否有动画
  ///
  bool isAnimation;

  ///
  /// 是否重复执行动画
  ///
  bool isReverse;

  ///
  /// 动画执行时长
  ///
  Duration duration;

  ///
  /// 柱状图个数
  ///
  int pillarCount;

  ///
  /// 柱状图默认颜色
  ///
  Color rectColor;

  ///
  /// 矩形的圆角
  ///
  double rectRadius;

  ///
  /// 以下的四周圆角只有在 rectRadius 为0的时候才生效
  ///
  double rectRadiusTopLeft,
      rectRadiusTopRight,
      rectRadiusBottomLeft,
      rectRadiusBottomRight;

  RoundPillarWidget(
      {@required this.size,
      @required this.pillarBeans,
      this.defaultPadding = 5,
      this.isAnimation = true,
      this.isReverse = false,
      this.duration = const Duration(milliseconds: 2000),
      this.pillarCount = 4,
      this.rectColor,
      this.rectRadius = 0,
      this.rectRadiusTopLeft = 0,
      this.rectRadiusTopRight = 0,
      this.rectRadiusBottomLeft = 0,
      this.rectRadiusBottomRight = 0});

  @override
  _RoundPillarWidgetState createState() => _RoundPillarWidgetState();
}

class _RoundPillarWidgetState extends State<RoundPillarWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  double begin = 0.0, end = 1.0;

  ///
  /// 当前动画值
  ///
  double _value;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimation) {
      _animationController =
          AnimationController(vsync: this, duration: widget.duration);
      Tween(begin: begin, end: end).animate(_animationController)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            if (widget.isReverse) {
              _animationController.repeat(reverse: widget.isReverse);
            }
          }
        })
        ..addListener(() {
          _value = _animationController.value;
          // 更新画笔的动画值，根据动画值计算path长度
          setState(() {});
        });
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    var _painter = PillarPainter(
        pillarBeans: widget.pillarBeans,
        animationValue: _value,
        defaultPadding: widget.defaultPadding,
        rectColor: widget.rectColor,
        pillarCount: widget.pillarCount,
        rectRadius: widget.rectRadius,
        rectRadiusTopLeft: widget.rectRadiusTopLeft,
        rectRadiusTopRight: widget.rectRadiusTopRight,
        rectRadiusBottomLeft: widget.rectRadiusBottomLeft,
        rectRadiusBottomRight: widget.rectRadiusBottomRight);
    return CustomPaint(
      size: widget.size,
      painter: _painter,
    );
  }
}

///
/// 柱状图画笔
///
class PillarPainter extends CustomPainter {
  ///
  /// 默认边距
  ///
  double defaultPadding;

  ///
  /// 绘制的边界
  ///
  double startX, endX, startY, endY;

  ///
  /// 极值
  ///
  List<double> maxMin;

  ///
  /// 实际绘制区域宽高
  ///
  double _drawWidth, _drawHeight;

  ///
  /// 数据集
  ///
  List<PillarBean> pillarBeans;

  ///
  /// 动画值大小
  ///
  double animationValue;

  ///
  /// 柱状图个数
  ///
  int pillarCount;

  ///
  /// 柱状图的宽度
  ///
  double rectWidth;

  ///
  /// 柱状图默认颜色
  ///
  Color rectColor;

  Map<Rect, double> rectMap = new Map();

  ///
  /// 矩形的圆角
  ///
  double rectRadius;

  ///
  /// 以下的四周圆角只有在 rectRadius 为0的时候才生效
  ///
  double rectRadiusTopLeft,
      rectRadiusTopRight,
      rectRadiusBottomLeft,
      rectRadiusBottomRight;

  PillarPainter(
      {@required this.pillarBeans,
      this.animationValue,
      this.defaultPadding,
      this.pillarCount,
      this.rectColor,
      this.rectRadius,
      this.rectRadiusTopLeft,
      this.rectRadiusTopRight,
      this.rectRadiusBottomLeft,
      this.rectRadiusBottomRight});

  @override
  void paint(Canvas canvas, Size size) {
    _initSize(size);
    _drawBar(canvas, size);
  }

  ///
  /// 绘制柱状图
  ///
  void _drawBar(Canvas canvas, Size size) {
    if (pillarBeans == null || pillarBeans.length == 0) return;
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = rectColor
      ..style = PaintingStyle.fill;

    if (maxMin[0] <= 0) return;
    rectMap.clear();
    var length =
        pillarBeans.length > pillarCount ? pillarCount : pillarBeans.length;
    for (int i = 0; i < length; i++) {
      if (pillarBeans[i].color != null) {
        paint.color = pillarBeans[i].color;
      } else {
        paint.color = rectColor;
      }
      double left = startX + defaultPadding * i + rectWidth * i;
      double right = left + rectWidth;
      double currentHeight =
          startY - pillarBeans[i].y / maxMin[0] * _drawHeight * animationValue;
      var rect = Rect.fromLTRB(left, currentHeight, right, startY);
      if (rectRadius != 0) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(rectRadius)), paint);
      } else {
        canvas.drawRRect(
            RRect.fromRectAndCorners(rect,
                topLeft: Radius.circular(rectRadiusTopLeft),
                topRight: Radius.circular(rectRadiusTopRight),
                bottomLeft: Radius.circular(rectRadiusBottomLeft),
                bottomRight: Radius.circular(rectRadiusBottomRight)),
            paint);
      }
      if (!rectMap.containsKey(rect)) rectMap[rect] = pillarBeans[i].y;
    }
  }

  @override
  bool shouldRepaint(PillarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }

  ///
  /// 绘制区域相关计算
  ///
  void _initSize(Size size) {
    _initBorder(size);
  }

  ///
  /// 计算绘制区域的边界
  ///
  void _initBorder(Size size) {
    startX = defaultPadding;
    endX = size.width - defaultPadding;
    endY = defaultPadding;
    startY = size.height - defaultPadding;
    _drawWidth = endX - startX;
    _drawHeight = startY - endY;
    maxMin = _calculateMaxMin(pillarBeans);
    // 计算单个柱状图的宽度
    var maxRectsWidth = _drawWidth - (pillarCount - 1) * defaultPadding;
    rectWidth = maxRectsWidth / pillarCount; //单个柱状图的宽度
  }

  ///
  /// 计算极值 最大值,最小值
  ///
  List<double> _calculateMaxMin(List<PillarBean> pillarBeans) {
    if (pillarBeans == null || pillarBeans.length == 0) return [0, 0];
    double max = 0.0, min = 0.0;
    for (PillarBean bean in pillarBeans) {
      if (max < bean.y) {
        max = bean.y;
      }
      if (min > bean.y) {
        min = bean.y;
      }
    }
    return [max, min];
  }
}

class PillarBean {
  double y;
  Color color;

  PillarBean({@required this.y, this.color});
}
