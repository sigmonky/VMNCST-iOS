// This is an implementation class to help to illustrate how Twitter and Facebook SDKs should interact with the Viacom Social Media SDK

#import <Foundation/Foundation.h>

//Import VMNSocialMediaSDK Session
#import "VMNSocialMediaSession.h"

// Apple's account framework
#import <Accounts/Accounts.h>

// Facebook SDK
#import <FacebookSDK/FacebookSDK.h>

/* Twitter API */
#import <Twitter/Twitter.h>

/* Twitter View Auth Flow Implementation */
#import "VMNSocialMediaTwitterLoginProtocols.h"

#import "VMNSocialMediaTwitterViewController.h"

//Example implementation of Twitter Reverse Auth
#import "VMNSocialMediaTwitterReverseAuthManager.h"

#import "VMNSocialMediaUserRegistrationProtocols.h"


@interface VMNSocialMediaMediator : NSObject <SMTwitterViewControllerDelegate,SMTwitterReverseAuthDelegate,VMNSocialMediaSessionDelegate, VMNSocialMediaUserRegistrationCompletionDelegate>{
}

+ (VMNSocialMediaMediator *)sharedInstance;
- (void)startSession;
- (void)fluxAuthInView:(UIViewController *)view username:(NSString *)username password:(NSString *)pass completion:(void (^)(NSError *err))completion;
- (void)facebookAuthInView:(UIViewController *)view completion:(void (^)(NSError *err))completion;
- (void)twitterAuthInView:(UIViewController *)aView completion:(void (^)(NSError *err))completion;
- (void)registerFluxUserInView:(UIViewController *)aView completion:(void (^)(NSError *err))completion;

- (void)checkFacebookSessionInitialization:(void (^)(NSError *err))completion;
- (void)fetchDataFromUserAccounts:(void (^)(NSError *err))completion;
- (BOOL)isAuthenticatedOnFlux;
- (BOOL)isAuthenticatedOnFacebook;
- (BOOL)isAuthenticatedOnTwitter;
    
@property (strong, nonatomic) VMNSocialMediaSession *socialMediaSession;
@property (strong, nonatomic) FBSession *facebookSession;
@property (strong, nonatomic) NSArray *twitterAccounts;
@property (strong, nonatomic) UIViewController *callingView;

@property (nonatomic, copy) void (^twitterReadyCompletionBlock)(NSError *err);

@property (nonatomic, copy) void (^registrationCompletionBlock)(NSError *err);


@end
