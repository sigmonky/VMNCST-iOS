#import <Foundation/Foundation.h>

@interface VMNSocialMediaZBoxUtils : NSObject
+ (NSString*)accessToken;
+ (void)storeLocalCredentials:(NSString*)zboxToken;
+ (BOOL)hasLocalCredentials;
+ (void)removeLocalCredentials;
@end
