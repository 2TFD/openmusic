import 'dart:typed_data';

class Float32VectorCodec {
  const Float32VectorCodec._();

  static Uint8List encode(List<double> vector) {
    if (vector.isEmpty) {
      throw ArgumentError.value(vector, 'vector', 'must not be empty');
    }
    if (vector.any((value) => !value.isFinite)) {
      throw ArgumentError.value(vector, 'vector', 'values must be finite');
    }
    final bytes = Uint8List(vector.length * Float32List.bytesPerElement);
    final data = ByteData.sublistView(bytes);
    for (var index = 0; index < vector.length; index++) {
      final offset = index * Float32List.bytesPerElement;
      data.setFloat32(offset, vector[index], Endian.little);
      if (!data.getFloat32(offset, Endian.little).isFinite) {
        throw ArgumentError.value(
          vector[index],
          'vector[$index]',
          'must be representable as finite Float32',
        );
      }
    }
    return bytes;
  }

  static List<double> decode(Uint8List bytes, {required int dimensions}) {
    if (dimensions <= 0) {
      throw ArgumentError.value(dimensions, 'dimensions', 'must be positive');
    }
    final expectedLength = dimensions * Float32List.bytesPerElement;
    if (bytes.length != expectedLength) {
      throw FormatException(
        'Expected $expectedLength Float32 bytes, got ${bytes.length}',
      );
    }
    final data = ByteData.sublistView(bytes);
    final vector = List<double>.generate(
      dimensions,
      (index) =>
          data.getFloat32(index * Float32List.bytesPerElement, Endian.little),
      growable: false,
    );
    if (vector.any((value) => !value.isFinite)) {
      throw const FormatException('Float32 vector contains non-finite values');
    }
    return vector;
  }
}
