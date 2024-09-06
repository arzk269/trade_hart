import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from "stripe";
import axios from "axios";
import * as qs from "qs";
import * as cors from "cors";

// Initialiser Firebase Admin SDK
admin.initializeApp();

// Initialiser Stripe avec votre clé secrète
const stripe = new Stripe(functions.config().stripe.secret);

// Configurer le middleware CORS
const corsHandler = cors({origin: true});

// Fonction pour créer un jeton personnalisé
export const generateToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated"
    );
  }

  const uid = context.auth.uid;
  const customClaims = {
    stripeAccount: data.stripeAccount,
  };

  try {
    const token = await admin.auth().createCustomToken(uid, customClaims);
    return {token};
  } catch (error) {
    throw new functions.https.HttpsError(
      "internal",
      "Error creating custom token",
      error
    );
  }
});

// Fonction HTTPS pour effectuer le transfert
export const createTransfer = functions.https.onRequest((req, res) => {
  return corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const idToken = req.headers.authorization?.split("Bearer ")[1];
    if (!idToken) {
      res.status(403).send("Forbidden");
      return;
    }

    try {
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      if (!decodedToken) {
        res.status(403).send("Forbidden: Invalid ID token");
        return;
      }

      const {totalAmount, sellerStripeId} = req.body;
      const amountInCents = Math.round(totalAmount * 90 * 0.97);

      const transfer = await stripe.transfers.create({
        amount: amountInCents,
        currency: "eur",
        destination: sellerStripeId,
      });

      res.status(200).json({transferId: transfer.id});
    } catch (error) {
      console.error("Error creating transfer:", error);
      res.status(500).send("Internal Server Error");
    }
  });
});

// Fonction HTTPS pour créer un PaymentIntent
export const createPayment = functions.https.onRequest((req, res) => {
  return corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const {amount, currency} = req.body;
      const response = await stripe.paymentIntents.create({
        amount: calculateAmount(amount),
        currency: currency,
        payment_method_types: ["card"],
        capture_method: "automatic",
      });

      console.log("Payment Intent Body -> ", response);
      res.status(200).json(response);
    } catch (error) {
      console.error("Error creating Payment Intent:", error);
      res.status(500).send("Internal Server Error");
    }
  });
});

const calculateAmount = (amount: string) => {
  return parseInt(amount, 10) * 100;
};

export const sendNotification = functions.https.onRequest((req, res) => {
  return corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const {
      token,
      title,
      body,
      senderId,
      receverId,
      articleId,
      serviceId,
      commandId,
      reservationId,
      route,
      conversationId,
    } = req.body;

    if (!token || !title || !body) {
      res.status(400).send("Bad Request: Missing required parameters");
      return;
    }

    const message = {
      token: token,
      notification: {
        title: title,
        body: body,
      },
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        route: route ?? "",
        senderId: senderId ?? "",
        receverId: receverId ?? "",
        articleId: articleId ?? "",
        serviceId: serviceId ?? "",
        commandId: commandId ?? "",
        reservationId: reservationId ?? "",
        conversationId: conversationId ?? "",
      },
    };

    try {
      const response = await admin.messaging().send(message);
      res.status(200).send(`Notification sent successfully: ${response}`);
    } catch (error) {
      console.error("Error sending notification:", error);
      res.status(500).send("Internal ServerError");
    }
  });
});

export const getAccountVerificationLink = async (accountId: string) => {
  try {
    const response = await axios.post(
      "https://api.stripe.com/v1/account_links",
      qs.stringify({
        account: accountId,
        refresh_url: "https://tradhart.com/",
        return_url: "https://tradhart.com/",
        type: "account_onboarding",
      }),
      {
        headers: {
          "Authorization": `Bearer ${functions.config().stripe.secret}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
      }
    );

    if (response.status === 200) {
      return response.data.url;
    } else {
      throw new Error(`Failed to get verification link ${response.data}`);
    }
  } catch (error) {
    throw new functions.https.HttpsError("internal", "Failed", error);
  }
};

// Fonction HTTPS pour créer un compte Stripe
export const createStripe = functions.https.onRequest((req, res) => {
  return corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    try {
      const response = await axios.post(
        "https://api.stripe.com/v1/accounts",
        qs.stringify({
          type: "express",
          country: "FR",
        }),
        {
          headers: {
            "Authorization": `Bearer ${functions.config().stripe.secret}`,
            "Content-Type": "application/x-www-form-urlencoded",
          },
        }
      );

      if (response.status === 200) {
        const accountId = response.data.id;
        const verificationUrl = await getAccountVerificationLink(accountId);
        res.status(200).json({accountId, verificationUrl});
      } else {
        throw new Error(`Failed to create Stripe account ${response.data}`);
      }
    } catch (error) {
      console.error("Error creating Stripe account:", error);
      res.status(500).send("Internal Server Error");
    }
  });
});

export const stripeVerif = functions.https.onRequest((req, res) => {
  return corsHandler(req, res, async () => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const {accountId} = req.body;

    if (!accountId) {
      res.status(400).send("Bad Request: Missing accountId");
      return;
    }

    try {
      const accountDetails = await stripe.accounts.retrieve(accountId);
      const chargesEnabled = accountDetails.charges_enabled;
      const paymentEnabled = accountDetails.payouts_enabled;

      const accountStatus = chargesEnabled && paymentEnabled ?
        "Compte vérifié et opérationnel" :
        "Compte non vérifié ou non opérationnel";

      console.log("Statut du compte:", accountStatus);
      res.status(200).json({chargesEnabled, paymentEnabled, accountStatus});
    } catch (error) {
      console.error("Erreur lors de la vérification du compte:", error);
      res.status(500).send("Internal Server Error");
    }
  });
});

const GOOGLE_API_KEY = "AIzaSyDApRHNNeJyHdQ2OIRqAtWXIdeJB3tphBA";

// Fonction pour obtenir les suggestions d'autocomplete
export const getPlaceSuggestions = functions.https.onRequest((req, res) => {
  return corsHandler(req, res, async () => {
    const input = req.query.input as string;

    if (!input) {
      res.status(400).send("Input is required");
      return;
    }

    try {
      const response = await axios.get("https://maps.googleapis.com/maps/api/place/autocomplete/json", {
        params: {
          input: input,
          key: GOOGLE_API_KEY,
          language: "fr",
          types: "geocode",
          // Optional: Restrict results to a specific country
          // components: "country:fr"
        },
      });

      // Envoyer la réponse JSON au client avec les suggestions
      res.json(response.data);
    } catch (error) {
      console.error("Error fetching data from Google Places API", error);
      res.status(500).send("Error fetching data");
    }
  });
});

export const getPlaceDetails = functions.https.onRequest(async (req, res) => {
  // Activer CORS si nécessaire
  res.set("Access-Control-Allow-Origin", "*");

  const placeId = req.query.placeid as string;

  if (!placeId) {
    res.status(400).send("Place ID is required");
    return;
  }

  try {
    const response = await axios.get("https://maps.googleapis.com/maps/api/place/details/json", {
      params: {
        placeid: placeId,
        key: GOOGLE_API_KEY,
      },
    });

    if (response.data.status !== "OK") {
      res.status(400).send("Failed to retrieve place details");
      return;
    }

    const result = response.data.result;
    const location = result.geometry.location;
    const formattedAddress = result.formatted_address;

    const placeDetails = {
      latitude: location.lat,
      longitude: location.lng,
      formatted_address: formattedAddress,
    };

    res.json(placeDetails);
  } catch (error) {
    console.error("Error fetching data from Google Places API", error);
    res.status(500).send("Error fetching data");
  }
});
