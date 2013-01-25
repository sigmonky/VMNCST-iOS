#import <UIKit/UIKit.h>

#import "VMNSocialMediaTwitterAccountsListViewController.h"
#import "VMNSocialMediaTwitterLoginProtocols.h"

@interface VMNSocialMediaTwitterViewController : UIViewController <SMTwitterAccountsListDelegate>{
    id<SMTwitterViewControllerDelegate>_delegate;
}

@property (nonatomic, assign) id<SMTwitterViewControllerDelegate>delegate;

- (id) initWithDelegate:(id<SMTwitterViewControllerDelegate>)feedbackDelegate;

@end
