const functions = require("firebase-functions");
const { Paddle, Environment } = require("@paddle/paddle-node-sdk");

// SET THIS TO Environment.sandbox FOR TESTING
const IS_SANDBOX = true;

const PADDLE_KEY = "pdl_sdbx_apikey_01kxnjmg3ey4xvv9qfwvmpm1q9_y8YmzenxjW7jRXMkrY5PFW_AjQ";
const PRODUCT_ID = "pro_01kxnjf56rgfmmqf6k27a8adzg";

const paddle = new Paddle(PADDLE_KEY, {
  environment: IS_SANDBOX ? Environment.sandbox : Environment.production,
});

exports.createPaddleCheckout = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');
  if (req.method === 'OPTIONS') {
    res.set('Access-Control-Allow-Methods', 'POST');
    res.set('Access-Control-Allow-Headers', 'Content-Type');
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }

  try {
    const { amount, currency, app_name, package_id } = req.body;

    if (!amount || !currency) {
      return res.status(400).json({ error: 'Missing amount or currency' });
    }

    const transaction = await paddle.transactions.create({
      items: [
        {
          quantity: 1,
          price: {
            name: `Support ${app_name || 'Developer'}`,
            description: `Donation from ${app_name || 'App'}`,
            productId: PRODUCT_ID,
            unitPrice: {
              amount: Math.round(parseFloat(amount) * 100).toString(),
              currencyCode: currency,
            },
            taxCategory: "standard"
          },
        },
      ],
      collectionMode: 'automatic',
      customData: {
        app_name: app_name || 'Unknown',
        package_id: package_id || 'Unknown',
      }
    });

    // Paddle v2 Hosted Checkout URL format
    const domain = IS_SANDBOX ? "sandbox-buy.paddle.com" : "buy.paddle.com";
    const checkoutUrl = `https://${domain}/checkout/buy?_ptxn=${transaction.id}`;

    console.log("Transaction ID:", transaction.id);
    console.log("Returning URL:", checkoutUrl);

    res.status(200).json({
      checkout_url: checkoutUrl
    });

  } catch (error) {
    console.error("Paddle Error:", JSON.stringify(error, null, 2));
    res.status(500).json({
      error: error.message,
      details: error.response?.data?.error || error
    });
  }
});
