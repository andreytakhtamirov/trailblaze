
# Trailblaze

A route-planning app that finds the scenic way to get to places. 

<img src="https://github.com/user-attachments/assets/16999276-5cc0-421f-b778-d380d7366154" width="19%">
<img src="https://github.com/user-attachments/assets/05472f96-39ba-4ee8-9912-44d0753399e3" width="19%">
<img src="https://github.com/user-attachments/assets/52704bb3-112e-46cc-b0c0-abf7cd072e5d" width="19%">
<img src="https://github.com/user-attachments/assets/e3695e5e-938b-4257-9b1b-3cc8445b3dc0" width="19%">
<br>
<img src="https://github.com/user-attachments/assets/b83dda7a-5638-48c1-9dff-f9c48e503ce3" width="19%">
<img src="https://github.com/user-attachments/assets/ebdb6833-5292-41ec-a6a8-c4d29a39ad4c" width="19%">
<img src="https://github.com/user-attachments/assets/f2ab765d-f664-49cf-ad6b-05c39a4a93b0" width="19%">
<img src="https://github.com/user-attachments/assets/8bf16503-19b3-4e1f-90a8-c542f7675e8b" width="19%">



## Releases
Available on the [App Store](https://apps.apple.com/ca/app/trailblaze/id6450859439) for iOS

Android release and development builds:
[![Latest Release](https://img.shields.io/github/v/release/andreytakhtamirov/trailblaze-flutter?include_prereleases&style=flat)](https://github.com/andreytakhtamirov/trailblaze-flutter/releases/latest)


## Key Features:
- Find new routes to your favourite destinations with directions for walking and cycling.
- Take advantage of optimized routing for gravel cycling, prioritizing unpaved trails/roads.
- Customize your route by selecting the ideal mix of trails and specifying an area to avoid.
- Navigate your routes with live turn-by-turn directions.

## Additional Features:
- Explore nearby parks within your preferred travel distance.
- View trip details, including distance, estimated time, and surface information.
- Sign in to personalize and manage your profile, including saving routes for future adventures.
- Export routes to GPX.
- Route Explorer: Choose a distance and discover nearby loops.

<br>
<br>

📜 [Terms](https://github.com/andreytakhtamirov/trailblaze-flutter/blob/main/terms_and_conditions.md#terms-and-conditions)

🛡️ [Privacy Policy](https://github.com/andreytakhtamirov/trailblaze-flutter//blob/main/privacy_policy.md#privacy-policy)

<br>
<br>

## Building

**Setting Mapbox access token**

To create an access token, you must first create a Mapbox account. The token should have the `Downloads:Read` scope.

-   to download the Android SDK add the token configuration to  `~/.gradle/gradle.properties`  :
```
  SDK_REGISTRY_TOKEN=YOUR_SECRET_MAPBOX_ACCESS_TOKEN
```

-   to download the iOS SDK add the token configuration to  `~/.netrc`  :

```
  machine api.mapbox.com
  login mapbox
  password YOUR_SECRET_MAPBOX_ACCESS_TOKEN
```

**Setting other secret tokens**

Next, create a `.env` file in the root directory of the project. This file will contain other tokens required for the app. The file should look like this:

    MAPBOX_ACCESS_TOKEN=MAPBOX_PUBLIC_TOKEN_HERE
    TRAILBLAZE_APP_TOKEN=APP_SECRET_HERE
    AUTH0_SCHEME=demo
    AUTH0_DOMAIN=trailblaze-dev.us.auth0.com
    AUTH0_CLIENT_ID=SECRET_CLIENT_ID_HERE
    
Note:
- Use your Mapbox public token in this file.
- For the app token, contact trailblaze.team@outlook.com
- The Mapbox access token and the app token are the only required fields to use the basic functionality of the app (Creating routes locally and exploring existing community routes).
- Other fields are only required for accessing your Trailblaze account (saving routes, posting on the community page) and will not be shared to preserve app security.

