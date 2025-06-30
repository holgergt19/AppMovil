import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingViewModel extends ChangeNotifier {
  bool isSubmitting = false;

  Future<void> submitRating({
    required String rideId,
    required String driverId,
    required int stars,
    String? comment,
    required VoidCallback onSuccess,
    required ValueChanged<String> onError,
  }) async {
    isSubmitting = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance.collection('ratings').add({
        'rideId': rideId,
        'driverId': driverId,
        'stars': stars,
        'comment': comment ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      isSubmitting = false;
      notifyListeners();
      return onError('Error al enviar calificación');
    }

    isSubmitting = false;
    notifyListeners();
    onSuccess();
  }
}
