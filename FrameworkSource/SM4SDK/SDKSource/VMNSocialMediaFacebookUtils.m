#import "VMNSocialMediaFacebookUtils.h"
#import "VMNSocialMediaConstants.h"

@implementation VMNSocialMediaFacebookUtils

+ (void)storeLocalCredentialsWithAccessToken:(NSString*)accessToken
                              expirationDate:(NSDate*)expirationDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:VMN_SM_FACEBOOK_AUTH_ACCESS_TOKEN];
    [defaults setObject:expirationDate forKey:VMN_SM_FACEBOOK_AUTH_EXPIRATION_DATE];
    [defaults synchronize];
}

+ (NSString*)accessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:VMN_SM_FACEBOOK_AUTH_ACCESS_TOKEN];
}

+ (NSDate*)facebookExpirationDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:VMN_SM_FACEBOOK_AUTH_EXPIRATION_DATE];
}

+ (BOOL)hasLocalCredentials {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:VMN_SM_FACEBOOK_AUTH_ACCESS_TOKEN] != nil &&
    [[defaults objectForKey:VMN_SM_FACEBOOK_AUTH_EXPIRATION_DATE] timeIntervalSinceNow] > 0;
}

+ (void)removeFacebookCookies {
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:
                                [NSURL URLWithString:@"http://login.facebook.com"]];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        [cookies deleteCookie:cookie];
    }
}

+ (void)removeLocalCredentials {
    [self removeFacebookCookies];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:VMN_SM_FACEBOOK_AUTH_ACCESS_TOKEN];
    [defaults removeObjectForKey:VMN_SM_FACEBOOK_AUTH_EXPIRATION_DATE];
}

@end
