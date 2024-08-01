// server.js
const express = require('express');
const { google } = require('googleapis');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const app = express();
const port = 3000;

const SCOPES = ['https://www.googleapis.com/auth/cloud-platform'];

// Load service account key from file
function loadServiceAccountKey() {
  return new Promise((resolve, reject) => {
    fs.readFile(path.join(__dirname, 'server_config/service.json'), 'utf8', (err, data) => {
      if (err) {
        reject(new Error('Failed to read service account key: ' + err.message));
        return;
      }
      try {
        resolve(JSON.parse(data));
      } catch (parseErr) {
        reject(new Error('Failed to parse service account key JSON: ' + parseErr.message));
      }
    });
  });
}

// Get access token function
async function getAccessToken() {
  try {
    const key = await loadServiceAccountKey();
    const jwtClient = new google.auth.JWT(
      key.client_email,
      null,
      key.private_key,
      SCOPES,
      null
    );
    return new Promise((resolve, reject) => {
      jwtClient.authorize((err, tokens) => {
        if (err) {
          reject(err);
          return;
        }
        resolve(tokens.access_token);
      });
    });
  } catch (err) {
    throw new Error('Failed to get access token: ' + err.message);
  }
}

// Middleware
app.use(cors());

// Endpoint to get access token
app.get('/getAccessToken', async (req, res) => {
  try {
    const accessToken = await getAccessToken();
    res.json({ accessToken });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
