#import <UIKit/UIKit.h>

#import "VMNSocialMediaUserRegistrationProtocols.h"

@interface VMNSocialMediaUserRegistrationViewController : UIViewController <VMNSocialMediaUserRegistrationDelegate, UINavigationControllerDelegate>{
    id<VMNSocialMediaUserRegistrationCompletionDelegate>_delegate;
}

@property (nonatomic, retain) NSArray *formFields;
@property (nonatomic, assign) id<VMNSocialMediaUserRegistrationCompletionDelegate>delegate;

- (id) initWithDelegate:(id<VMNSocialMediaUserRegistrationCompletionDelegate>)feedbackDelegate;

@end
