#import <Foundation/Foundation.h>


@interface VMNSocialMediaFacebookUtils : NSObject
+ (void)storeLocalCredentialsWithAccessToken:(NSString*)accessToken
                              expirationDate:(NSDate*)expirationDate;
+ (NSString*)accessToken;
+ (NSDate*)facebookExpirationDate;
+ (BOOL)hasLocalCredentials;
+ (void)removeFacebookCookies;
+ (void)removeLocalCredentials;
@end
