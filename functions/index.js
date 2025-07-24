// functions/index.js

const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");
const {onCall, onRequest} = require("firebase-functions/v2/https");
const {defineSecret} = require("firebase-functions/params");

// Initialize Firebase Admin SDK
initializeApp();
const db = getFirestore();

const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");
const STRIPE_WEBHOOK_SECRET = defineSecret("STRIPE_WEBHOOK_SECRET");

// Import the specific function logic
const {createPaymentIntentLogic} = require("./Stripe/payment");
const {createRefundLogic} = require("./Stripe/refund");
const {handleStripeWebhook} = require("./Stripe/webhook");


/**
 * Cloud Function to create a Stripe Payment Intent.
 */
exports.createPaymentIntent = onCall(
    {secrets: [STRIPE_SECRET_KEY]},
    // **[FIX] Use the correct v2 request object signature**
    async (request) => {
      // In v2, auth info is on request.auth and data is on request.data
      // We pass them to the logic function just like before.
      return createPaymentIntentLogic(
          request.data, // Pass the data from the request
          request,      // Pass the entire request object as the context
          STRIPE_SECRET_KEY.value(),
          db,
          FieldValue);
    },
);

/**
 * Cloud Function to process a Stripe Refund.
 */
exports.createRefund = onCall(
    {secrets: [STRIPE_SECRET_KEY]},
    // **[FIX] Use the correct v2 request object signature**
    async (request) => {
      return createRefundLogic(
          request.data,
          request, // Pass the entire request object as the context
          STRIPE_SECRET_KEY.value(),
          db,
          FieldValue,
      );
    },
);

/**
 * Cloud Function to handle Stripe Webhook events.
 * (This was already correct, no changes needed here)
 */
exports.stripeWebhook = onRequest(
    {secrets: [STRIPE_WEBHOOK_SECRET], raw: true},
    async (req, res) => {
      await handleStripeWebhook(
          req,
          res,
          STRIPE_WEBHOOK_SECRET.value(),
          db,
          FieldValue);
    },
);