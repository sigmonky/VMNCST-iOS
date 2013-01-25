Overview 
------------------------

The SM4 SDK is a drop-in solution for adding a social community into an app. The SDK offers a convenient layer of abstraction for API services exposed by Zeebox, Flux, Twitter and Facebook, facilitating development, integration, testing and support.

The SM4 SDK is shipped as an IOS framework and/or as a private Cocoa Pod component. Along with the framework, a demo Xcode project is provided with a singleton class named "VMNSocialMediaMediator",  which is used to illustrate how Twitter and Facebook SDKs should interact with the Viacom Social Media SDK.

You should use the SDK if you application connects to Facebook and/or Twitter and you'd like to have quick access to the social features offered by Viacom Flux and ZeeBox communities.

Usage
------------------------

### Add the following files into your project: VMNSocialMediaSDK.framework and VMNSocialMediaSDKResources.bundle.

### Import the framework into your Xcode project. We recommend to import it into your application's prefix (.pch) file.

	import <VMNSocialMediaSDK/VMNSocialMediaSDK.h>
	
### Import Dependencies

The SDK relies in the following dependencies:

- FacebookSDK.framework
- SystemConfiguration.framework
- Twitter.framework
- AdSupport.framework
- Social.framework
- Accounts.framework
- ABOAuthCore
- JSONKit

### Configure your application social network IDs in your PLIST

Open your application's plist and add the following keys: VMNSocialMediaID (Flux Community ID), VMNTwitterConsumerKey and VMNTwitterConsumerSecret.

Besides those fields, there is Facebook-specific fields you have to add:FacebookAppID and another field inside URL types, Item 0, URL Schemes, Item 0, with your Facebook app ID.

Each of these keys should be populated with the values provided by the application's producers. 

### Initialize a VMNSocial Media Session


Initialize a new VMNSocialMedia Session in your application's main delegate, inside the application: didFinishLaunchingWithOptions method:

	[[VMNSocialMediaMediator sharedInstance] startSession];


### Authenticate to Social Networks

#### Example: Facebook Authentication


	/* Login/Logout Using Facebook Credentials */
	[[VMNSocialMediaMediator sharedInstance] facebookAuthInView:self completion:^( NSError *error) {
	    if (error == nil){
	        // Facebook login has been successful
	    }else{
	        //handle error
	    }
	}];


#### Example: Twitter Authentication

	/* Login/Logout Using Twitter Credentials */

	[[VMNSocialMediaMediator sharedInstance] twitterAuthInView:self completion:^( NSError *error) {
	    if (error == nil){
	        // Twitter login has been successful
	    }else{
	        //handle error
	    }
	}];



#### Example: Flux Authentication

	/* Login/Logout Using Flux Credentials */
	[[VMNSocialMediaMediator sharedInstance] fluxAuthInView:self username:usernameField.text password:passField.text completion:^( NSError *error) {
	    if (error == nil){
	        // Flux login has been successful
	    }else{
	        //handle error
	    }
	}];


### Check if user is connected to a Social Network

	/* Verify if user is authenticated via Twitter */
	if ([[VMNSocialMediaMediator sharedInstance] isAuthenticatedOnTwitter]){
	// Do Something
	}

	/* Verify if user is authenticated via Facebook */
	if ([[VMNSocialMediaMediator sharedInstance] isAuthenticatedOnFacebook]){
	// Do Something
	}

	/* Verify if user is authenticated via Flux */
	if ([[VMNSocialMediaMediator sharedInstance] isAuthenticatedOnFlux]){
	// Do Something
	}


### Retrieve a Social Network user

	VMNSocialMediaUser *user = [[VMNSocialMediaSession sharedInstance] currentUser];

The VMNSocial Media User object stores the properties for a Zeebox user and/or a Flux user:

This is how you access the properties of a Zeebox user:

	[user zeeBoxProfile ];

This call should return a NSDictionary with all the user properties exposed by the Zeebox API.

This is how you access the properties of a Viacom Flux user:

	[user fluxProfile ];
	
	
### Retrieve the Zeebox User Token

	NSString *zeeBoxToken = [[[VMNSocialMediaMediator sharedInstance] socialMediaSession] zeeBoxToken];

