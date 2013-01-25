#import <Foundation/Foundation.h>

@interface VMNSocialMediaFluxUtils : NSObject
+ (NSString*)fluxCookie;
+ (BOOL)hasLocalCredentials;
+ (void)removeLocalCredentials;
+ (void)removeFluxCookies;
+(NSHTTPCookie *)authCookie;
+ (void)storeLocalCredentials;
+ (void)storeLocalCredentialsWithValue:(NSString *)cookieValue;
+ (void)storeUserID:(NSString *)userID;
+ (NSString *)userID;
@end
