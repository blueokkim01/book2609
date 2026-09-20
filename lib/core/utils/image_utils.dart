import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../constants/app_constants.dart';

/// 인증 사진 업로드 전 클라이언트 측 전처리(압축·용량 검증) 유틸리티.
///
/// 여기서의 크기 제한은 업로드 실패를 줄이기 위한 사전 검증일 뿐이며,
/// 최종 강제는 항상 `storage.rules`가 담당한다.
class ImageUtils {
  const ImageUtils._();

  /// 이미지를 [AppConstants.imageMaxDimension] 이하로 리사이즈하고
  /// JPEG 품질 [AppConstants.imageCompressQuality]로 압축한다.
  ///
  /// 웹에서는 `flutter_image_compress`의 File API를 사용할 수 없으므로
  /// 원본 바이트를 그대로 반환한다(웹은 브라우저가 이미 합리적인 크기로
  /// 인코딩한 이미지를 넘겨주는 경우가 많음).
  static Future<Uint8List> compress(File file) async {
    if (kIsWeb) {
      return file.readAsBytes();
    }

    final Uint8List? compressed = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: AppConstants.imageMaxDimension,
      minHeight: AppConstants.imageMaxDimension,
      quality: AppConstants.imageCompressQuality,
      keepExif: false,
    );

    return compressed ?? await file.readAsBytes();
  }

  /// 압축 후에도 용량 제한을 초과하는지 확인한다.
  static bool exceedsMaxSize(Uint8List bytes) =>
      bytes.lengthInBytes > AppConstants.maxPhotoSizeBytes;
}
