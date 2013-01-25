/**
 
 Abstract: LoginViewController
 
 Version: 1.0
 
 */

#import "LoginViewController.h"
#import "UserProfileController.h"
#import "AppDelegate.h"

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"VIACOM SOCIAL MEDIA SDK";
        [self.navigationController.navigationBar setBackgroundColor:[UIColor grayColor]];    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)refreshUI {
    spinner.view.hidden = YES;
    
    //Verify if user is authenticated on Flux
    if ([session isAuthenticatedOnFlux]){
        [fluxLoginButton setTitle: @"Logout from Flux" forState: UIControlStateNormal];
    }else{
        [fluxLoginButton setTitle: @"Login to Flux" forState: UIControlStateNormal];
    }
    
    //Verify if user is authenticated on Facebook
    if ([session isAuthenticatedOnFacebook]){
        [fbLoginButton setTitle: @"Logout from Facebook" forState: UIControlStateNormal];
    }else{
        [fbLoginButton setTitle: @"Login with Facebook" forState: UIControlStateNormal];
    }
    
    //Verify if user is authenticated on Twitter
    if ([session isAuthenticatedOnTwitter]){
        [twitterLoginButton setTitle: @"Logout from Twitter" forState: UIControlStateNormal];
    }else{
        [twitterLoginButton setTitle: @"Login with Twitter" forState: UIControlStateNormal];
    }

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    spinner = [[LoadingSpinner alloc] initWithNibName:@"LoadingSpinner" bundle:nil];
    passField.secureTextEntry = YES;
    [self.view addSubview:spinner.view];
    session = ((AppDelegate *)[UIApplication sharedApplication].delegate).session;
    session.delegate = self;
    [self refreshUI];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



-(IBAction)fbLoginButtonClicked:(id)sender {
    
    
//    if ([session isAuthenticatedOnFacebook]) {
//        [session logout:FACEBOOK];
//    } else {
//        [session authenticate:FACEBOOK];
//    }
}

-(IBAction)twitterLoginButtonClicked:(id)sender {
    if ([session isAuthenticatedOnTwitter]) {
        [session logout:TWITTER];
    } else {
        [session authenticate:TWITTER];
    }
}

-(IBAction)fluxLoginButtonClicked:(id)sender {
    spinner.view.hidden = NO;
    if ([session isAuthenticatedOnFlux]) {
        [session logout:FLUX];
    } else {
        [session authenticateWithUserName:usernameField.text andPassword:passField.text];
    }
}


#pragma mark SMSessionDelegate

-(void)didLogin {
    NSLog(@"did login");
    [self refreshUI];
}

-(void)didNotLoginWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    [self refreshUI];
}

-(void)didLogout {
    [self refreshUI];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
