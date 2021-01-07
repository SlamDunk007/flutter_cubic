import 'package:flutter/material.dart';

/// @date:2021/1/5
/// @author:guannan
/// @des:贝塞尔曲线，带圆点

class CubicLineWidget extends StatefulWidget {
  ///
  /// 绘制区域大小
  ///
  Size size;

  ///
  /// 数据集
  ///
  List<CubicBean> cubicBeans;

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
  /// 曲线的宽度
  ///
  double lineWidth;

  ///
  /// 曲线颜色
  ///
  Color lineColor;

  ///
  /// 内圆半径
  ///
  double innerRadius;

  ///
  /// 内圆颜色
  ///
  Color innerColor;

  ///
  /// 外圆半径
  ///
  double outRadius;

  ///
  /// 外圆颜色
  ///
  Color outColor;

  CubicLineWidget(
      {@required this.size,
      @required this.cubicBeans,
      this.isAnimation = true,
      this.isReverse = false,
      this.duration = const Duration(milliseconds: 2000),
      this.lineColor = const Color(0xFFF39266),
      this.lineWidth = 5,
      this.innerRadius = 6,
      this.innerColor = const Color(0xFFE3581E),
      this.outRadius = 10,
      this.outColor = const Color(0xFFFEEDE9)});

  @override
  _CubicLineWidgetState createState() => _CubicLineWidgetState();
}

class _CubicLineWidgetState extends State<CubicLineWidget>
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
    var _painter = CubicLinePainter(
        cubicBeans: widget.cubicBeans,
        animationValue: _value,
        lineColor: widget.lineColor,
        lineWidth: widget.lineWidth ?? 5,
        innerRadius: widget.innerRadius,
        innerColor: widget.innerColor,
        outRadius: widget.outRadius,
        outColor: widget.outColor);

    return CustomPaint(
      size: widget.size,
      painter: _painter,
    );
  }
}

///
/// 动画的实际画笔
///
class CubicLinePainter extends CustomPainter {
  double defaultPadding = 10;
  Path path;

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
  List<CubicBean> cubicBeans;

  ///
  /// 动画值大小
  ///
  double animationValue;

  ///
  /// 曲线的宽度
  ///
  double lineWidth;

  ///
  /// 曲线颜色
  ///
  Color lineColor;

  ///
  /// 内圆半径
  ///
  double innerRadius;

  ///
  /// 内圆颜色
  ///
  Color innerColor;

  ///
  /// 外圆半径
  ///
  double outRadius;

  ///
  /// 外圆颜色
  ///
  Color outColor;

  CubicLinePainter(
      {@required this.cubicBeans,
      this.animationValue,
      @required this.lineColor,
      this.lineWidth,
      this.innerRadius,
      this.innerColor,
      this.outRadius,
      this.outColor});

  @override
  void paint(Canvas canvas, Size size) {
    _initSize(size);
    _drawCubicLine(canvas, size);
  }

  ///曲线或折线
  void _drawCubicLine(Canvas canvas, Size size) {
    if (cubicBeans == null || cubicBeans.length == 0) return;
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..color = lineColor
      ..style = PaintingStyle.stroke;

    if (maxMin[0] <= 0) return;
    var pathMetrics = path.computeMetrics(forceClosed: false);
    var list = pathMetrics.toList();
    var length = animationValue * list.length.toInt();
    Path linePath = new Path();
    for (int i = 0; i < length; i++) {
      var extractPath = list[i].extractPath(0, list[i].length * animationValue,
          startWithMoveTo: true);
      linePath.addPath(extractPath, Offset(0, 0));
    }

    var paintCircle = Paint()
      ..isAntiAlias = true
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..color = this.outColor
      ..style = PaintingStyle.stroke;

    /// 先画阴影再画曲线，目的是防止阴影覆盖曲线
    canvas.drawPath(linePath, paint);

    var metric = linePath.computeMetrics().first;
    final offset = metric.getTangentForOffset(metric.length).position;
    canvas.drawCircle(Offset(startX + _drawWidth * animationValue, offset.dy),
        this.outRadius, paintCircle);
    paintCircle.color = this.innerColor;
    paintCircle.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(startX + _drawWidth * animationValue, offset.dy),
        this.innerRadius, paintCircle);
  }

  @override
  bool shouldRepaint(CubicLinePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }

  ///
  /// 绘制区域相关计算
  ///
  void _initSize(Size size) {
    _initBorder(size);
    _initPath(size);
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
    maxMin = _calculateMaxMin(cubicBeans);
  }

  ///
  /// 绘制的路径初始化计算
  ///
  void _initPath(Size size) {
    if (path == null) {
      if (cubicBeans != null && cubicBeans.length > 0 && maxMin[0] > 0) {
        path = Path();
        double preX, preY, currentX, currentY;
        int length = cubicBeans.length;
        // 两个点之间的x方向距离
        double W = _drawWidth / (length - 1);
        for (int i = 0; i < length; i++) {
          if (i == 0) {
            var key = startX;
            var value = (startY - cubicBeans[i].y / maxMin[0] * _drawHeight);
            path.moveTo(key, value);
            continue;
          }
          currentX = startX + W * i;
          preX = startX + W * (i - 1);

          preY = (startY - cubicBeans[i - 1].y / maxMin[0] * _drawHeight);
          currentY = (startY - cubicBeans[i].y / maxMin[0] * _drawHeight);
          path.cubicTo((preX + currentX) / 2, preY, (preX + currentX) / 2,
              currentY, currentX, currentY);
        }
      }
    }
  }

  ///
  /// 计算极值 最大值,最小值
  ///
  List<double> _calculateMaxMin(List<CubicBean> cubicBeans) {
    if (cubicBeans == null || cubicBeans.length == 0) return [0, 0];
    double max = 0.0, min = 0.0;
    for (CubicBean bean in cubicBeans) {
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

class CubicBean {
  double y;

  CubicBean({@required this.y});
}
