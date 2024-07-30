# video_audio_call

video-audio call mobile app

## Prerequisites

This project was built using the following tools:

- Flutter 3.19.6
- Dart 	3.3.4

## Getting Started 🚀

- setup send firebase notification
 
  1. run local server in terminal -> node notification_server.js
  2. after run cUrl in postman -> return accessToken

  curl 'http://localhost:3000/getAccessToken' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H 'Cache-Control: max-age=0' \
  -H 'Connection: keep-alive' \
  -H 'If-None-Match: W/"412-v0q5iMmhuTSRkIQc70fGTJo67ok"' \
  -H 'Sec-Fetch-Dest: document' \
  -H 'Sec-Fetch-Mode: navigate' \
  -H 'Sec-Fetch-Site: none' \
  -H 'Sec-Fetch-User: ?1' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36' \
  -H 'sec-ch-ua: "Not/A)Brand";v="8", "Chromium";v="126", "Google Chrome";v="126"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"'

  - Response
    {
    "accessToken": "ya29.c.c0ASRK0Gbt7C1q57-kshWW0Vsl60bjifwHjaaBoK_rnvYL5FM85u_MJ8I9wSr_8k7a1ZOPj7W4N-CcZMMgeQl1TK-baS2bTiGiIWamu5esgSCmyeOX7bkXTiZziP9oSdGm1CQTAsK82UTS64GNmgu3KdQYxBUBlRm17CcYJ9DQf117KWVUcPjqsTD6V4JFTF4C9XEGKAOf6RvXTvoQx2FMdxyJIdW93XNx4I0UmXLaIBoGuKZxRYvx8U9UfJhEiLqcbhk8vq4d6MUXdSYEf-7ecXJi5p84zfdgTgdXrI9QjYwyoy3xH3A_-Bwsxn1477CWr0z-qKFijzACHQHNpgo85Ip3Jt2S5Q29AFTRvC4dKfGlTs6HLlt8kAEH384C0yxev5nS2Jh8O82fl_saqMv6-Wo8rqye9keOYopWpWnfV_-4W8iWY7yqslVSyuq8hg648on1OoqQz7O55lnuxzYj52aQJMeV8BkQQU6Zxj-jFRVfjXmqBf5l-gu3uq6_Xg_JdjR5I1uVyXmMswXicbJxb4hfX0U75csIZtx1MjcV6opu1Vk6M6pcZ0szn6d1kduUOuU8_dv411l-ZkSnbq-gt_ShZXBefrnopvWvQZxjqi00rmMim66Mv2_6USO530au8bw4-6bxwRU77vXWh1mq4gWJSoRMr9SojklMYjrqRsS1ogB47m3VF0yWWQr--pwniIRQY14W5h5rlyrayk2BYgWgcki_awsRFnZozdRdUa2S9VjFyF1-X6Ig3tj0q5xrq9i8UUQgUddzFQsxwsIJhFpogXM73aMa70reBjojwdZ8fIYs84z_YwSXiujydih6iUnZctc-4Ojh5SruiRfc1sZq2MgkjyqsxXQ1-5172c2paqSrIB6hYdFetIOj13j3lhvQc6hYmrV0w6pkVpnZ0rd3aevVYMhwJpZW5-Vka8jSIjx9o8Vtx3iQj7v3z7pdo5kzIlWsXelzwr1h_yM5qf_lw9OM5f7v_Bl5bt11JIcy4bWi2Xrw6Mw"
    }

   3. accessToken to replace for send notification api
    
   - token path - lib/service/config.dart
     notificationAccessToken = "ya29.c.c0ASRK0Gbt7C1q57-......."