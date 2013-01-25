#import "VMNSocialMediaSettingsUtils.h"

#define SETTINGS_FLUX_COMMUNITY_ID @"VMNSocialMediaID"
#define SETTINGS_TWITTER_CONSUMER_KEY @"VMNTwitterConsumerKey"
#define SETTINGS_TWITTER_CONSUMER_SECRET @"VMNTwitterConsumerSecret"

@implementation VMNSocialMediaSettingsUtils

+ (NSString *) fluxCommunityID {
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:SETTINGS_FLUX_COMMUNITY_ID];
}

+ (NSString *) twitterConsumerKey {
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:SETTINGS_TWITTER_CONSUMER_KEY];
}

+ (NSString *) twitterConsumerSecret {
	return [[[NSBundle mainBundle] infoDictionary]objectForKey:SETTINGS_TWITTER_CONSUMER_SECRET];
}

@end
