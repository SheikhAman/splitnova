const functions = require("firebase-functions");

// Basic Firebase Health Check Function
exports.healthCheck = functions.https.onRequest((req, res) => {
  res.status(200).json({
    status: "online",
    app: "SplitNova Backend",
    timestamp: new Date().toISOString(),
  });
});
