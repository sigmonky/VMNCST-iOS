#import <Foundation/Foundation.h>


@class VMNSocialMediaRequest;

@protocol SMRequestDelegate

-(void)request:(VMNSocialMediaRequest *)request didFailWithError:(NSError *)error;

-(void)request:(VMNSocialMediaRequest *)request didLoad:(NSDictionary *)response;

@end


@protocol VMNSocialMediaSessionDelegate
-(void)showFluxSignupFormWithFields:(NSArray *)formFields;
@end



