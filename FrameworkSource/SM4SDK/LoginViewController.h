/**
 
 Abstract: LoginViewController
 
 Version: 1.0
 
 */

#import <UIKit/UIKit.h>
#import "SMSession.h"
#import "LoadingSpinner.h"

@interface LoginViewController : UIViewController<SMSessionDelegate, UITextFieldDelegate> {
    IBOutlet UIButton *shareButton;
    IBOutlet UIButton *fbLoginButton;
    IBOutlet UIButton *fluxLoginButton;
    IBOutlet UIButton *twitterLoginButton;
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passField;
    SMSession *session;
    LoadingSpinner *spinner;
}

-(IBAction)shareButtonClicked:(id)sender;
-(IBAction)fbLoginButtonClicked:(id)sender;

@end
