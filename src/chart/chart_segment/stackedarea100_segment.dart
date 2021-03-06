part of charts;

/// Creates the segments for 100% stacked area series.
///
/// Generates the stacked area100 series points and has the [calculateSegmentPoints] method overrided to customize
/// the stacked area100 segment point calculation.
///
/// Gets the path and color from the [series].
class StackedArea100Segment extends ChartSegment {
  Rect _pathRect;
  Path _path, _strokePath;

  ///Area series.
  XyDataSeries<dynamic, dynamic> series;

  /// Gets the color of the series.
  @override
  Paint getFillPaint() {
    fillPaint = Paint();
    if (series.gradient == null) {
      if (_color != null) {
        fillPaint.color = _color;
        fillPaint.style = PaintingStyle.fill;
      }
    } else {
      fillPaint = (_pathRect != null)
          ? _getLinearGradientPaint(series.gradient, _pathRect,
              seriesRenderer._chart._requireInvertedAxis)
          : fillPaint;
    }
    if (fillPaint.color != null)
      fillPaint.color =
          (series.opacity < 1 && fillPaint.color != Colors.transparent)
              ? fillPaint.color.withOpacity(series.opacity)
              : fillPaint.color;
    _defaultFillColor = fillPaint;
    return fillPaint;
  }

  /// Gets the border color of the series.
  @override
  Paint getStrokePaint() {
    final Paint strokePaint = Paint();
    strokePaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = series.borderWidth;
    if (series.borderGradient != null && _strokePath != null) {
      strokePaint.shader =
          series.borderGradient.createShader(_strokePath.getBounds());
    } else if (_strokeColor != null) {
      strokePaint.color = series.borderColor;
    }
    series.borderWidth == 0
        ? strokePaint.color = Colors.transparent
        : strokePaint.color;
    strokePaint.strokeCap = StrokeCap.round;
    _defaultStrokeColor = strokePaint;
    return strokePaint;
  }

  /// Calculates the rendering bounds of a segment.
  @override
  void calculateSegmentPoints() {}

  /// Draws segment in series bounds.
  @override
  void onPaint(Canvas canvas) {
    if (series.selectionSettings.enable) {
      series.selectionSettings._selectionRenderer._checkWithSelectionState(
          seriesRenderer._segments[0], seriesRenderer._chart);
    }
    _renderStackedAreaSeries(seriesRenderer, fillPaint, strokePaint, canvas,
        _seriesIndex, getFillPaint, _path, _strokePath);
  }
}
