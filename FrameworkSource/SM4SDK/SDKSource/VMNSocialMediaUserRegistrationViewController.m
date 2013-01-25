#import "VMNSocialMediaUserRegistrationViewController.h"

//Import Form Table View UI
#import "VMNSocialMediaUserRegistrationFormViewController.h"

#define kViewHeight CGRectGetHeight([UIScreen mainScreen].applicationFrame)
#define kViewWidth  CGRectGetWidth([UIScreen mainScreen].applicationFrame)


@interface VMNSocialMediaUserRegistrationViewController ()

@end

@implementation VMNSocialMediaUserRegistrationViewController

@synthesize delegate = _delegate;
@synthesize formFields;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithDelegate:(id<VMNSocialMediaUserRegistrationCompletionDelegate>)feedbackDelegate{
	self = [super init];
	if (self != nil) {
		_delegate = feedbackDelegate;
		
	}
	return self;
}

-(void) close_clicked:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


- (void)viewDidLoad{
    [self.view setFrame:CGRectMake(0, 0, kViewWidth, kViewHeight)];

    UINavigationController *navigationController = [[UINavigationController alloc] init];
    navigationController.view.frame = self.view.frame;
    VMNSocialMediaUserRegistrationFormViewController *formView = [[VMNSocialMediaUserRegistrationFormViewController alloc] init];
    formView.formFields = self.formFields;
    formView.delegate = self;
    [navigationController pushViewController:formView animated:YES];
    [formView release];
    navigationController.delegate = self;
    [self.view addSubview:navigationController.view];
}

- (void) closeButtonClick {
//    NSLog(@"User Registration close");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.view removeFromSuperview];
}


#pragma mark VMNSocialMediaRequestDelegate

- (void)closeForm{
    
    if (NSClassFromString(@"UISplitViewController") != nil && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissModalViewControllerAnimated:YES];
    }else{
        [self.view removeFromSuperview];
    }
}


#pragma mark VMNSocialMediaUserRegistrationCompletionDelegate

- (void)registrationDidComplete:(NSError *)error{
//    NSLog(@"registrationDidComplete %@", _delegate);
    if ([_delegate respondsToSelector:@selector(registrationDidComplete)]) {
        [_delegate registrationDidComplete];
    }
    [self closeForm];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc{
    [super dealloc];
    self.formFields = nil;
    self.delegate = nil;

}
@end
