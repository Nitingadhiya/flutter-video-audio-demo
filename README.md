# video_audio_call

video-audio call mobile app

## Prerequisites

This project was built using the following tools:

- Flutter 3.19.6
- Dart 	3.3.4

## Getting Started 🚀


### setup firebase

- add packages for firebase 

``` dart
firebase_core: ^3.2.0
firebase_auth: ^5.1.2
``` 



### Add video call

 - add this package and follow the step in your project
``` dart
agora_rtc_engine: ^6.3.2
``` 
 - create the appId and certificateId in agora platform -> https://console.agora.io/
 - channel name -> generate dynamic video call room id
 - create token for video call feature
  - use this cUrl

``` dart
curl --location --request GET 'https://agora-token-generator-demo.vercel.app/api/main?type=rtc' \
--header 'Content-Type: application/json' \
--data '{
    "appId": "<agora_app_id>",
    "certificate": "<agora_certificate_id>",
    "channel": "<video_room_id>",
    "uid": "",
    "role": "publisher",
    "expire": 0
}'
``` 


###   setup send firebase notification

- add this package and follow the step in your project

``` dart
  firebase_messaging: ^15.0.3
``` 

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

4. run api in postman for get token and use in send notification api 

 ``` dart
curl --location 'http://localhost:3000/getAccessToken'
```

###   setup incoming call ring

- add this package and follow the step in your project

``` dart
  flutter_callkit_incoming: ^2.0.4+1
``` 
#### android setup

- AndroidManifest.xml
``` dart
 <manifest...>
     ...
     <!--
         Using for load image from internet
     -->
     <uses-permission android:name="android.permission.INTERNET"/>

   <application ...>
       <activity ...
          android:name=".MainActivity"
          android:launchMode="singleInstance">   <!-- change this line -->
        ...
   ...
   
 </manifest>
```

- create file `proguard-rules.pro` -> path -> <project>/android/app/proguard-rules.pro
``` dart
 -keep class com.hiennv.flutter_callkit_incoming.** { *; }
 -keep class com.izooto.** { *; }
 -keep class com.zest.android.** { *; }
 -keep class com.zest.ios.** { *; }
 -keep class com.hiennguyenraovat.plugins.** { *; }
```

- add this line <project>/android/app/build.gradle
``` dart
    buildTypes {
        release {
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'  \\ add this line
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig signingConfigs.debug
        }
    }
```


#### Ios setup


- add this code in <project>/ios/runner/AppDelegate.swift for handle ring event

