// functions/index.js

const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {onCall, onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");

// Initialize Firebase Admin SDK
initializeApp();
const db = getFirestore(); // Get Firestore instance once

// Define your secrets using Firebase Secret Manager
// These will be securely loaded at runtime for deployed functions.
// For local emulation, they are also made available if set
// via `firebase functions:secrets:set`.
const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");
const STRIPE_WEBHOOK_SECRET = defineSecret("STRIPE_WEBHOOK_SECRET");

// Import the specific function logic from the subfolder
const {createPaymentIntentLogic} = require("./Stripe/payment");
const {createRefundLogic} = require("./Stripe/refund");
const {handleStripeWebhook} = require("./Stripe/webhook");


/**
 * Cloud Function to create a Stripe Payment Intent.
 * Callable by authenticated clients (e.g., your Flutter app).
 */
exports.createPaymentIntent = onCall(
    // Configure this function to access the Stripe secret key
    {secrets: [STRIPE_SECRET_KEY]},
    async (data, context) => {
      // Pass the secret key and Firestore instance
      // to the logic handler
      return createPaymentIntentLogic(
          data,
          context,
          STRIPE_SECRET_KEY.value(),
          db,
          FieldValue);
    },
);

/**
 * Cloud Function to process a Stripe Refund.
 * Callable by authenticated clients.
 */
exports.createRefund = onCall(
    // Configure this function to access the Stripe secret key
    {secrets: [STRIPE_SECRET_KEY]},
    async (data, context) => {
      // Pass the secret key and Firestore instance to the logic handler
      return createRefundLogic(
          data,
          context,
          STRIPE_SECRET_KEY.value(),
          db,
          FieldValue,
      );
    },
);

/**
 * Cloud Function to handle Stripe Webhook events.
 * Triggered by Stripe, not by clients.
 * It's crucial to set `raw: true` to access the raw request
 * body for signature verification.
 */
exports.stripeWebhook = onRequest(
    // Configure this function to access the Stripe webhook secret
    {secrets: [STRIPE_WEBHOOK_SECRET], raw: true},
    async (req, res) => {
      // Pass the webhook secret and Firestore instance to the logic handler
      await handleStripeWebhook(
          req,
          res,
          STRIPE_WEBHOOK_SECRET.value(),
          db,
          FieldValue);
    },
);
