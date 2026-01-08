// functions/Stripe/cancelPayment.js

const {HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

/**
 * Logic for canceling a payment and reverting order status.
 * This is called when the user cancels the payment sheet on the client side.
 *
 * @param {object} data - The data sent from the client
 * (e.g., { orderIds: ['order1', 'order2'] }).
 * @param {object} context - The Cloud Functions callable context (includes auth info).
 * @param {object} db - The Firestore database instance.
 * @return {Promise<object>} - A promise that resolves with success status.
 * @throws {HttpsError} - Throws an HttpsError on authentication or other failures.
 */
async function cancelPaymentLogic(data, context, db) {
  // 1. Authentication Check
  if (!context.auth) {
    console.error("Unauthenticated user attempting to cancel payment.");
    throw new HttpsError(
        "unauthenticated",
        "User not authenticated. Access denied.",
    );
  }

  const userId = context.auth.uid;

  try {
    // 2. Input Validation
    const orderIds = data.orderIds;

    if (!orderIds || !Array.isArray(orderIds) || orderIds.length === 0) {
      throw new HttpsError("invalid-argument", "No order IDs provided.");
    }

    console.log(
        `Canceling payment for user ${userId}, orders: ${orderIds.join(", ")}`,
    );

    // 3. Use transaction to safely revert order status
    await db.runTransaction(async (transaction) => {
      const orderRefs = orderIds.map((id) => db.collection("orders").doc(id));
      const orderDocs = await Promise.all(
          orderRefs.map((ref) => transaction.get(ref)),
      );

      for (let i = 0; i < orderDocs.length; i++) {
        const orderDoc = orderDocs[i];
        const orderId = orderIds[i];

        if (!orderDoc.exists) {
          console.log(`Order ${orderId} does not exist. Skipping.`);
          continue;
        }

        const orderData = orderDoc.data();

        // Verify order belongs to the user
        if (orderData.user_id !== userId) {
          console.error(`Order ${orderId} does not belong to user ${userId}`);
          throw new HttpsError(
              "permission-denied",
              "You do not have permission to cancel this order's payment.",
          );
        }

        // Only revert if status is 'pending'
        // This prevents reverting already paid or other status orders
        if (orderData.status !== "pending") {
          console.log(
              `Order ${orderId} is not in 'pending' status ` +
              `(current: ${orderData.status}). Skipping.`,
          );
          continue;
        }

        // Revert to ready_for_checkout
        transaction.update(orderRefs[i], {
          status: "ready_for_checkout",
          payment_cancelled_at: admin.firestore.FieldValue.serverTimestamp(),
          payment_intent_id: admin.firestore.FieldValue.delete(),
        });
      }
    });

    console.log(
        `Payment cancelled, orders reverted to 'ready_for_checkout': ` +
        `${orderIds.join(", ")}`,
    );

    return {success: true, orderIds: orderIds};
  } catch (error) {
    console.error("Error cancelling payment:", error);

    if (error instanceof HttpsError) {
      throw error;
    }

    throw new HttpsError(
        "internal",
        "An error occurred while cancelling the payment.",
    );
  }
}

module.exports = {cancelPaymentLogic};

