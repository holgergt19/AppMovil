import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

class PaymentViewModel extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  bool _processing = false;
  bool get isProcessing => _processing;

  /// Graba el pago, recibe userId ahora como obligatorio
  Future<void> pay({
    required String rideId,
    required String userId,
    required String method,
    required double amount,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _processing = true;
    notifyListeners();
    try {
      await _db.recordPayment(
        rideId: rideId,
        userId: userId,
        method: method,
        amount: amount,
      );
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      _processing = false;
      notifyListeners();
    }
  }

  /// Monto total cobrado a los pasajeros (ejemplo)
  double get driverEarnings => 0.0;

  /// Comisión de la empresa (ejemplo)
  double get companyEarnings => 0.0;
}
