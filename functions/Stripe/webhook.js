// functions/Stripe/webhook.js

const Stripe = require("stripe");

/**
 * Logic for handling Stripe Webhook events.
 * This is an internal helper function, called by the exported Cloud Function in index.js.
 * It's designed to be a single endpoint for ALL Stripe events.
 *
 * @param {object} req - The Express request object from the HTTP trigger.
 * @param {object} res - The Express response object.
 * @param {string} stripeWebhookSecret - The Stripe webhook signing secret.
 * @param {object} db - The Firestore database instance.
 */
async function handleStripeWebhook(req, res, stripeWebhookSecret, db) {
    const signature = req.headers["stripe-signature"];
    let event;

    try {
        // Verify webhook signature to ensure the event is from Stripe and not tampered with
        event = new Stripe(stripeWebhookSecret).webhooks.constructEvent(
            req.rawBody,
            signature,
            stripeWebhookSecret
        );
    } catch (err) {
        console.error("Webhook signature verification failed:", err.message);
        // Return 400 immediately if signature verification fails
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Log the event type for debugging (useful for unhandled events)
    console.log(`Received Stripe event type: ${event.type}, ID: ${event.id}`);

    try {
        // Handle different event types
        switch (event.type) {
            case "payment_intent.succeeded": {
                const paymentIntent = event.data.object;
                const orderIdsString = paymentIntent.metadata && paymentIntent.metadata.orders_id;

                if (!orderIdsString) {
                    console.warn(
                        `Webhook: payment_intent.succeeded event ${event.id} missing orders_id in metadata.`
                    );
                    return res.json({ received: true });
                }
                const orderIds = orderIdsString.split(","); // Split into an array

                const batch = db.batch();
                for (const orderId of orderIds) {
                    const orderRef = db.collection("orders").doc(orderId);
                    // Fetch and check current status for idempotency for EACH order
                    const orderDoc = await orderRef.get(); // Or fetch all first in a single query
                    if (!orderDoc.exists ||
                        orderDoc.data().status === "paid" ||
                        orderDoc.data().status === "refunded") {
                        console.log(`Webhook: Order ${orderId} already processed or invalid status. Skipping.`);
                        continue; // Skip this specific order in the loop
                    }

                    batch.update(orderRef, {
                        status: "paid",
                        // payment_id: paymentIntent.id, // Link to the single Payment Intent
                        // payment_date: FieldValue.serverTimestamp(),
                        // Update any other relevant fields
                    });
                }
                await batch.commit(); // Commit all updates in one go

                console.log(
                    `Webhook: Status updated to 'paid' for orders: ${orderIds.join(", ")} for PI ${paymentIntent.id}`
                );
                break;
            }

            case "payment_intent.payment_failed": {
                const paymentIntent = event.data.object;
                const orderIdsString = paymentIntent.metadata && paymentIntent.metadata.orders_id;

                if (!orderIdsString) {
                    console.warn(
                        `Webhook: payment_intent.payment_failed event ${event.id}
                         missing orders_id in metadata. Skipping.`
                    );
                    return res.json({ received: true });
                }

                const orderIds = orderIdsString.split(",");
                const batch = db.batch();

                for (const orderId of orderIds) {
                    const orderRef = db.collection("orders").doc(orderId);
                    // You could add an idempotency check here if needed,
                    // e.g., check if the status is already 'ready_for_checkout'.
                    batch.update(orderRef, {
                        status: "ready_for_checkout", // Revert status to allow another payment attempt
                    });
                }

                await batch.commit();
                console.log(
                    `Webhook: Status updated to 'ready_for_checkout' for orders: ${orderIds.join(", ")}
                     for failed PI ${paymentIntent.id}`
                );
                break;
            }
        }

        // Crucially, send a 200 OK response to Stripe to acknowledge receipt.
        // This tells Stripe the event was delivered successfully, and it doesn't need to retry.
        res.json({ received: true });

    } catch (error) {
        console.error(
            `Error processing Stripe webhook event ${event ? event.id : "unknown"} 
            (type: ${event ? event.type : "unknown"}):`,
            error
        );
        // Even if there's an error in your processing logic (e.g., Firestore update fails),
        // still return 200 OK to Stripe if the signature was valid. This prevents retries.
        // Implement robust internal logging/alerting for these errors.
        res.status(200).json({ received: true, error: "Internal processing error. Check logs." });
    }
}

module.exports = { handleStripeWebhook };