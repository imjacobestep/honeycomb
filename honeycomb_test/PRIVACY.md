Authentication:
Honeycomb stores userIDs (email addresses and passwords) in a Firebase Authentication database
Passwords are not stored in plaintext, but are hashed

Geolocation:
User geolocation is used only in the map view when the permission is allowed on the device
This location data is not stored and is only used to position the map, allowing the user to find nearby resources

Username:
Usernames are collected when creating or editing resource or client information
This is used to provide context around how recently a resource's info was updated and links that latest version to the user making the changes