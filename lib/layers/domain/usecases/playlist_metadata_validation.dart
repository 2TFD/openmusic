typedef ValidatedPlaylistMetadata = ({
  String name,
  String? description,
  String? imageUrl,
});

ValidatedPlaylistMetadata validatePlaylistMetadata({
  required String name,
  String? description,
  String? imageUrl,
}) {
  final normalizedName = name.trim();
  final normalizedDescription = _trimToNull(description);
  final normalizedImageUrl = _trimToNull(imageUrl);

  if (normalizedName.isEmpty || normalizedName.length > 50) {
    throw ArgumentError.value(name, 'name');
  }
  if ((normalizedDescription?.length ?? 0) > 500) {
    throw ArgumentError.value(description, 'description');
  }
  if (normalizedImageUrl != null) {
    final uri = Uri.tryParse(normalizedImageUrl);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        !uri.hasAuthority ||
        uri.host.isEmpty) {
      throw ArgumentError.value(imageUrl, 'imageUrl');
    }
  }

  return (
    name: normalizedName,
    description: normalizedDescription,
    imageUrl: normalizedImageUrl,
  );
}

String? _trimToNull(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
