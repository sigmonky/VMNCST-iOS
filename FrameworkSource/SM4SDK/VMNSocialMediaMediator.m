// This is an implementation class to help to illustrate how Twitter and Facebook SDKs should interact with the Viacom Social Media SDK

#import "VMNSocialMediaMediator.h"
#import"VMNSocialMediaUserRegistrationViewController.h"

static VMNSocialMediaMediator *sharedInstance = nil;

@implementation VMNSocialMediaMediator

@synthesize facebookSession = _facebookSession;
@synthesize socialMediaSession = _socialMediaSession;
@synthesize twitterReadyCompletionBlock;
@synthesize registrationCompletionBlock;
@synthesize twitterAccounts = _twitterAccounts;
@synthesize callingView = _callingView;

/**
 Method that returns the VMNSocialMediaMediator Singleton Object
 */
+ (VMNSocialMediaMediator *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil){
            sharedInstance = [[super allocWithZone:NULL] init];
        }
    }
    return sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (id) copyWithZone:(NSZone*)zone {
    return self;
}

- (id) retain {
    return self;
}

- (NSUInteger) retainCount {
    return NSUIntegerMax; // denotes an object that cannot be released
}

- (void)release {
    // do nothing
}

- (id) autorelease {
    return self;
}


// Starts a new VMNSocialMedia session
- (void)startSession{
    //SET THE SM4 USER SESSION
    self.socialMediaSession= [[VMNSocialMediaSession sharedInstance] initWithDelegate:self];
}


// Checks if a user is connected to Flux.
// It should be here only if you application needs support for a Viacom Flux community.
- (BOOL)isAuthenticatedOnFlux{
    return [self.socialMediaSession hasFluxLocalCredentials]? TRUE : FALSE;
}

// Checks if a user is connected to Facebook
- (BOOL)isAuthenticatedOnFacebook{
    return [self.socialMediaSession hasFacebookLocalCredentials]? TRUE : FALSE;
}

// Checks if a user is connected to Twitter
- (BOOL)isAuthenticatedOnTwitter{
    return [self.socialMediaSession hasTwitterLocalCredentials]? TRUE : FALSE;
}


// Authenticates the user using a Viacom Flux username and password.
// It should be here only if you application needs support for a Viacom Flux community.
- (void)fluxAuthInView:(UIViewController *)aView username:(NSString *)username password:(NSString *)pass completion:(void (^)(NSError *err))completion{
    self.callingView = aView;
    if ([self isAuthenticatedOnFlux]){
        [self.socialMediaSession removeFluxLocalCredentials];
        [self.socialMediaSession  removeZeeBoxLocalCredentials];
        completion(nil);
    }else{
        [self.socialMediaSession authenticateWithFluxUserName:username password:pass completion:^( NSError *error) {
            completion(error);
        }];
    }
}

// Displays a registration dialog to create a new user in a Viacom Flux community.
// It should be here only if you application needs support for a Viacom Flux community.
- (void)registerFluxUserInView:(UIViewController *)aView completion:(void (^)(NSError *err))completion{
    self.callingView = aView;
    self.registrationCompletionBlock = completion;
    [self.socialMediaSession completeFluxUserSignUp];
}


// Displays a view to authenticate a Facebook user
- (void)facebookAuthInView:(UIViewController *)aView completion:(void (^)(NSError *err))completion{
    self.callingView = aView;
    // this button's job is to flip-flop the session from open to closed
    if (FBSession.activeSession.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [FBSession.activeSession closeAndClearTokenInformation];
        
        //Remove local credentials
        [self.socialMediaSession  removeFacebookLocalCredentials];
        [self.socialMediaSession  removeZeeBoxLocalCredentials];
        
        if (completion != nil) {
            completion(nil);
        }
    } else {
        if (FBSession.activeSession.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            FBSession.activeSession = [[FBSession alloc] init];
        }
        
        NSArray *permissions = [NSArray arrayWithObjects:@"email", nil];
        
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (error != nil){
                                              
                                          }else{
                                              //Store Facebook
                                              NSString *existingToken = [NSString stringWithFormat:@"%@", session.accessToken];
                                              
                                              NSDate *existingExpiration = session.expirationDate;
                                              
                                              [self.socialMediaSession  storeFacebookLocalCredentialsWithAccessToken:existingToken existingExpiration:existingExpiration];
                                              
                                              //Link to Flux backend
                                              //It should be here only if you application needs support for a Viacom Flux community.
                                              if (![self isAuthenticatedOnFlux]){
                                                  [self.socialMediaSession  linkFluxToFacebook:^( NSError *error){
                                                      //Return to the calling block
                                                      completion(error);
                                                  }];
                                              }else{
                                                  completion(nil);
                                              }
                                              
                                              //Link to Zeebox
                                              [self.socialMediaSession linkToZeeBox:FACEBOOK completion:^( NSError *error) {
                                                  completion(nil);
                                              }];
                                              
                                          }
                                      }];
    }
}

// Check for a Facebook user session
- (void)checkFacebookSessionInitialization:(void (^)(NSError *err))completion{
    if (!FBSession.activeSession.isOpen) {
        // create a fresh session object
        FBSession.activeSession = [[FBSession alloc] init];
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [FBSession.activeSession openWithCompletionHandler:^(FBSession *session,
                                                                 FBSessionState status,
                                                                 NSError *error) {
                if (completion != nil) {
                    completion(nil);
                }
            }];
        }
    }
}

