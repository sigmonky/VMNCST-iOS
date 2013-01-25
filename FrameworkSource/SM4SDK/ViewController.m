#import "ViewController.h"
#import "AppDelegate.h"
#import "ZeeBoxUserViewController.h"
#import "FluxUserViewController.h"

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)refreshUI {
    
    //Verify if user is authenticated on Facebook
    if ([[VMNSocialMediaMediator sharedInstance] isAuthenticatedOnFacebook]) {
        // valid account UI is shown whenever the session is open
        [fbLoginButton setTitle: @"Logout from Facebook" forState: UIControlStateNormal];
    } else {
       [fbLoginButton setTitle: @"Login with Facebook" forState: UIControlStateNormal];
    }
    
    //Verify if user is authenticated on Twitter
    if ([[VMNSocialMediaMediator sharedInstance] isAuthenticatedOnTwitter]){
        // valid account UI is shown whenever the session is open
           [twitterLoginButton setTitle: @"Logout from Twitter" forState: UIControlStateNormal];
    }else{
           [twitterLoginButton setTitle: @"Login with Twitter" forState: UIControlStateNormal];
    }
    
    //Verify if user is authenticated on Flux
    if ([[VMNSocialMediaMediator sharedInstance] isAuthenticatedOnFlux]){
        // valid account UI is shown whenever the session is open
        usernameField.alpha = 0;
        passField.alpha = 0;
        usernameLabel.alpha = 0;
        passLabel.alpha = 0;
        createAccount.alpha = 0;

        [fluxLoginButton setTitle: @"Logout from Flux" forState: UIControlStateNormal];
    }else{
        usernameField.alpha = 1;
        passField.alpha = 1;
        usernameLabel.alpha = 1;
        passLabel.alpha = 1;
        createAccount.alpha = 1;
        [fluxLoginButton setTitle: @"Login using Flux credentials" forState: UIControlStateNormal];
    }
    
    if ([[VMNSocialMediaMediator sharedInstance] isAuthenticatedOnFacebook] || [[VMNSocialMediaMediator sharedInstance] isAuthenticatedOnTwitter] ){
        zBoxProfile.alpha = 1;
        fluxProfile.alpha = 1;
    }else{
        zBoxProfile.alpha = 0;
        fluxProfile.alpha = 0;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    // Check if user is authenticated on Facebook
    [[VMNSocialMediaMediator sharedInstance] checkFacebookSessionInitialization:^( NSError *error) {
        [self refreshUI];
    }];
    
    passField.secureTextEntry = YES;
    
    // Check social media buttons login/logout state
    [self refreshUI];
    
    [super viewDidLoad];

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
    [[VMNSocialMediaMediator sharedInstance] facebookAuthInView:self completion:^( NSError *error) {
        if (error == nil){
            // Facebook login has been successfull
        }else{
            //handle error
            NSString *errorMsg = [error localizedDescription];

            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flux Error" message:errorMsg delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
            });
        }
        [self refreshUI];

    }];
}

-(IBAction)twitterLoginButtonClicked:(id)sender {
    [[VMNSocialMediaMediator sharedInstance] twitterAuthInView:self completion:^( NSError *error) {
        if (error == nil){
            // Twitter login has been successfull
        }else{
            //handle error
            NSLog(@"nserror %@", [error localizedDescription]);
            NSString *errorMsg = [error localizedDescription];

            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flux Error" message:errorMsg delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
            });
        
        }
        
        [self refreshUI];

    }];
}

-(IBAction)fluxLoginButtonClicked:(id)sender {
    [[VMNSocialMediaMediator sharedInstance] fluxAuthInView:self username:usernameField.text password:passField.text completion:^( NSError *error) {
        if (error == nil){
            // Flux login has been successfull
        }else{
            //handle error
            NSString *errorMsg = [error localizedDescription];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flux Error" message:errorMsg delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
            });
        }
        [self refreshUI];
    }];
}


-(IBAction)viewFluxProfile:(id)sender {
    FluxUserViewController *fluxUserProfile = [[FluxUserViewController alloc]init];
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.view.frame = self.view.frame;
    [self presentModalViewController: fluxUserProfile
                            animated: YES];

}

-(IBAction)viewZeeBoxProfile:(id)sender {
    ZeeBoxUserViewController *zeeBoxUserProfile = [[ZeeBoxUserViewController alloc]init];
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.view.frame = self.view.frame;
    [self presentModalViewController: zeeBoxUserProfile
                            animated: YES];
}

- (IBAction)createAccount:(id)sender{
    // Create an Account with Flux
    [[VMNSocialMediaMediator sharedInstance] registerFluxUserInView:self completion:^( NSError *error) {
        if (error == nil){
            // Flux user registration has been successfull
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"You have been successfully registered." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }else{
            // Show error message
        }
    }];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
