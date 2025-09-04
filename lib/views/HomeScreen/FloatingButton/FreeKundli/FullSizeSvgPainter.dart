// ignore_for_file: file_names, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';

class FullSizeSvgPainter extends CustomPainter {
  final image;

  FullSizeSvgPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale factors to fit the image within the available size
    final double scaleX = size.width / image.width;
    final double scaleY = size.height / image.height;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    // Scale and center the image
    final double offsetX = (size.width - image.width * scale) / 2;
    final double offsetY = (size.height - image.height * scale) / 2;
    final Offset offset = Offset(offsetX, offsetY);

    // Apply the scaling and draw the image
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale, scale);
    canvas.drawImage(image, Offset.zero, Paint());
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
