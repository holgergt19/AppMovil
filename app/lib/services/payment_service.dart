class PaymentService {
  /// Simula un pago con tarjeta.
  Future<bool> processCardPayment(double amount) async {
    await Future.delayed(const Duration(seconds: 2));
    return true; // siempre exitoso en esta versión dummy
  }
}
