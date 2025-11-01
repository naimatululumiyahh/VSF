class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  // Hardcoded exchange rates (simulasi)
  final Map<String, double> _exchangeRates = {
    'IDR': 1.0,
    'USD': 15800.0,
    'EUR': 17200.0,
  };

  Future<double> convertFromIDR(int amountIDR, String targetCurrency) async {
    if (targetCurrency == 'IDR') return amountIDR.toDouble();
    
    final rate = _exchangeRates[targetCurrency];
    if (rate == null) return amountIDR.toDouble();
    
    return amountIDR / rate;
  }

  String formatCurrency(double amount, String currency) {
    switch (currency) {
      case 'IDR':
        return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      default:
        return amount.toStringAsFixed(2);
    }
  }

  Map<String, double> getAllConversions(int amountIDR) {
    return {
      'IDR': amountIDR.toDouble(),
      'USD': amountIDR / _exchangeRates['USD']!,
      'EUR': amountIDR / _exchangeRates['EUR']!,
    };
  }
}
