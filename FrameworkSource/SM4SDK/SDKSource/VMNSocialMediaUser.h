/**
 
 VMNSocialMediaUser
 
 */

#import <Foundation/Foundation.h>

@interface VMNSocialMediaUser : NSObject <NSCoding> {
    NSDictionary *_fluxProfile;
    NSDictionary *_zeeBoxProfile;
}

-(void)initWithUsedDetails:(NSDictionary *)details;

@property(nonatomic, retain) NSDictionary* fluxProfile;
@property(nonatomic, retain) NSDictionary* zeeBoxProfile;


@end
