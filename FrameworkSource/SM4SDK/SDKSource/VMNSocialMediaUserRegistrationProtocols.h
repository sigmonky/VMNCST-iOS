#import <Foundation/Foundation.h>

@protocol VMNSocialMediaUserRegistrationDelegate

- (void)registrationDidComplete:(NSError *)error;
@optional
- (void)closeForm;
@end



@protocol SelectCountryDelegate
- (void)didSelectCountry:(NSString *)country;
@end


@protocol VMNSocialMediaUserRegistrationCompletionDelegate
- (void)registrationDidComplete;
@end