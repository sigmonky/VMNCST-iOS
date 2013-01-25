#import "VMNSocialMediaFluxUtils.h"
#import "VMNSocialMediaConstants.h"

@implementation VMNSocialMediaFluxUtils

+ (NSString*)fluxCookie {
    return [[NSUserDefaults standardUserDefaults] objectForKey:VMN_SM_FLUX_COOKIE];
}

+(NSHTTPCookie *)authCookie {
    NSHTTPCookie *authCookie = nil;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if ([@"RtxAuth2407" isEqualToString:cookie.name]) {
            authCookie = cookie;
            break;
        }
    }
    return authCookie;
}

+ (void)storeLocalCredentials{
    NSHTTPCookie *authCookie = [VMNSocialMediaFluxUtils authCookie];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:authCookie.value forKey:VMN_SM_FLUX_COOKIE];
    [defaults synchronize];
}

+ (void)storeLocalCredentialsWithValue:(NSString *)cookieValue{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:cookieValue forKey:VMN_SM_FLUX_COOKIE];
    [defaults synchronize];
}


+ (BOOL)hasLocalCredentials {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:VMN_SM_FLUX_COOKIE] != nil;
}

+ (void)removeLocalCredentials {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Remove Flux Cookie
    [defaults removeObjectForKey:VMN_SM_FLUX_COOKIE];
    //remove Flux User ID
    [defaults removeObjectForKey:VMN_SM_FLUX_USER_ID];

    [defaults synchronize];
    [VMNSocialMediaFluxUtils removeFluxCookies];
}

+ (void)removeFluxCookies{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if ([[cookie domain] isEqualToString:@".flux.com"]) {
            [storage deleteCookie:cookie];
        }
    }
}

+ (void)storeUserID:(NSString *)userID{
    //Store Flux User ID
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userID forKey:VMN_SM_FLUX_USER_ID];
    [defaults synchronize];
}

+ (NSString *)userID{
    return [[NSUserDefaults standardUserDefaults] objectForKey:VMN_SM_FLUX_USER_ID];
}


@end
