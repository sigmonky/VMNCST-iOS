#import "VMNSocialMediaZBoxUtils.h"
#import "VMNSocialMediaConstants.h"

@implementation VMNSocialMediaZBoxUtils


+ (NSString*)accessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:VMN_SM_ZBOX_TOKEN];
}

+ (void)storeLocalCredentials:(NSString *)zboxToken{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:zboxToken forKey:VMN_SM_ZBOX_TOKEN];
    [defaults synchronize];
}

+ (BOOL)hasLocalCredentials {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:VMN_SM_ZBOX_TOKEN] != nil;
}

+ (void)removeLocalCredentials {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Remove any Twitter data -- these are Socialize specific
    [defaults removeObjectForKey:VMN_SM_ZBOX_TOKEN];
    [defaults synchronize];
}

@end
