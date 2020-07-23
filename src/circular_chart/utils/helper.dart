part of charts;

num _percentToValue(String value, num size) {
  if (value != null) {
    return value.contains('%')
        ? (size / 100) * (num.tryParse(value.replaceAll(RegExp('%'), ''))).abs()
        : (num.tryParse(value))?.abs();
  }
  return null;
}

/// Convert degree to radian
num _degreesToRadians(num deg) => deg * (pi / 180);

Path _getArcPath(num innerRadius, num radius, Offset center, num startAngle,
    num endAngle, num degree, SfCircularChart chart, bool isAnimate) {
  final Path path = Path();
  startAngle = _degreesToRadians(startAngle);
  endAngle = _degreesToRadians(endAngle);
  degree = _degreesToRadians(degree);

  final math.Point<double> innerRadiusStartPoint = math.Point<double>(
      innerRadius * cos(startAngle) + center.dx,
      innerRadius * sin(startAngle) + center.dy);
  final math.Point<double> innerRadiusEndPoint = math.Point<double>(
      innerRadius * cos(endAngle) + center.dx,
      innerRadius * sin(endAngle) + center.dy);

  final math.Point<double> radiusStartPoint = math.Point<double>(
      radius * cos(startAngle) + center.dx,
      radius * sin(startAngle) + center.dy);

  if (isAnimate) {
    path.moveTo(innerRadiusStartPoint.x, innerRadiusStartPoint.y);
  }

  final bool isFullCircle =
      startAngle != null && endAngle != null && endAngle - startAngle == 2 * pi;

  final num midpointAngle = (endAngle + startAngle) / 2;

  path.lineTo(radiusStartPoint.x, radiusStartPoint.y);

  if (isFullCircle) {
    path.arcTo(Rect.fromCircle(center: center, radius: radius), startAngle,
        midpointAngle - startAngle, true);
    path.arcTo(Rect.fromCircle(center: center, radius: radius), midpointAngle,
        endAngle - midpointAngle, true);
  } else {
    path.arcTo(Rect.fromCircle(center: center, radius: radius), startAngle,
        degree, true);
  }

  path.lineTo(innerRadiusEndPoint.x, innerRadiusEndPoint.y);

  if (isFullCircle) {
    path.arcTo(Rect.fromCircle(center: center, radius: innerRadius), endAngle,
        midpointAngle - endAngle, true);
    path.arcTo(Rect.fromCircle(center: center, radius: innerRadius),
        midpointAngle, startAngle - midpointAngle, true);
  } else {
    path.arcTo(Rect.fromCircle(center: center, radius: innerRadius), endAngle,
        startAngle - endAngle, true);
  }

  path.lineTo(radiusStartPoint.x, radiusStartPoint.y);

  return path;
}

ChartPoint<dynamic> _getCircularPoint(
    CircularSeriesRenderer seriesRenderer, int pointIndex) {
  final CircularSeries<dynamic, dynamic> series = seriesRenderer._series;
  ChartPoint<dynamic> currentPoint;
  final dynamic xMap = series.xValueMapper;
  final dynamic yMap = series.yValueMapper;
  final dynamic sortFieldMap = series.sortFieldValueMapper;
  final dynamic radiusMap = series.pointRadiusMapper;
  final dynamic colorMap = series.pointColorMapper;
  dynamic xVal, yVal, radiusVal, colorVal, sortVal;
  if (xMap != null) {
    xVal = xMap(pointIndex);
  }

  if (xVal != null) {
    if (yMap != null) {
      yVal = yMap(pointIndex);
    }

    if (radiusMap != null) {
      radiusVal = radiusMap(pointIndex);
    }

    if (colorMap != null) {
      colorVal = colorMap(pointIndex);
    }

    if (sortFieldMap != null) {
      sortVal = sortFieldMap(pointIndex);
    }

    currentPoint =
        ChartPoint<dynamic>(xVal, yVal, radiusVal, colorVal, sortVal);
  }

  return currentPoint;
}

