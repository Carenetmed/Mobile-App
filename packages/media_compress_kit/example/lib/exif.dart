import 'dart:convert';
import 'dart:typed_data';

/// A JPEG EXIF block with a camera make and model, an orientation and a GPS
/// location, as a phone camera writes. Enough for the sample photo, without
/// an image package.
Uint8List addExif(
  Uint8List jpeg, {
  required String make,
  required String model,
  required int orientation,
  required (double, double) location,
}) {
  final tiff = _TiffWriter();
  // IFD0: make, model, orientation and a pointer to the GPS IFD.
  const ifd0 = 8;
  const ifd0Entries = 4;
  const gpsEntries = 4;
  const ifd0Size = 2 + ifd0Entries * 12 + 4;
  const gpsIfd = ifd0 + ifd0Size;
  const gpsSize = 2 + gpsEntries * 12 + 4;
  var data = gpsIfd + gpsSize;

  final makeBytes = ascii.encode('$make\x00');
  final modelBytes = ascii.encode('$model\x00');
  final makeAt = data;
  data += makeBytes.length;
  final modelAt = data;
  data += modelBytes.length;
  final latAt = data;
  data += 24;
  final lonAt = data;
  data += 24;

  tiff
    ..bytes(ascii.encode('II'))
    ..u16(42)
    ..u32(ifd0)
    ..u16(ifd0Entries)
    ..entry(0x010F, 2, makeBytes.length, makeAt)
    ..entry(0x0110, 2, modelBytes.length, modelAt)
    ..entry(0x0112, 3, 1, orientation)
    ..entry(0x8825, 4, 1, gpsIfd)
    ..u32(0)
    ..u16(gpsEntries)
    ..entry(0x0001, 2, 2, ascii.encode(location.$1 < 0 ? 'S' : 'N')[0])
    ..entry(0x0002, 5, 3, latAt)
    ..entry(0x0003, 2, 2, ascii.encode(location.$2 < 0 ? 'W' : 'E')[0])
    ..entry(0x0004, 5, 3, lonAt)
    ..u32(0)
    ..bytes(makeBytes)
    ..bytes(modelBytes)
    ..degrees(location.$1.abs())
    ..degrees(location.$2.abs());

  final payload = [...ascii.encode('Exif\x00\x00'), ...tiff.toBytes()];
  final segment = BytesBuilder()
    ..add([0xFF, 0xE1])
    ..add([(payload.length + 2) >> 8, (payload.length + 2) & 0xFF])
    ..add(payload);
  // Right after the start-of-image marker.
  return (BytesBuilder()
        ..add(jpeg.sublist(0, 2))
        ..add(segment.toBytes())
        ..add(jpeg.sublist(2)))
      .toBytes();
}

class _TiffWriter {
  final _out = BytesBuilder();

  void bytes(List<int> value) => _out.add(value);

  void u16(int value) => _out.add([value & 0xFF, value >> 8]);

  void u32(int value) => _out.add([
    value & 0xFF,
    (value >> 8) & 0xFF,
    (value >> 16) & 0xFF,
    (value >> 24) & 0xFF,
  ]);

  void entry(int tag, int type, int count, int value) {
    u16(tag);
    u16(type);
    u32(count);
    // Short values sit in the first bytes of the 4-byte field.
    u32(value);
  }

  void rational(int numerator, int denominator) {
    u32(numerator);
    u32(denominator);
  }

  void degrees(double value) {
    final degrees = value.floor();
    final minutes = ((value - degrees) * 60).floor();
    final seconds = ((value - degrees) * 60 - minutes) * 60;
    rational(degrees, 1);
    rational(minutes, 1);
    rational((seconds * 100).round(), 100);
  }

  Uint8List toBytes() => _out.toBytes();
}

/// What [readExif] found in a JPEG.
class ExifSummary {
  const ExifSummary({this.make, this.orientation, this.hasLocation = false});

  final String? make;
  final int? orientation;
  final bool hasLocation;
}

/// Reads the make, orientation and whether there is a GPS location from a
/// JPEG's EXIF block. Empty when there is none.
ExifSummary readExif(Uint8List jpeg) {
  final data = ByteData.sublistView(jpeg);
  var at = 2;
  while (at + 4 <= jpeg.length && jpeg[at] == 0xFF) {
    final marker = jpeg[at + 1];
    final length = data.getUint16(at + 2);
    if (marker == 0xE1 &&
        ascii.decode(jpeg.sublist(at + 4, at + 8), allowInvalid: true) ==
            'Exif') {
      return _readTiff(ByteData.sublistView(jpeg, at + 10, at + 2 + length));
    }
    if (marker == 0xDA) break; // Image data starts; no EXIF.
    at += 2 + length;
  }
  return const ExifSummary();
}

ExifSummary _readTiff(ByteData tiff) {
  final endian = tiff.getUint8(0) == 0x49 ? Endian.little : Endian.big;
  int u16(int at) => tiff.getUint16(at, endian);
  int u32(int at) => tiff.getUint32(at, endian);
  String? make;
  int? orientation;
  var hasLocation = false;
  final ifd0 = u32(4);
  final count = u16(ifd0);
  for (var i = 0; i < count; i++) {
    final entry = ifd0 + 2 + i * 12;
    final tag = u16(entry);
    if (tag == 0x010F) {
      final length = u32(entry + 4);
      final offset = length <= 4 ? entry + 8 : u32(entry + 8);
      make = ascii
          .decode(
            tiff.buffer.asUint8List(tiff.offsetInBytes + offset, length),
            allowInvalid: true,
          )
          .replaceAll('\x00', '');
    } else if (tag == 0x0112) {
      orientation = u16(entry + 8);
    } else if (tag == 0x8825) {
      // A location means a latitude in the GPS IFD.
      final gps = u32(entry + 8);
      if (gps > 0 && gps + 2 <= tiff.lengthInBytes) {
        for (var j = 0; j < u16(gps); j++) {
          if (u16(gps + 2 + j * 12) == 0x0002) hasLocation = true;
        }
      }
    }
  }
  return ExifSummary(
    make: make,
    orientation: orientation,
    hasLocation: hasLocation,
  );
}