``` dart
      override func application(_ application: UIApplication,
                                 continue userActivity: NSUserActivity,
                                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

           guard let handleObj = userActivity.handle else {
               return false
           }

           guard let isVideo = userActivity.isVideo else {
               return false
           }
           let objData = handleObj.getDecryptHandle()
           let nameCaller = objData["nameCaller"] as? String ?? ""
           let handle = objData["handle"] as? String ?? ""
           let data = flutter_callkit_incoming.Data(id: UUID().uuidString, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
           //set more data...
           //data.nameCaller = nameCaller
           SwiftFlutterCallkitIncomingPlugin.sharedInstance?.startCall(data, fromPushKit: true)

           return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
       }

       // Handle updated push credentials
       func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
           print(credentials.token)
           let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
           print(deviceToken)
           //Save deviceToken to your server
           SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(deviceToken)
       }

       func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
           print("didInvalidatePushTokenFor")
           SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
       }

       // Handle incoming pushes
       func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
           print("didReceiveIncomingPushWith")
           guard type == .voIP else { return }

           let id = payload.dictionaryPayload["id"] as? String ?? ""
           let nameCaller = payload.dictionaryPayload["nameCaller"] as? String ?? ""
           let handle = payload.dictionaryPayload["handle"] as? String ?? ""
           let isVideo = payload.dictionaryPayload["isVideo"] as? Bool ?? false

           let data = flutter_callkit_incoming.Data(id: id, nameCaller: nameCaller, handle: handle, type: isVideo ? 1 : 0)
           //set more data
           data.extra = ["user": "abc@123", "platform": "ios"]
           //data.iconName = ...
           //data.....
           SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(data, fromPushKit: true)

           //Make sure call completion()
           DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
               completion()
           }
       }


       // Func Call api for Accept
       func onAccept(_ call: Call, _ action: CXAnswerCallAction) {
           let json = ["action": "ACCEPT", "data": call.data.toJSON()] as [String: Any]
           print("LOG: onAccept")
           self.performRequest(parameters: json) { result in
               switch result {
               case .success(let data):
                   print("Received data: \(data)")
                   //Make sure call action.fulfill() when you are done(connected WebRTC - Start counting seconds)
                   action.fulfill()

               case .failure(let error):
                   print("Error: \(error.localizedDescription)")
               }
           }
       }

       // Func Call API for Decline
       func onDecline(_ call: Call, _ action: CXEndCallAction) {
           let json = ["action": "DECLINE", "data": call.data.toJSON()] as [String: Any]
           print("LOG: onDecline")
           self.performRequest(parameters: json) { result in
               switch result {
               case .success(let data):
                   print("Received data: \(data)")
                   //Make sure call action.fulfill() when you are done
                   action.fulfill()

               case .failure(let error):
                   print("Error: \(error.localizedDescription)")
               }
           }
       }

       // Func Call API for End
       func onEnd(_ call: Call, _ action: CXEndCallAction) {
           let json = ["action": "END", "data": call.data.toJSON()] as [String: Any]
           print("LOG: onEnd")
           self.performRequest(parameters: json) { result in
               switch result {
               case .success(let data):
                   print("Received data: \(data)")
                   //Make sure call action.fulfill() when you are done
                   action.fulfill()

               case .failure(let error):
                   print("Error: \(error.localizedDescription)")
               }
           }
       }

       // Func Call API for TimeOut
       func onTimeOut(_ call: Call) {
           let json = ["action": "TIMEOUT", "data": call.data.toJSON()] as [String: Any]
           print("LOG: onTimeOut")
           self.performRequest(parameters: json) { result in
               switch result {
               case .success(let data):
                   print("Received data: \(data)")

               case .failure(let error):
                   print("Error: \(error.localizedDescription)")
               }
           }
       }

       // Func Callback Toggle Audio Session
       func didActivateAudioSession(_ audioSession: AVAudioSession) {
           //Use if using WebRTC
           //RTCAudioSession.sharedInstance().audioSessionDidActivate(audioSession)
           //RTCAudioSession.sharedInstance().isAudioEnabled = true
       }

       // Func Callback Toggle Audio Session
       func didDeactivateAudioSession(_ audioSession: AVAudioSession) {
           //Use if using WebRTC
           //RTCAudioSession.sharedInstance().audioSessionDidDeactivate(audioSession)
           //RTCAudioSession.sharedInstance().isAudioEnabled = false
       }

       func performRequest(parameters: [String: Any], completion: @escaping (Result<Any, Error>) -> Void) {
           if let url = URL(string: "https://webhook.site/e32a591f-0d17-469d-a70d-33e9f9d60727") {
               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               request.addValue("application/json", forHTTPHeaderField: "Content-Type")
               //Add header

               do {
                   let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
                   request.httpBody = jsonData
               } catch {
                   completion(.failure(error))
                   return
               }

               let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                   if let error = error {
                       completion(.failure(error))
                       return
                   }

                   guard let data = data else {
                       completion(.failure(NSError(domain: "mobile.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Empty data"])))
                       return
                   }

                   do {
                       let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                       completion(.success(jsonObject))
                   } catch {
                       completion(.failure(error))
                   }
               }
               task.resume()
           } else {
               completion(.failure(NSError(domain: "mobile.app", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
           }
       }
```

- add this code in <project>/ios/runner/Info.plist

``` dart
<key>UIBackgroundModes</key>
<array>
    <string>voip</string>
    <string>remote-notification</string>
    <string>processing</string> //you can add this if needed
</array>
```

- handle ring in app kill mode for follow this link 

https://github.com/hiennguyen92/flutter_callkit_incoming/blob/master/PUSHKIT.md


