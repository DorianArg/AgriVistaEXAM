import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:image_picker/image_picker.dart';

abstract interface class InterventionPhotoPicker {
  Future<String?> choisirDepuisGalerie();
}

final class ImagePickerInterventionPhotoPicker
    implements InterventionPhotoPicker {
  const ImagePickerInterventionPhotoPicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<String?> choisirDepuisGalerie() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      return image?.path;
    } catch (_) {
      throw const LocalStorageFailure('Impossible d’ouvrir la photothèque.');
    }
  }
}
