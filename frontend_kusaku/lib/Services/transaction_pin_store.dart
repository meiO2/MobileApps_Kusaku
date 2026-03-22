class TransactionPinStore {
  static String? _pin;

  static String? get pin => _pin;

  static bool get hasPin => _pin != null && _pin!.isNotEmpty;

  static void setPin(String value) {
    _pin = value;
  }
}
