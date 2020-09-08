import 'package:firebase_livestream_ml_vision/ml_kit_flutter.dart';

class BarcodeDetector {
  bool _hasBeenOpened = false;
  bool _isClosed = false;

  Future<bool> startDetection() async {
    assert(!_isClosed);

    _hasBeenOpened = true;

    return await MlKitFlutter.channel.invokeMethod<bool>('BarcodeDetector#start');
  }

  Future<bool> close() async {
    if (!_hasBeenOpened) _isClosed = true;
    if (_isClosed) return Future<bool>.value(true);

    _isClosed = true;
    return await MlKitFlutter.channel.invokeMethod<bool>('BarcodeDetector#close');
  }
}

class Barcode {
  Barcode(dynamic _data)
      : rawValue = _data['value'],
        displayValue = _data['displayValue'];

  static List<Barcode> fromList(List<dynamic> data) {
    return data.map((m) => Barcode(m)).toList();
  }

  final String rawValue;

  final String displayValue;
}