Path _getRoundedCornerArcPath(num innerRadius, num outerRadius, Offset center,
    num startAngle, num endAngle, num degree, CornerStyle cornerStyle) {
  final Path path = Path();

  Offset _midPoint;
  num midStartAngle, midEndAngle;
  if (cornerStyle == CornerStyle.startCurve ||
      cornerStyle == CornerStyle.bothCurve) {
    _midPoint =
        _degreeToPoint(startAngle, (innerRadius + outerRadius) / 2, center);

    midStartAngle = _degreesToRadians(180);

    midEndAngle = midStartAngle + _degreesToRadians(180);

    path.addArc(
        Rect.fromCircle(
            center: _midPoint, radius: (innerRadius - outerRadius).abs() / 2),
        midStartAngle,
        midEndAngle);
  }

  path.addArc(Rect.fromCircle(center: center, radius: outerRadius),
      _degreesToRadians(startAngle), _degreesToRadians(endAngle - startAngle));

  if (cornerStyle == CornerStyle.endCurve ||
      cornerStyle == CornerStyle.bothCurve) {
    _midPoint =
        _degreeToPoint(endAngle, (innerRadius + outerRadius) / 2, center);

    midStartAngle = _degreesToRadians(endAngle / 2);

    midEndAngle = midStartAngle + _degreesToRadians(180);

    path.arcTo(
        Rect.fromCircle(
            center: _midPoint, radius: (innerRadius - outerRadius).abs() / 2),
        midStartAngle,
        midEndAngle,
        false);
  }

  path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      _degreesToRadians(endAngle),
      _degreesToRadians(startAngle) - _degreesToRadians(endAngle),
      false);

  return path;
}

_Region _getPointRegion(SfCircularChart chart, Offset position,
    CircularSeriesRenderer seriesRenderer) {
  _Region pointRegion;
  const num chartStartAngle = -.5 * pi;
  // for (int i = 0; i < chart._chartSeries.visibleSeriesRenderers.length; i++) {
  // final CircularSeriesRenderer seriesRenderer =
  //     chart._chartSeries.visibleSeriesRenderers[i];
  for (_Region region in seriesRenderer._pointRegions) {
    final num fromCenterX = position.dx - region.center.dx;
    final num fromCenterY = position.dy - region.center.dy;
    num tapAngle =
        (atan2(fromCenterY, fromCenterX) - chartStartAngle) % (2 * pi);
    num pointStartAngle = region.start - _degreesToRadians(-90);
    num pointEndAngle = region.end - _degreesToRadians(-90);
    if (((region.endAngle + 90) > 360) && (region.startAngle + 90) > 360) {
      pointEndAngle = _degreesToRadians((region.endAngle + 90) % 360);
      pointStartAngle = _degreesToRadians((region.startAngle + 90) % 360);
    } else if ((region.endAngle + 90) > 360) {
      tapAngle = tapAngle > pointStartAngle ? tapAngle : 2 * pi + tapAngle;
    }
    if (tapAngle >= pointStartAngle && tapAngle <= pointEndAngle) {
      final num distanceFromCenter =
          sqrt(pow(fromCenterX.abs(), 2) + pow(fromCenterY.abs(), 2));
      if (distanceFromCenter <= region.outerRadius &&
          distanceFromCenter >= region.innerRadius) {
        pointRegion = region;
      }
    }
  }
  // }
  return pointRegion;
}

// Draw the path
void _drawPath(Canvas canvas, _StyleOptions style, Path path) {
  final Paint paint = Paint();
  if (style.fill != null) {
    paint.color = style.fill == Colors.transparent
        ? style.fill
        : style.fill.withOpacity(style.opacity ?? 1);
    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }
  if (style.strokeColor != null &&
      style.strokeWidth != null &&
      style.strokeWidth > 0) {
    paint.color = style.strokeColor;
    paint.strokeWidth = style.strokeWidth;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
  }
}

Offset _degreeToPoint(num degree, num radius, Offset center) {
  degree = _degreesToRadians(degree);
  return Offset(
      center.dx + cos(degree) * radius, center.dy + sin(degree) * radius);
}

void _needsRepaintCircularChart(
    SfCircularChart chart, SfCircularChart oldChart) {
  if (chart.series.length == oldChart.series.length &&
      chart.series[0] == oldChart.series[0]) {
    for (int seriesIndex = 0;
        seriesIndex < chart.series.length;
        seriesIndex++) {
      _canRepaintSeries(chart, oldChart, seriesIndex);
    }
  } else {
    // ignore: avoid_function_literals_in_foreach_calls
    chart._chartSeries.visibleSeriesRenderers.forEach(
        (CircularSeriesRenderer seriesRenderer) =>
            seriesRenderer._needsRepaint = true);
  }
}

