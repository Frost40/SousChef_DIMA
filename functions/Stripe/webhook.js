// functions/Stripe/webhook.js

const Stripe = require('stripe');

/**
 * Logic for handling Stripe Webhook events.
 * This is an internal helper function, called by the exported Cloud Function in index.js.
 * It's designed to be a single endpoint for ALL Stripe events.
 *
 * @param {object} req - The Express request object from the HTTP trigger.
 * @param {object} res - The Express response object.
 * @param {string} stripeWebhookSecret - The Stripe webhook signing secret.
 * @param {object} db - The Firestore database instance.
 * @param {object} FieldValue - Firebase Firestore FieldValue for server timestamps.
 */
async function handleStripeWebhook(req, res, stripeWebhookSecret, db, FieldValue) {
    const signature = req.headers['stripe-signature'];
    let event;

    try {
        // Verify webhook signature to ensure the event is from Stripe and not tampered with
        event = new Stripe(stripeWebhookSecret).webhooks.constructEvent(
            req.rawBody,
            signature,
            stripeWebhookSecret
        );
    } catch (err) {
        console.error('Webhook signature verification failed:', err.message);
        // Return 400 immediately if signature verification fails
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    // Log the event type for debugging (useful for unhandled events)
    console.log(`Received Stripe event type: ${event.type}, ID: ${event.id}`);

    try {
        // Handle different event types
        switch (event.type) {
            case 'payment_intent.succeeded': {
                const paymentIntent = event.data.object;
                const orderIdsString = paymentIntent.metadata?.orders_id;
                if (!orderIdsString) {
                    console.warn(`Webhook: payment_intent.succeeded event ${event.id} missing orders_id in metadata.`);
                    return res.json({ received: true });
                }
                const orderIds = orderIdsString.split(','); // Split into an array

                const batch = db.batch();
                for (const orderId of orderIds) {
                    const orderRef = db.collection('orders').doc(orderId);
                    // Fetch and check current status for idempotency for EACH order
                    const orderDoc = await orderRef.get(); // Or fetch all first in a single query
                    if (!orderDoc.exists || orderDoc.data().status === 'paid' || orderDoc.data().status === 'refunded') {
                        console.log(`Webhook: Order ${orderId} already processed or invalid status. Skipping.`);
                        continue; // Skip this specific order in the loop
                    }

                    batch.update(orderRef, {
                        status: 'paid',
                        // payment_id: paymentIntent.id, // Link to the single Payment Intent
                        // payment_date: FieldValue.serverTimestamp(),
                        // Update any other relevant fields
                    });
                }
                await batch.commit(); // Commit all updates in one go

                console.log(`Webhook: Status updated to 'paid' for orders: ${orderIds.join(', ')} for PI ${paymentIntent.id}`);
                break;
            }

            case 'payment_intent.payment_failed': {
                const paymentIntent = event.data.object;
                const orderId = paymentIntent.metadata?.order_id;

                if (!orderId) {
                    console.warn(`Webhook: payment_intent.payment_failed event ${event.id} missing order_id in metadata. Skipping.`);
                    return res.json({ received: true });
                }

                const orderRef = db.collection('orders').doc(orderId);
                const orderDoc = await orderRef.get();

                if (!orderDoc.exists) {
                    console.warn(`Webhook: payment_intent.payment_failed event ${event.id} for non-existent order ${orderId}. Skipping.`);
                    return res.json({ received: true });
                }

                const currentStatus = orderDoc.data()?.status;
                if (currentStatus === 'failed') {
                    console.log(`Webhook: Order ${orderId} already marked as 'failed'. Skipping duplicate processing for event ${event.id}.`);
                    return res.json({ received: true });
                }

                await orderRef.update({
                    status: 'failed',
                    payment_id: paymentIntent.id,
                    failure_code: paymentIntent.last_payment_error?.code || 'unknown',
                    failure_message: paymentIntent.last_payment_error?.message || 'unknown',
                    lastAttemptDate: FieldValue.serverTimestamp(),
                });
                console.log(`Webhook: Order ${orderId} status updated to 'failed' for event ${event.id}.`);
                break;
            }

            case 'charge.refunded': {
                const charge = event.data.object;
                const paymentIntentId = charge.payment_intent; // Charge is linked to Payment Intent
                let orderId = charge.metadata?.order_id; // Check if orderId is in charge metadata

                // If orderId not directly in charge metadata, try to find it via paymentIntent
                if (!orderId && paymentIntentId) {
                    const paymentIntentDoc = await db.collection('orders').where('payment_id', '==', paymentIntentId).limit(1).get();
                    if (!paymentIntentDoc.empty) {
                        orderId = paymentIntentDoc.docs[0].id;
                    }
                }

                if (!orderId) {
                    console.warn(`Webhook: charge.refunded event ${event.id} could not find associated order_id. Skipping.`);
                    return res.json({ received: true });
                }

                const orderRef = db.collection('orders').doc(orderId);
                const orderDoc = await orderRef.get();

                if (!orderDoc.exists) {
                    console.warn(`Webhook: charge.refunded event ${event.id} for non-existent order ${orderId}. Skipping.`);
                    return res.json({ received: true });
                }

                const currentStatus = orderDoc.data()?.status;
                if (currentStatus === 'refunded') {
                    console.log(`Webhook: Order ${orderId} already marked as 'refunded'. Skipping duplicate processing for event ${event.id}.`);
                    return res.json({ received: true });
                }

                // Determine if it's a full or partial refund
                const originalAmount = orderDoc.data().amountPaid; // Assuming you store this when payment succeeded
                const refundedAmount = charge.amount_refunded;

                let newStatus = 'partially_refunded';
                if (originalAmount && refundedAmount >= originalAmount) {
                    newStatus = 'refunded';
                }

                await orderRef.update({
                    status: newStatus,
                    refund_id: charge.id, // Store charge ID related to the refund
                    refund_date: FieldValue.serverTimestamp(),
                    // Consider adding total_refunded_amount field to track cumulative refunds if doing partials
                });
                console.log(`Webhook: Order ${orderId} status updated to '${newStatus}' for event ${event.id}.`);
                break;
            }

            // Add other Stripe event types you need to handle here (e.g., customer.subscription.created, etc.)

            default:
                // Log any unhandled event types for awareness
                console.log(`Webhook: Unhandled event type: ${event.type}. Event ID: ${event.id}`);
        }

        // Crucially, send a 200 OK response to Stripe to acknowledge receipt.
        // This tells Stripe the event was delivered successfully and it doesn't need to retry.
        res.json({ received: true });

    } catch (error) {
        console.error(`Error processing Stripe webhook event ${event?.id} (type: ${event?.type}):`, error);
        // Even if there's an error in your processing logic (e.g., Firestore update fails),
        // still return 200 OK to Stripe if the signature was valid. This prevents retries.
        // Implement robust internal logging/alerting for these errors.
        res.status(200).json({ received: true, error: "Internal processing error. Check logs." });
    }
}

module.exports = { handleStripeWebhook };