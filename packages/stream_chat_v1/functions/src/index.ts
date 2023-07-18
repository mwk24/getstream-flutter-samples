/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import Increase from "increase";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

const increase = new Increase({
  apiKey: 'NsfFRMtQrssgqnvYlRgkJBNwSXDgSUs5', // defaults to process.env["INCREASE_API_KEY"]
  environment: 'sandbox', // defaults to 'production'
});

export const helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", { structuredData: true });

  const accountID = createAccount();

  response.send("Hello from Firebase! with account ID: " + accountID);
});



async function createAccount() {
  const account = await increase.accounts.create({ name: 'Persona account 1' });
  return account.id;
}

