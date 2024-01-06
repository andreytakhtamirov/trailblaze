
# trailblaze-flutter

A route-planning app that finds the scenic way to get to places. 


## Releases
Check out the latest release of Trailblaze for iOS & Android:

[![Latest Release](https://img.shields.io/github/v/release/andreytakhtamirov/trailblaze-flutter?include_prereleases&style=flat)](https://github.com/andreytakhtamirov/trailblaze-flutter/releases/latest)


## Features
- Find new routes to your favorite places with directions for walking and cycling.
- Explore nearby parks within your chosen travel distance.
- See details about your trip, including distance, time, and surface information.
- 🏔️🚴 **[BETA] Routing for gravel cycling, prioritizing unpaved trails** [See availability map here](https://github.com/andreytakhtamirov/trailblaze-pathsense#supported-regions).
- Sign in and customize your profile.

</br>

- *[COMING SOON] Discover page with routes from other users.*
- *[COMING SOON] Save and share your own routes.*

## Screenshots
<img width="400" alt="route preview" src="https://github.com/andreytakhtamirov/trailblaze-flutter/assets/70922688/91a2d70a-c1ab-48fe-ac2d-877f2ad9612c">
<img width="400" alt="route info" src="https://github.com/andreytakhtamirov/trailblaze-flutter/assets/70922688/2885f8c0-15c0-4864-bdfb-d1ece401a47e">
<img width="400" alt="features view" src="https://github.com/andreytakhtamirov/trailblaze-flutter/assets/70922688/416f73eb-add5-48fe-aefe-6df4f8009013">
<img width="400" alt="image" src="https://github.com/andreytakhtamirov/trailblaze-flutter/assets/70922688/8bfe803b-ba0c-491c-93e0-66fce5512af3">

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

There you may also find the DevOps methods used throughout the process.
