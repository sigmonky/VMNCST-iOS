#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate> {
    IBOutlet UIButton *shareButton;
    IBOutlet UIButton *fbLoginButton;
    IBOutlet UIButton *fluxLoginButton;
    IBOutlet UIButton *twitterLoginButton;
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passField;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UILabel *passLabel;
    IBOutlet UIButton *zBoxProfile;
    IBOutlet UIButton *fluxProfile;
    IBOutlet UIButton *createAccount;

}

-(IBAction)fbLoginButtonClicked:(id)sender;
-(IBAction)twitterLoginButtonClicked:(id)sender;
-(IBAction)fluxLoginButtonClicked:(id)sender;
-(IBAction)viewFluxProfile:(id)sender;
-(IBAction)viewZeeBoxProfile:(id)sender;
- (void)refreshUI;
@end
