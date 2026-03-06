import 'package:day_tracker/core/services/image_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageStorageService', () {
    group('allowedExtensions', () {
      test('contains expected image formats', () {
        expect(ImageStorageService.allowedExtensions, contains('.jpg'));
        expect(ImageStorageService.allowedExtensions, contains('.jpeg'));
        expect(ImageStorageService.allowedExtensions, contains('.png'));
        expect(ImageStorageService.allowedExtensions, contains('.gif'));
        expect(ImageStorageService.allowedExtensions, contains('.webp'));
      });

      test('has exactly 5 allowed extensions', () {
        expect(ImageStorageService.allowedExtensions.length, 5);
      });

      test('does not contain executable extensions', () {
        expect(ImageStorageService.allowedExtensions, isNot(contains('.exe')));
        expect(ImageStorageService.allowedExtensions, isNot(contains('.sh')));
        expect(ImageStorageService.allowedExtensions, isNot(contains('.bat')));
        expect(ImageStorageService.allowedExtensions, isNot(contains('.js')));
        expect(ImageStorageService.allowedExtensions, isNot(contains('.html')));
        expect(ImageStorageService.allowedExtensions, isNot(contains('.svg')));
      });

      test('does not contain document extensions', () {
        expect(ImageStorageService.allowedExtensions, isNot(contains('.pdf')));
        expect(ImageStorageService.allowedExtensions, isNot(contains('.doc')));
        expect(ImageStorageService.allowedExtensions, isNot(contains('.txt')));
      });
    });
  });
}
