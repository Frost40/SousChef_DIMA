import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import '../../models/order.dart';

class OrderFirestore {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;

  // Riferimento alla collezione degli ordini
  firestore.CollectionReference get _ordersTable => _firestore.collection('orders');

  // Ottiene un ordine in base all'ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      firestore.DocumentSnapshot doc = await _ordersTable.doc(orderId).get();
      if (doc.exists) {
        return Order.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Errore nel recupero dell\'ordine: $e');
      rethrow;
    }
  }

  // Verifica l'esistenza di un ordine in sospeso per lo stesso ristorante e utente
  Future<Order?> getPendingOrder(String userId, String restaurantId) async {
    try {
      firestore.QuerySnapshot snapshot = await _ordersTable
          .where('user_id', isEqualTo: userId)
          .where('restaurant_id', isEqualTo: restaurantId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Order.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Errore nella ricerca dell\'ordine in sospeso: $e');
      rethrow;
    }
  }

  /// Create a new order in the database
  Future<void> createNewOrder({
    required Order order,
  }) async {
    await _ordersTable.add(order.toFirestore());
  }

  // Ottiene tutti gli ordini di un utente
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      firestore.QuerySnapshot snapshot = await _ordersTable
          .where('user_id', isEqualTo: userId)
          .orderBy('dateTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Errore nel recupero degli ordini dell\'utente: $e');
      rethrow;
    }
  }

  // Aggiorna lo stato di un ordine
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _ordersTable.doc(orderId).update({'status': status});
  }
}