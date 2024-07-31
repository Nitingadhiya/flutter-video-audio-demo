# video_audio_call

video-audio call mobile app

## Prerequisites

This project was built using the following tools:

- Flutter 3.19.6
- Dart 	3.3.4

## Getting Started 🚀

### setup firebase
``` dart
firebase_core: ^3.2.0
``` 
### Login and sign up with firebase auth
    - add this packege
``` dart
firebase_auth: ^5.1.2
``` 
    - create login and sign up page 
    - and save user data with fcm token in firestore database
    - and get all user data in home page 

### Add video call

 - add this package and follow the step in your project
   - create the appId in agora platform -> https://console.agora.io/
``` dart
agora_rtc_engine: ^6.3.2
``` 
  - create token for this api
    - 


###   setup send firebase notification

1. download serviceAccountKey.json file in firebase
   - follow this path -> project setting-> service account -> Generate new private key
     <img src='https://firebasestorage.googleapis.com/v0/b/video-audio-call-faf0f.appspot.com/o/Screenshot%202024-07-31%20at%204.20.45%E2%80%AFPM.png?alt=media&token=4f548748-a3ff-4a7a-9f43-85ebc3b06ec0' width='600'></img></a>
   - save this file in your project

2. create notification_server.json for create local server in get access token for notification send api
   - `config/service.json` to replace your serviceAccountKey.json path
 ``` dart
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
    fs.readFile(path.join(__dirname, 'config/service.json'), 'utf8', (err, data) => {
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
```
3. then run command in your project terminal

 ``` dart
node notification_server.js
```

4. run api in postman for get token

 ``` dart
curl --location 'http://localhost:3000/getAccessToken'
```


  1. run local server in terminal -> node notification_server.js
  2. after run cUrl in postman -> return accessToken



  - Response
    {
    "accessToken": "ya29.c.c0ASRK0Gbt7C1q57-kshWW0Vsl60bjifwHjaaBoK_rnvYL5FM85u_MJ8I9wSr_8k7a1ZOPj7W4N-CcZMMgeQl1TK-baS2bTiGiIWamu5esgSCmyeOX7bkXTiZziP9oSdGm1CQTAsK82UTS64GNmgu3KdQYxBUBlRm17CcYJ9DQf117KWVUcPjqsTD6V4JFTF4C9XEGKAOf6RvXTvoQx2FMdxyJIdW93XNx4I0UmXLaIBoGuKZxRYvx8U9UfJhEiLqcbhk8vq4d6MUXdSYEf-7ecXJi5p84zfdgTgdXrI9QjYwyoy3xH3A_-Bwsxn1477CWr0z-qKFijzACHQHNpgo85Ip3Jt2S5Q29AFTRvC4dKfGlTs6HLlt8kAEH384C0yxev5nS2Jh8O82fl_saqMv6-Wo8rqye9keOYopWpWnfV_-4W8iWY7yqslVSyuq8hg648on1OoqQz7O55lnuxzYj52aQJMeV8BkQQU6Zxj-jFRVfjXmqBf5l-gu3uq6_Xg_JdjR5I1uVyXmMswXicbJxb4hfX0U75csIZtx1MjcV6opu1Vk6M6pcZ0szn6d1kduUOuU8_dv411l-ZkSnbq-gt_ShZXBefrnopvWvQZxjqi00rmMim66Mv2_6USO530au8bw4-6bxwRU77vXWh1mq4gWJSoRMr9SojklMYjrqRsS1ogB47m3VF0yWWQr--pwniIRQY14W5h5rlyrayk2BYgWgcki_awsRFnZozdRdUa2S9VjFyF1-X6Ig3tj0q5xrq9i8UUQgUddzFQsxwsIJhFpogXM73aMa70reBjojwdZ8fIYs84z_YwSXiujydih6iUnZctc-4Ojh5SruiRfc1sZq2MgkjyqsxXQ1-5172c2paqSrIB6hYdFetIOj13j3lhvQc6hYmrV0w6pkVpnZ0rd3aevVYMhwJpZW5-Vka8jSIjx9o8Vtx3iQj7v3z7pdo5kzIlWsXelzwr1h_yM5qf_lw9OM5f7v_Bl5bt11JIcy4bWi2Xrw6Mw"
    }



   3. accessToken to replace for send notification api
    
   - token path - lib/service/config.dart
   - notificationAccessToken = "ya29.c.c0ASRK0Gbt7C1q57-......."