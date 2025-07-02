// functions/Stripe/payment.js

const Stripe = require("stripe");
const {HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

/**
 * Logic for creating a Stripe Payment Intent.
 * This is an internal helper function, called by the
 * exported Cloud Function in index.js.
 *
 * @param {object} data - The data sent from the client
 * (e.g., { amount: 1000, currency: 'eur', items: [...] }).
 * @param {object} context - The Cloud Functions
 * callable context (includes auth info).
 * @param {string} stripeSecretKey - The Stripe secret key.
 * @param {object} db - The Firestore database instance.
 * @param {object} FieldValue - Firebase Firestore
 * FieldValue for server timestamps.
 * @return {Promise<object>} - A promise that resolves
 * with the client secret and order ID.
 * @throws {HttpsError} - Throws an HttpsError on
 * authentication or other failures.
 */
async function createPaymentIntentLogic(
    data,
    context,
    stripeSecretKey,
    db,
    FieldValue,
) {
  // 1. Authentication Check
  if (!context.auth) {
    console.error("Unauthenticated user attempting to create payment intent.");
    throw new HttpsError(
        "unauthenticated",
        "User not authenticated. Access denied.",
    );
  }

  const userId = context.auth.uid;
  const stripeInstance = new Stripe(stripeSecretKey);

  try {
    // 2. Input Validation
    if (typeof data.amount !== "number" ||
        !Number.isInteger(data.amount) ||
        data.amount <= 0) {
      console.error("Invalid amount provided:", data.amount);
      throw new HttpsError(
          "invalid-argument",
          "Amount must be a positive integer" +
          " (in cents/smallest currency unit).");
    }
    if (!data.currency) {
      data.currency = "eur"; // Default currency if not provided
    }
    if (typeof data.currency !== "string" || data.currency.length !== 3) {
      console.error("Invalid currency provided:", data.currency);
      throw new HttpsError(
          "invalid-argument",
          "Currency must be a 3-letter ISO 4217 " +
          "code (e.g., \"eur\", \"usd\").");
    }

    // 3. Retrieve and veryfing Order IDs from the provided items
    console.log(`Verifying orders for user ${userId}: ${orderIds.join(", ")}`);

    const orderIds = data.items.map((item) => item.id);

    if (!orderIds || orderIds.length === 0) {
      throw new HttpsError("invalid-argument", "No order IDs provided.");
    }

    // Query Firestore for the requested orders
    const ordersQuery = await db.collection("orders")
        .where(admin.firestore.FieldPath.documentId(), "in", orderIds)
        .get();

    // Check if all orders exist
    if (ordersQuery.size !== orderIds.length) {
      console.error(
          `Order count mismatch: requested 
          ${orderIds.length}, found ${ordersQuery.size}`,
      );
      throw new HttpsError(
          "not-found",
          "One or more specified orders do not exist");
    }

    // Validate order ownership and status
    let totalFromDB = 0;
    const validOrderIds = [];

    ordersQuery.forEach((doc) => {
      const order = doc.data();

      // Check if order belongs to the requesting user
      if (order.user_id !== userId) {
        console.error(`Order ${doc.id} does not belong to user ${userId}`);
        throw new HttpsError(
            "permission-denied",
            "You do not have permission to pay for " +
            "one or more of these orders");
      }

      // Check if order is in 'pending' status
      if (order.status !== "pending") {
        console.error(`Order ${doc.id} is not in 
        pending state, but ${order.status}`);
        throw new HttpsError(
            "failed-precondition",
            "One or more orders are not in \"pending\" state");
      }

      // Sum up total amount for verification
      totalFromDB += Math.round(order.total * 100); // Convert to cents
      validOrderIds.push(doc.id);
    });

    // Verify total amount matches (allow small rounding differences)
    if (Math.abs(totalFromDB - data.amount) > 1) {
      console.error(
          `Amount discrepancy: requested 
          ${data.amount}, calculated ${totalFromDB}`,
      );
      throw new HttpsError(
          "invalid-argument",
          "Total amount does not match the sum of orders");
    }

    // 4. Create Payment Intent with Stripe
    const paymentIntent = await stripeInstance.paymentIntents.create({
      amount: data.amount,
      currency: data.currency,
      metadata: {
        orders_id: validOrderIds.join(","), // Use verified order IDs
        user_id: userId,
      },
    });

    console.log(
        `Payment Intent created for orders: 
        ${validOrderIds.join(", ")} - ${paymentIntent.id}`,
    );

    // Return client secret to the client
    return {
      clientSecret: paymentIntent.client_secret,
      orderIds: validOrderIds,
    };
  } catch (error) {
    // Log the full error for debugging
    console.error("Errore nella creazione del payment intent:", error);

    // Re-throw as an HttpsError with a user-friendly message
    if (error instanceof HttpsError) {
      throw error; // Re-throw if it's already an HttpsError
    }
    // For Stripe API errors, extract the message
    if (error.type && error.raw) {
      throw new HttpsError(
          "internal",
          `Stripe API Error: ${error.raw.message ||
          "Errore sconosciuto da Stripe."}`);
    }
    throw new HttpsError(
        "internal",
        "Si è verificato un errore inaspettato " +
        "durante la creazione del pagamento.");
  }
}

module.exports = {createPaymentIntentLogic};
