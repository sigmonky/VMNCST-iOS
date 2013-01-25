#import <Foundation/Foundation.h>

#import "VMNSocialMediaProtocols.h"
#import "VMNSocialMediaUser.h"
#import "VMNSocialMediaFacebookUtils.h"
#import "VMNSocialMediaTwitterUtils.h"
#import "VMNSocialMediaFluxUtils.h"
#import "VMNSocialMediaZBoxUtils.h"

extern NSString *kErrorDomain;

typedef enum SocialNetworkName {
    FACEBOOK,
    TWITTER
} SocialNetworkName;

@class SMTwitterLoginController;

@interface VMNSocialMediaSession : NSObject<SMRequestDelegate> {
    id<VMNSocialMediaSessionDelegate> _delegate;
    VMNSocialMediaUser* _currentUser;
@private
	SMTwitterLoginController *twitterLoginController;
}

-(id)initWithDelegate:(id<VMNSocialMediaSessionDelegate>)delegate;
-(id)initWithUCID:(NSString *)ucid andDelegate:(id<VMNSocialMediaSessionDelegate>)delegate;
-(id)startWithUCID:(NSString *)ucid andDelegate:(id<VMNSocialMediaSessionDelegate>)delegate;

-(void)authenticateWithFluxUserName:(NSString *)userName password:(NSString *)password completion:(void (^)(NSError *err))completion;

-(void)linkFluxToFacebook:(void (^)(NSError *err))completion;
-(void)linkFluxToTwitter:(void (^)(NSError *err))completion;
-(void)linkToZeeBox:(SocialNetworkName)socialNetworkName completion:(void (^)(NSError *err))completion;

-(BOOL)hasFacebookLocalCredentials;
-(BOOL)hasTwitterLocalCredentials;
-(BOOL)hasFluxLocalCredentials;

- (void)completeFluxUserSignUp;
- (void)removeFacebookLocalCredentials;
- (void)removeTwitterLocalCredentials;
- (void)removeFluxLocalCredentials;
- (void)removeZeeBoxLocalCredentials;
- (void)getZBoxUserProfile;
- (void)getFluxUserProfile;

- (NSString *)facebookToken;
- (NSString *)zeeBoxToken;
- (NSString *)fluxToken;

+ (VMNSocialMediaSession *)sharedInstance;

- (void)submitFluxRegistrationInfo:(NSMutableDictionary *)formValues completion:(void (^)(NSMutableDictionary *response))completion;

- (void)twitterPerformReverseAuth;

- (void)storeFacebookLocalCredentialsWithAccessToken:(NSString*)accessToken
                                      existingExpiration:(NSDate*)expirationDate;
- (void)linkToTwitterAppWithConsumerKey:(NSString *)twConsumerKey consumerSecret:(NSString *)twConsumerSecret;

- (NSString *)apiVersion;

@property (nonatomic, retain) VMNSocialMediaUser *currentUser;
@property (nonatomic, assign) id<VMNSocialMediaSessionDelegate> delegate;

@end
