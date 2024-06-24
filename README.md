
# trailblaze-flutter

A route-planning app that finds the scenic way to get to places. 

<img width="19%" alt="route preview" src="https://github.com/andreytakhtamirov/trailblaze-flutter/assets/70922688/d2b5d956-3972-49fe-80af-8cf96e5e9149">&nbsp;
<img width="19%" alt="route info" src="https://github.com/andreytakhtamirov/trailblaze-flutter/assets/70922688/281f7fee-834e-4b81-9818-9d38f97e6380">&nbsp;
<img width="19%" alt="features view" src="https://github.com/andreytakhtamirov/trailblaze-flutter/assets/70922688/622ec0d7-58eb-4799-90c2-534a8a327ac6">&nbsp;
<img width="19%" alt="pin view" src="https://github.com/andreytakhtamirov/trailblaze-flutter/assets/70922688/2c136947-de79-4216-b809-dd27772be4c4">&nbsp;
<img width="19%" alt="pin view" src="https://github.com/andreytakhtamirov/trailblaze-flutter/assets/70922688/d1199edb-a188-4687-9489-e9f52f81d8d1">&nbsp;

## Releases
Available on the [App Store](https://apps.apple.com/ca/app/trailblaze/id6450859439) for iOS

Android release and development builds:
[![Latest Release](https://img.shields.io/github/v/release/andreytakhtamirov/trailblaze-flutter?include_prereleases&style=flat)](https://github.com/andreytakhtamirov/trailblaze-flutter/releases/latest)


## Key Features:
- Find new routes to your favourite destinations with directions for walking and cycling.
- Take advantage of optimized routing for gravel cycling, prioritizing unpaved trails/roads.
- Customize your route by selecting the ideal mix of trails and specifying an area to avoid.

## Additional Features:
- Explore nearby parks within your preferred travel distance.
- View trip details such as distance, estimated time, and surface information.
- Sign in to personalize and manage your profile, including saving routes for future adventures.
- Export routes to GPX.
- Route Explorer: Choose a distance and discover nearby loops.

<br>


## Coming Soon
- *Discover page with routes from other users.*
- Save and share your own routes.*

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


## About the Project

Trailblaze was a 4-month long capstone project completed by Andrey Takhtamirov, Alex Braverman, and Filipe Brito (Conestoga College Software Engineering Technology 2023), including a client application (trailblaze-android) and a server application (trailblaze-server).

Both projects are now open-sourced and available here:
- https://dev.azure.com/trailblaze/trailblaze/_git/trailblaze-android
- https://dev.azure.com/trailblaze/trailblaze/_git/trailblaze-server