void _canRepaintSeries(
    SfCircularChart chart, SfCircularChart oldChart, int seriesIndex) {
  final CircularSeriesRenderer seriesRenderer =
      chart._chartSeries.visibleSeriesRenderers[0];
  final CircularSeriesRenderer oldWidgetSeriesRenderer =
      oldChart._chartSeries.visibleSeriesRenderers[seriesIndex];
  final CircularSeries<dynamic, dynamic> series = chart.series[0];
  final CircularSeries<dynamic, dynamic> oldWidgetSeries =
      oldWidgetSeriesRenderer._series;
  if (seriesRenderer._center?.dy != oldWidgetSeriesRenderer._center?.dy ||
      seriesRenderer._center?.dx != oldWidgetSeriesRenderer._center?.dx ||
      series.borderWidth != oldWidgetSeries.borderWidth ||
      series.name != oldWidgetSeries.name ||
      series.borderColor?.value != oldWidgetSeries.borderColor?.value ||
      seriesRenderer._currentInnerRadius !=
          oldWidgetSeriesRenderer._currentInnerRadius ||
      seriesRenderer._currentRadius != oldWidgetSeriesRenderer._currentRadius ||
      seriesRenderer._start != oldWidgetSeriesRenderer._start ||
      seriesRenderer._totalAngle != oldWidgetSeriesRenderer._totalAngle ||
      seriesRenderer._dataPoints?.length !=
          oldWidgetSeriesRenderer._dataPoints?.length ||
      series.emptyPointSettings.borderWidth !=
          oldWidgetSeries.emptyPointSettings.borderWidth ||
      series.emptyPointSettings.borderColor?.value !=
          oldWidgetSeries.emptyPointSettings.borderColor?.value ||
      series.emptyPointSettings.color?.value !=
          oldWidgetSeries.emptyPointSettings.color?.value ||
      series.emptyPointSettings.mode !=
          oldWidgetSeries.emptyPointSettings.mode ||
      series.dataSource?.length != oldWidgetSeries.dataSource?.length ||
      series.dataLabelSettings.isVisible !=
          oldWidgetSeries.dataLabelSettings.isVisible ||
      series.dataLabelSettings.color?.value !=
          oldWidgetSeries.dataLabelSettings.color?.value ||
      series.dataLabelSettings.borderRadius !=
          oldWidgetSeries.dataLabelSettings.borderRadius ||
      series.dataLabelSettings.borderWidth !=
          oldWidgetSeries.dataLabelSettings.borderWidth ||
      series.dataLabelSettings.borderColor?.value !=
          oldWidgetSeries.dataLabelSettings.borderColor?.value ||
      series.dataLabelSettings.textStyle?.color?.value !=
          oldWidgetSeries.dataLabelSettings.textStyle?.color?.value ||
      series.dataLabelSettings.textStyle?.fontWeight !=
          oldWidgetSeries.dataLabelSettings.textStyle?.fontWeight ||
      series.dataLabelSettings.textStyle?.fontSize !=
          oldWidgetSeries.dataLabelSettings.textStyle?.fontSize ||
      series.dataLabelSettings.textStyle?.fontFamily !=
          oldWidgetSeries.dataLabelSettings.textStyle?.fontFamily ||
      series.dataLabelSettings.textStyle?.fontStyle !=
          oldWidgetSeries.dataLabelSettings.textStyle?.fontStyle ||
      series.dataLabelSettings.labelIntersectAction !=
          oldWidgetSeries.dataLabelSettings.labelIntersectAction ||
      series.dataLabelSettings.labelPosition !=
          oldWidgetSeries.dataLabelSettings.labelPosition ||
      series.dataLabelSettings.connectorLineSettings.color?.value !=
          oldWidgetSeries
              .dataLabelSettings.connectorLineSettings.color?.value ||
      series.dataLabelSettings.connectorLineSettings.width !=
          oldWidgetSeries.dataLabelSettings.connectorLineSettings.width ||
      series.dataLabelSettings.connectorLineSettings.length !=
          oldWidgetSeries.dataLabelSettings.connectorLineSettings.length ||
      series.dataLabelSettings.connectorLineSettings.type !=
          oldWidgetSeries.dataLabelSettings.connectorLineSettings.type ||
      series.xValueMapper != oldWidgetSeries.xValueMapper ||
      series.yValueMapper != oldWidgetSeries.yValueMapper ||
      series.enableTooltip != oldWidgetSeries.enableTooltip) {
    seriesRenderer._needsRepaint = true;
  } else {
    seriesRenderer._needsRepaint = false;
  }
}

num _findAngleDeviation(num innerRadius, num outerRadius, num totalAngle) {
  final num calcRadius = (innerRadius + outerRadius) / 2;

  final num circumference = 2 * pi * calcRadius;

  final num rimSize = (innerRadius - outerRadius).abs();

  final num deviation = ((rimSize / 2) / circumference) * 100;

  return (deviation * 360) / 100;
}
