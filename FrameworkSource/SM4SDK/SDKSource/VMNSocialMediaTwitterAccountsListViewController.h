#import <UIKit/UIKit.h>

#import "VMNSocialMediaUser.h"
#import "VMNSocialMediaTwitterLoginProtocols.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface VMNSocialMediaTwitterAccountsListViewController : UITableViewController{
    float _viewTop;
    float _viewLeft;
    float _viewWidth;
    float _viewHeight;
    id<SMTwitterAccountsListDelegate>_delegate;

}

@property (strong, nonatomic) ACAccountStore *accountStore; 
@property (strong, nonatomic) NSArray *accounts;
@property (nonatomic, assign) id<SMTwitterAccountsListDelegate>delegate;

- (id)initWithViewLeft: (float)aViewLeft viewTop:(float)aViewTop viewWidth:(float)aViewWidth viewHeight:(float)aViewHeight;

@end
