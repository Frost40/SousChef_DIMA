// functions/Stripe/refund.js

const Stripe = require('stripe');
const { HttpsError } = require('firebase-functions/v2/https');

/**
 * Logic for creating a Stripe Refund.
 * This is an internal helper function, called by the exported Cloud Function in index.js.
 *
 * @param {object} data - The data sent from the client (e.g., { payment_intent_id: 'pi_...', amount: 1000 }).
 * @param {object} context - The Cloud Functions callable context (includes auth info).
 * @param {string} stripeSecretKey - The Stripe secret key.
 * @param {object} db - The Firestore database instance.
 * @param {object} FieldValue - Firebase Firestore FieldValue for server timestamps.
 * @returns {Promise<object>} - A promise that resolves with the refund details.
 * @throws {HttpsError} - Throws an HttpsError on authentication or other failures.
 */
async function createRefundLogic(data, context, stripeSecretKey, db, FieldValue) {
    // 1. Authentication Check
    if (!context.auth) {
        console.error('Unauthenticated user attempting to create refund.');
        throw new HttpsError('unauthenticated', 'Utente non autenticato. Accesso negato.');
    }

    const userId = context.auth.uid; // You might want to check if this user has permission to issue refunds
    const stripeInstance = new Stripe(stripeSecretKey);

    try {
        // 2. Input Validation
        if (!data.payment_intent_id || typeof data.payment_intent_id !== 'string') {
            console.error('Missing or invalid payment_intent_id for refund:', data.payment_intent_id);
            throw new HttpsError('invalid-argument', 'ID del Payment Intent non fornito o non valido.');
        }
        if (typeof data.amount !== 'number' || !Number.isInteger(data.amount) || data.amount <= 0) {
            console.error('Invalid amount provided for refund:', data.amount);
            throw new HttpsError('invalid-argument', 'L\'ammontare del rimborso deve essere un numero intero positivo (in centesimi/unità più piccole).');
        }

        // Optional: Fetch the original order from Firestore to verify refund eligibility or maximum amount
        // Example:
        // const originalOrderQuery = await db.collection('orders').where('payment_id', '==', data.payment_intent_id).limit(1).get();
        // if (originalOrderQuery.empty) {
        //     throw new HttpsError('not-found', 'Ordine originale non trovato per il rimborso.');
        // }
        // const originalOrder = originalOrderQuery.docs[0].data();
        // if (originalOrder.status === 'refunded' || originalOrder.status === 'partially_refunded') {
        //     throw new HttpsError('failed-precondition', 'L\'ordine è già stato rimborsato.');
        // }
        // Add logic to ensure the amount being refunded does not exceed the original payment amount.

        // 3. Create Refund with Stripe
        const refund = await stripeInstance.refunds.create({
            payment_intent: data.payment_intent_id,
            amount: data.amount, // Amount to refund in the smallest currency unit
            metadata: {
                requested_by_user_id: userId,
                // You might add an internal order_id here if retrieved above
            },
        });

        console.log(`Refund created for Payment Intent ${data.payment_intent_id}: ${refund.id}`);

        // Optional: Update your Firestore order status to 'refunded' or 'partially_refunded'
        // You should *also* rely on the 'charge.refunded' webhook for the definitive update,
        // but a preliminary update here can be useful for immediate client feedback.
        // Make sure to handle idempotency if you do this.

        return {
            refundId: refund.id,
            status: refund.status,
            amountRefunded: refund.amount,
        };

    } catch (error) {
        console.error('Errore nella creazione del rimborso:', error);
        if (error instanceof HttpsError) {
            throw error;
        }
        if (error.type && error.raw) {
            throw new HttpsError('internal', `Stripe API Error: ${error.raw.message || 'Errore sconosciuto da Stripe.'}`);
        }
        throw new HttpsError('internal', 'Si è verificato un errore inaspettato durante la creazione del rimborso.');
    }
}

module.exports = { createRefundLogic };