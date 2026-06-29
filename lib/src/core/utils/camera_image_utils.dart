import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraImageUtils {
  CameraImageUtils._();

  static bool _loggedCameraPlanes = false;

  /// Dispatches to the correct platform converter.
  static InputImage? toInputImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    if (Platform.isAndroid) return toInputImageAndroid(image, camera);
    if (Platform.isIOS) return toInputImageIos(image, camera);
    return null;
  }

  static InputImage? toInputImageAndroid(
    CameraImage image,
    CameraDescription camera,
  ) {
    _logCameraPlanesOnce(image);
    if (image.planes.isEmpty) return null;

    if (image.format.group == ImageFormatGroup.yuv420) {
      if (image.planes.length < 3) return null;
      return _buildInputImage(
        image: image,
        camera: camera,
        bytes: _yuv420ToNv21(image),
        format: InputImageFormat.nv21,
        bytesPerRow: image.width,
      );
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;
    return _buildInputImage(
      image: image,
      camera: camera,
      bytes: _concatenatePlanes(image),
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );
  }

  static InputImage? toInputImageIos(
    CameraImage image,
    CameraDescription camera,
  ) {
    if (image.planes.isEmpty) return null;
    return _buildInputImage(
      image: image,
      camera: camera,
      bytes: _concatenatePlanes(image),
      format: InputImageFormat.bgra8888,
      bytesPerRow: image.planes[0].bytesPerRow,
    );
  }

  static InputImage? _buildInputImage({
    required CameraImage image,
    required CameraDescription camera,
    required Uint8List bytes,
    required InputImageFormat format,
    required int bytesPerRow,
  }) {
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: bytesPerRow,
      ),
    );
  }

  static Uint8List _concatenatePlanes(CameraImage image) {
    final allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  // YUV_420_888 → NV21 per https://github.com/flutter-ml/google_ml_kit_flutter/issues/626
  // (PudovkinSergey), ported from blog.minhazav.dev YUV to NV21 Java approach.
  static Uint8List _yuv420ToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final numPixels = (width * height * 1.5).toInt();
    final nv21 = List<int>.filled(numPixels, 0);

    var idY = 0;
    var idUV = width * height;
    final uvWidth = width ~/ 2;
    final uvHeight = height ~/ 2;

    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;
    final yRowStride = yPlane.bytesPerRow;
    final yPixelStride = yPlane.bytesPerPixel ?? 1;

    for (var y = 0; y < height; y++) {
      final uvOffset = y * uvRowStride;
      final yOffset = y * yRowStride;

      for (var x = 0; x < width; x++) {
        nv21[idY++] = yBuffer[yOffset + x * yPixelStride];

        if (y < uvHeight && x < uvWidth) {
          final bufferIndex = uvOffset + (x * uvPixelStride);
          nv21[idUV++] = vBuffer[bufferIndex];
          nv21[idUV++] = uBuffer[bufferIndex];
        }
      }
    }

    return Uint8List.fromList(nv21);
  }

  static void _logCameraPlanesOnce(CameraImage image) {
    if (!kDebugMode || _loggedCameraPlanes) return;
    _loggedCameraPlanes = true;
    debugPrint(
      'CameraImage format: group=${image.format.group}, raw=${image.format.raw}, '
      'planes=${image.planes.length}',
    );
    debugPrint('Image Format: ${image.format.raw}');
    for (var i = 0; i < image.planes.length; i++) {
      final plane = image.planes[i];
      debugPrint(
        'CameraImage plane[$i]: bytesPerRow=${plane.bytesPerRow}, '
        'bytesPerPixel=${plane.bytesPerPixel}',
      );
    }
  }
}