// Displays a view to authenticate a Twitter user
- (void)twitterAuthInView:(UIViewController *)aView completion:(void (^)(NSError *err))completion{
    self.callingView = aView;
    if ([self isAuthenticatedOnTwitter]){
        //Remove local credentials
        [self.socialMediaSession removeTwitterLocalCredentials];
        [self.socialMediaSession  removeZeeBoxLocalCredentials];
        completion(nil);
    }else{
        //Check if it's IOS5 or above
        Class TWTweetClass = NSClassFromString(@"TWTweetComposeViewController");
        if (TWTweetClass){
            [self fetchDataFromUserAccounts:^( NSError *error) {
                //Check if there's more than one Twitter account registered in the user's device
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.twitterReadyCompletionBlock = completion;
                    if (error == nil){
                        if ([self.twitterAccounts count]>1){
                            //If there's more than one twitter account, display a list with all Twitter accounts registered in a device.
                            VMNSocialMediaTwitterViewController *twitterAccountsList = [[VMNSocialMediaTwitterViewController alloc]initWithDelegate:self];
                            [aView.view addSubview:twitterAccountsList.view];
                        }else{
                            [VMNSocialMediaTwitterReverseAuthManager sharedInstance].delegate = self;
                            [[VMNSocialMediaTwitterReverseAuthManager sharedInstance] performReverseAuth:[self.twitterAccounts objectAtIndex:0]];
                        }
                    }else{
                        completion(error);
                    }
                });
                
            }];
        }
    }
}


// Fetch Twitter accounts from Apple's Account Framework. In case the user only has one Twitter account registered in his/her device, that one will automatically be selected. Otherwise a tableview will be showed with the list of all Twitter accounts registered in the device.
- (void)fetchDataFromUserAccounts:(void (^)(NSError *err))completion{
    {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        if (_twitterAccounts == nil) {
            ACAccountType *accountTypeTwitter = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            [accountStore requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) {
                if(granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        self.twitterAccounts = [accountStore accountsWithAccountType:accountTypeTwitter];
                        completion(nil);
                    });
                }else{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSString *message;
                        if (error.code == 6){
                            message = @"There's no Twitter account registered in this device.";
                        }else{
                            message = @"User didn't allow access to his/her Twitter account";
                        }
                        completion(nil);
                    });
                }
            }];
        }else{
            completion(nil);
        }
    }
}


#pragma mark Twitter Auth Flow Delegate Methods

// Delegate method that is called when a user has selected a Twitter account
- (void)twitterAccountDidGetSelected:(id)account{
    //Twitter account has been selected. Perform reverse auth.
    [VMNSocialMediaTwitterReverseAuthManager sharedInstance].delegate = self;
    [[VMNSocialMediaTwitterReverseAuthManager sharedInstance] performReverseAuth:account];
}

// Delegate method of a User who did not authorize access to his/her Twitter account
- (void)twitterAccountNotAuthorized:(NSError *)error{
    twitterReadyCompletionBlock(error);
}

#pragma mark Twitter Reverse Auth Flow Delegate Methods

//Reverse auth is necessary in order to retrieve a Twitter secret token from a user and pass it over to either Flux and/or Zeebox

//Delegate method called when Twitter reverse auth has been completed
- (void) reverseAuthDidSucceed{
    
    // Link selected Twitter account to Flux backend if Viacom Flux credentials are nil
    // It should be here only if you application needs support for a Viacom Flux community.
    if (![self isAuthenticatedOnFlux]){
        [self.socialMediaSession linkFluxToTwitter:^( NSError *error){
            twitterReadyCompletionBlock(error);
        }];
    }
    else{
        twitterReadyCompletionBlock(nil);
    }
    
    //Link the user to Zeebox
    [self.socialMediaSession linkToZeeBox:TWITTER completion:^( NSError *error) {
        //error handling
        twitterReadyCompletionBlock(nil);
    }];
    
}

//Delegate method called if Twitter reverse auth failed
- (void) reverseAuthDidFailWithError:(NSError *)error{
    twitterReadyCompletionBlock(error);
}


#pragma mark VMNSocialMediaSessionDelegate

//Delegate method called to display additional user registration fields for a Facebook or Twitter authenticated user.
//It should be here only if you application needs support for a Viacom Flux community.

- (void)showFluxSignupFormWithFields:(NSArray *)formFields{
    //Show Signup/Registration Form
    VMNSocialMediaUserRegistrationViewController *regForm = [[VMNSocialMediaUserRegistrationViewController alloc] initWithDelegate:self];
    regForm.formFields = formFields;
    if ([formFields count] >0){
        
        //Ipad View
        if (NSClassFromString(@"UISplitViewController") != nil && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            regForm.modalPresentationStyle = UIModalPresentationFormSheet;
            // show the navigation controller modally
            [self.callingView presentModalViewController:regForm animated:YES];
            
        }else{
            //iPhone View
            [self.callingView.view addSubview:regForm.view];
        }
    }
}

#pragma mark VMNSocialMediaUserRegistrationDelegate

//Delegate method called to indicate that a user registration in a Viacom Flux community has been completed.
//It should be here only if you application needs support for a Viacom Flux community.
- (void)registrationDidComplete{
    registrationCompletionBlock(nil);
}


@end