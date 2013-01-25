#import "VMNSocialMediaTwitterUtils.h"
#import "VMNSocialMediaConstants.h"

@implementation VMNSocialMediaTwitterUtils

+ (NSString*)accessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:VMN_SM_TWITTER_AUTH_ACCESS_TOKEN];
}

+ (NSString*)accessTokenSecret {
    return [[NSUserDefaults standardUserDefaults] objectForKey:VMN_SM_TWITTER_AUTH_SECRET_ACCESS_TOKEN];
}


// called by SMTwitterReverseAuthManager
+ (void)storeLocalCredentialsWithAccessToken:(NSString*)accessToken
                           accessTokenSecret:(NSString*)accessTokenSecret {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:VMN_SM_TWITTER_AUTH_ACCESS_TOKEN];
    [defaults setObject:accessTokenSecret forKey:VMN_SM_TWITTER_AUTH_SECRET_ACCESS_TOKEN];
    [defaults synchronize];
}

+ (void)linkToAppWithConsumerKey:(NSString *)twConsumerKey consumerSecret:(NSString *)twConsumerSecret{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:twConsumerKey forKey:VMN_SM_TWITTER_APP_CONSUMER_KEY];
    [defaults setObject:twConsumerSecret forKey:VMN_SM_TWITTER_APP_CONSUMER_SECRET];
    [defaults synchronize];
}

+ (void)removeTwitterCookies {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if ([[cookie domain] isEqualToString:@".twitter.com"]) {
            [storage deleteCookie:cookie];
        }
    }
}

+ (BOOL)hasLocalCredentials {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:VMN_SM_TWITTER_AUTH_ACCESS_TOKEN] != nil &&
    [defaults objectForKey:VMN_SM_TWITTER_AUTH_SECRET_ACCESS_TOKEN] != nil;
}


+ (void)removeLocalCredentials{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Remove any Twitter data -- these are Socialize specific
    [defaults removeObjectForKey:VMN_SM_TWITTER_AUTH_ACCESS_TOKEN];
    [defaults removeObjectForKey:VMN_SM_TWITTER_AUTH_SECRET_ACCESS_TOKEN];
    [defaults synchronize];
    [self removeTwitterCookies];
}

+ (NSString*)consumerKey {
    return [[NSUserDefaults standardUserDefaults] objectForKey:VMN_SM_TWITTER_APP_CONSUMER_KEY];
}

+ (NSString*)consumerSecret {
    return [[NSUserDefaults standardUserDefaults] objectForKey:VMN_SM_TWITTER_APP_CONSUMER_SECRET];
}


@end
