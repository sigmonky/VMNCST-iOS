#import <Foundation/Foundation.h>
#import "VMNSocialMediaTwitterSignedRequest.h"
#import <Twitter/Twitter.h>

@interface VMNSocialMediaTwitterUtils : NSObject
+ (void)storeLocalCredentialsWithAccessToken:(NSString*)accessToken
                           accessTokenSecret:(NSString*)accessTokenSecret;
+ (NSString*)accessToken;
+ (NSString*)accessTokenSecret;
+ (void)removeTwitterCookies;
+ (BOOL)hasLocalCredentials;
+ (void)removeLocalCredentials;
+ (NSString*)consumerKey;
+ (NSString*)consumerSecret;
+ (void)linkToAppWithConsumerKey:(NSString *)twConsumerKey consumerSecret:(NSString *)twConsumerSecret;
@end
