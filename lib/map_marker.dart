import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarkerPlus {
  static Future<Marker> buildLabelMarker({
    required String label,
    required MarkerId markerId,
    required LatLng position,
    Color backgroundColor = Colors.white,
    BorderSide stroke = const BorderSide(color: Colors.black, width: 5),
    TextStyle textStyle = const TextStyle(fontSize: 38, color: Colors.black, fontWeight: FontWeight.bold),
    VoidCallback? onTap,
    bool consumeTapEvents = true,
    Offset anchor = const Offset(.5, .5),
    double alpha = 1.0,
    double zIndex = 0,
  }) async => Marker(
    markerId: markerId,
    alpha: alpha,
    anchor: anchor,
    consumeTapEvents: consumeTapEvents,
    draggable: false,
    flat: false,
    icon: await _createCustomMarkerBitmap(label, textStyle: textStyle, backgroundColor: backgroundColor, stroke: stroke,),
    infoWindow: InfoWindow.noText,
    position: position,
    rotation: 0,
    visible: true,
    zIndex: zIndex,
    onTap: onTap,
  );

  static Future<BitmapDescriptor> _createCustomMarkerBitmap(
    String title, {
    required TextStyle textStyle,
    required Color backgroundColor,
    required BorderSide stroke,
  }) async {
    TextSpan span = TextSpan(
      text: title,
      style: textStyle,
    );
    TextPainter painter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
    );
    painter.text = TextSpan(
      text: title.toString(),
      style: textStyle,
    );
    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    painter.layout();

    int textHeight = painter.height.toInt();
    double sizeBubble = (textHeight + 18).ceilToDouble();

    var offset = Offset((sizeBubble - painter.width) / 2, (sizeBubble - painter.height) / 2);
    painter.paint(canvas, offset);

    var halfStroke = stroke.width / 2;
    canvas.drawRRect(
        RRect.fromLTRBR(0 + halfStroke, 0 + halfStroke, sizeBubble - halfStroke, sizeBubble - halfStroke, Radius.circular(sizeBubble / 2)),
        Paint()
          ..color = backgroundColor
          ..isAntiAlias = true);
    canvas.drawRRect(
        RRect.fromLTRBR(0 + halfStroke, 0 + halfStroke, sizeBubble - halfStroke, sizeBubble - halfStroke, Radius.circular(sizeBubble / 2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke.width
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true
          ..color = stroke.color);
    painter.layout();
    painter.paint(canvas, offset);
    ui.Picture p = pictureRecorder.endRecording();
    ByteData? pngBytes = await (await p.toImage(
        sizeBubble.toInt(), sizeBubble.toInt()))
        .toByteData(format: ui.ImageByteFormat.png);
    Uint8List data = Uint8List.view(pngBytes!.buffer);
    return BitmapDescriptor.fromBytes(data);
  }
}
