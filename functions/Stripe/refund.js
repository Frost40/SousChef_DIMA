// functions/Stripe/refund.js

const Stripe = require("stripe");
const {HttpsError} = require("firebase-functions/v2/https");

/**
 * Logic for creating a Stripe Refund.
 * This is an internal helper function, called
 * by the exported Cloud Function in index.js.
 *
 * @param {object} data - The data sent from the
 * client (e.g., { order_id: 'abc123', amount: 1000 }).
 * @param {object} context - The Cloud Functions
 * callable context (includes auth info).
 * @param {string} stripeSecretKey - The Stripe
 * secret key.
 * @param {object} db - The Firestore database instance.
 * @return {Promise<object>} - A promise that
 * resolves with the refund details.
 * @throws {HttpsError} - Throws an HttpsError on
 * authentication or other failures.
 */
async function createRefundLogic(
    data,
    context,
    stripeSecretKey,
    db,
) {
  // 1. Authentication Check
  if (!context.auth) {
    console.error("Unauthenticated user attempting to create refund.");
    throw new HttpsError(
        "unauthenticated",
        "User is not authenticated. Access denied.",
    );
  }

  const userId = context.auth.uid;
  const stripeInstance = new Stripe(stripeSecretKey);

  try {
    // 2. Input Validation
    if (!data.order_id || typeof data.order_id !== "string") {
      console.error(
          "Missing or invalid order_id for refund:",
          data.order_id,
      );
      throw new HttpsError(
          "invalid-argument",
          "Order ID not provided or not valid.",
      );
    }
    if (typeof data.amount !== "number" ||
        !Number.isInteger(data.amount) ||
        data.amount <= 0
    ) {
      console.error("Invalid amount provided for refund:", data.amount);
      throw new HttpsError(
          "invalid-argument",
          "The refund amount must be a positive integer (in cents).",
      );
    }

    // 3. Fetch the order from Firestore to verify eligibility
    const orderRef = db.collection("orders").doc(data.order_id);
    const orderDoc = await orderRef.get();

    if (!orderDoc.exists) {
      throw new HttpsError("not-found", "Order not found.");
    }

    const orderData = orderDoc.data();

    // 4. Verify the order status is paid
    if (orderData.status !== "paid") {
      throw new HttpsError(
          "failed-precondition",
          `Unable to refund: order status 
          is "${orderData.status}" instead of "paid".`,
      );
    }

    // 5. Verify the refund amount does not exceed the original payment amount
    if (!orderData.total || data.amount > orderData.total) {
      throw new HttpsError(
          "invalid-argument",
          "Refund amount cannot exceed the " +
          "original payment amount.",
      );
    }

    // 6. Create Refund with Stripe using the payment_intent_id from the order
    const refund = await stripeInstance.refunds.create({
      payment_intent: orderData.order_id,
      amount: data.amount,
      metadata: {
        order_id: data.order_id,
        requested_by_user_id: userId,
      },
    });

    console.log(`Refund created for Order ${data.order_id}`);

    return {
      refundId: refund.payment_intent,
      amountRefunded: refund.amount,
    };
  } catch (error) {
    console.error("Error creating refund:", error);
    if (error instanceof HttpsError) {
      throw error;
    }
    if (error.type && error.raw) {
      throw new HttpsError(
          "internal",
          `Stripe API Error: ${error.raw.message ||
          "Unknown error from Stripe."}`,
      );
    }
    throw new HttpsError(
        "internal",
        "An unexpected error occurred during refund creation.",
    );
  }
}

module.exports = {createRefundLogic};
